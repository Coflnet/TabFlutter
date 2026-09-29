"""Playwright harness for the Spables Excel add-in (web/excel/).

No real Excel is involved: office.js is replaced by office_mock.js (an
in-memory workbook with Office.js batching semantics) and the backend
https://tab.coflnet.com is replaced by `Backend`, which implements §2 of the
Excel sync contract.

Run:  python test/excel_addin/test_taskpane.py        (or: pytest test/excel_addin)
Env:  CHROME_PATH   Chromium binary (default: Playwright's bundled one)
      SCREENSHOT_DIR where pane screenshots go (default: a temp dir)
"""

import functools
import http.server
import json
import os
import pathlib
import random
import re
import tempfile
import threading
import time
import traceback
import uuid
from datetime import datetime, timedelta, timezone
from urllib.parse import urlparse
from zoneinfo import ZoneInfo

from playwright.sync_api import sync_playwright

HERE = pathlib.Path(__file__).resolve().parent
ADDIN_DIR = HERE.parent.parent / "web" / "excel"
OFFICE_JS = "https://appsforoffice.microsoft.com/lib/1/hosted/office.js"
API = "https://tab.coflnet.com"
TZ = "Europe/Berlin"
SHOTS = pathlib.Path(os.environ.get("SCREENSHOT_DIR") or tempfile.mkdtemp(prefix="spables-addin-"))
ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
USED = {}  # Excel API member -> requirement set, collected from the mock


# ---------------------------------------------------------------- backend mock

class Backend:
    """In-memory implementation of the contract's §2 endpoints."""

    def __init__(self):
        self.integrations = {}   # pollToken -> integration dict
        self.calls = []          # (method, path)
        self.code_ttl = 15 * 60
        self.fail_ack = 0        # number of acks to answer with 500
        self.bad_headers = set()

    # --- helpers used by the tests (the "phone" side) ---
    def only(self):
        assert len(self.integrations) == 1, self.integrations
        return next(iter(self.integrations.values()))

    def pair(self, code):
        norm = re.sub(r"[\s-]", "", code).upper()
        for integ in self.integrations.values():
            if integ["code"] and integ["code"].replace("-", "") == norm and integ["code_exp"] > time.time():
                integ["code"] = None
                push = uuid.uuid4().hex
                integ["push_tokens"].add(push)
                return push
        raise AssertionError("pairing code not valid: " + code)

    def push(self, push_token, data, entry_id=None, created=None):
        integ = next(i for i in self.integrations.values() if push_token in i["push_tokens"])
        entry_id = entry_id or str(uuid.uuid4())
        if not any(e["entryId"] == entry_id for e in integ["entries"]):
            integ["entries"].append({
                "entryId": entry_id,
                "createdAt": created or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
                "data": data,
            })
        return entry_id

    def count(self, method, path):
        return sum(1 for c in self.calls if c == (method, path))

    # --- HTTP ---
    def _new_code(self, integ):
        code = "".join(random.choice(ALPHABET) for _ in range(8))
        integ["code"] = code[:4] + "-" + code[4:]
        integ["code_exp"] = time.time() + self.code_ttl
        return {
            "pairingCode": integ["code"],
            "pairingExpiresAt": datetime.fromtimestamp(integ["code_exp"], timezone.utc).isoformat().replace("+00:00", "Z"),
        }

    def handle(self, route, request):
        origin = request.headers.get("origin", "*")
        cors = {"Access-Control-Allow-Origin": origin, "Vary": "Origin"}
        # Playwright answers CORS preflights of routed requests itself, so check
        # here that only the custom headers the backend allows are sent.
        custom = {h for h in request.headers if h.startswith("x-")}
        self.bad_headers |= custom - {"x-integration-token", "x-integration-push-token"}
        if request.method == "OPTIONS":
            return route.fulfill(status=204, headers={
                **cors,
                "Access-Control-Allow-Methods": "GET, POST, DELETE",
                "Access-Control-Allow-Headers": "Content-Type, X-Integration-Token, X-Integration-Push-Token",
            })
        path = urlparse(request.url).path
        self.calls.append((request.method, path))
        status, body = self._dispatch(request.method, path, request)
        route.fulfill(status=status, headers={**cors, "Content-Type": "application/json"}, body=json.dumps(body))

    def _dispatch(self, method, path, request):
        if (method, path) == ("POST", "/api/integration/excel"):
            label = json.loads(request.post_data or "{}").get("label")
            token = uuid.uuid4().hex
            integ = {"id": str(uuid.uuid4()), "token": token, "label": label, "push_tokens": set(),
                     "entries": [], "code": None, "code_exp": 0}
            self.integrations[token] = integ
            return 200, {"integrationId": integ["id"], "pollToken": token, **self._new_code(integ)}

        integ = self.integrations.get(request.headers.get("x-integration-token", ""))
        if integ is None:
            return 401, {"error": "unknown token"}
        if (method, path) == ("POST", "/api/integration/excel/code"):
            return 200, self._new_code(integ)
        if (method, path) == ("GET", "/api/integration/status"):
            return 200, {"integrationId": integ["id"], "label": integ["label"],
                         "devices": len(integ["push_tokens"]), "pending": len(integ["entries"])}
        if (method, path) == ("GET", "/api/integration/entries"):
            return 200, integ["entries"][:100]
        if (method, path) == ("POST", "/api/integration/entries/ack"):
            if self.fail_ack:
                self.fail_ack -= 1
                return 500, {"error": "simulated ack failure"}
            ids = set(json.loads(request.post_data)["entryIds"])
            integ["entries"] = [e for e in integ["entries"] if e["entryId"] not in ids]
            return 200, {}
        if (method, path) == ("DELETE", "/api/integration/devices"):
            integ["push_tokens"].clear()
            return 200, {}
        return 404, {"error": "not found"}


# ---------------------------------------------------------------- harness

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def start_server():
    handler = functools.partial(QuietHandler, directory=str(ADDIN_DIR))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


class Pane:
    """One task pane instance (one opened workbook)."""

    def __init__(self, env, backend, lang="de-DE", doc=None, url=None):
        self.backend = backend
        self.errors = []
        self.context = env.browser.new_context(viewport={"width": 320, "height": 700}, timezone_id=TZ,
                                               locale=lang)
        config = {"displayLanguage": lang, "doc": doc}
        if url is not None:
            config["url"] = url
        self.context.add_init_script("window.__officeMockConfig = %s;" % json.dumps(config))
        mock_js = (HERE / "office_mock.js").read_text()
        self.context.route(OFFICE_JS, lambda route: route.fulfill(
            status=200, content_type="application/javascript", body=mock_js))
        self.context.route(API + "/**", backend.handle)
        self.page = self.context.new_page()
        self.page.on("pageerror", lambda e: self.errors.append("pageerror: %s" % e))
        # Failed HTTP requests are logged by the browser; the tests provoke some on purpose.
        self.page.on("console", lambda m: m.type == "error" and not m.text.startswith("Failed to load resource")
                     and self.errors.append("console: " + m.text))
        self.page.goto("http://127.0.0.1:%d/taskpane.html" % env.port)

    def poke(self):
        """Make the pane poll now (it polls on becoming visible)."""
        self.page.evaluate("document.dispatchEvent(new Event('visibilitychange'))")

    def wait(self, condition, timeout=10, poke=True):
        if poke:
            self.poke()
        end = time.time() + timeout
        while time.time() < end:
            if condition():
                return
            self.page.wait_for_timeout(50)
        raise AssertionError("condition not met in %ss; status=%r errors=%r" % (timeout, self.text("#status"), self.errors))

    def text(self, selector):
        return self.page.inner_text(selector)

    def visible(self, selector):
        return self.page.is_visible(selector)

    def doc(self):
        return self.page.evaluate("__mock.export()")

    def mock(self, expr):
        return self.page.evaluate(expr)

    def table(self):
        """(header, rows, formats) of table Spables, or None."""
        d = self.doc()
        t = next((t for t in d["tables"] if t["name"] == "Spables"), None)
        if not t:
            return None
        sheet = next(s for s in d["sheets"] if s["name"] == t["sheet"])
        cell = lambda r, c: sheet["cells"].get("%d,%d" % (r, c), {"v": "", "f": "General"})
        grid = [[cell(t["row"] + r, t["col"] + c) for c in range(t["cols"])] for r in range(t["rows"] + 1)]
        return ([c["v"] for c in grid[0]], [[c["v"] for c in row] for row in grid[1:]],
                [[c["f"] for c in row] for row in grid[1:]], t, sheet)

    def shot(self, name):
        path = SHOTS / name
        self.page.screenshot(path=str(path))
        return path

    def close(self):
        USED.update(self.mock("__mock.used"))
        assert not self.backend.bad_headers, self.backend.bad_headers
        assert not self.errors, self.errors
        assert not self.mock("__mock.warnings"), self.mock("__mock.warnings")
        self.context.close()


def excel_serial(local_dt):
    return (local_dt - datetime(1899, 12, 30)).total_seconds() / 86400


CODE_RE = re.compile(r"^[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$")


# ---------------------------------------------------------------- scenarios

def test_first_open_shows_code_and_saves_settings(env):
    backend = Backend()
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    integ = backend.only()
    assert integ["label"] == "Bestellungen.xlsx", integ["label"]
    assert pane.text("#code") == integ["code"]
    assert pane.visible("#pair") and not pane.visible("#connected")
    assert "Einstellungen → Integrationen → Excel verbinden" in pane.text("#pair")
    assert pane.text("#pairTitle") == "Handy verbinden"
    settings = pane.doc()["settings"]
    assert settings["spablesPollToken"] == integ["token"]
    assert settings["spablesIntegrationId"] == integ["id"]
    assert settings["Office.AutoShowTaskpaneWithDocument"] is True
    pane.shot("pane-de-pairing.png")

    # Reopening the workbook reuses the stored integration.
    saved = pane.doc()
    pane.close()
    again = Pane(env, backend, doc=saved)
    again.wait(lambda: CODE_RE.match(again.text("#code")), poke=False)
    assert len(backend.integrations) == 1
    assert backend.count("POST", "/api/integration/excel/code") == 1  # fresh code for the reopened pane
    again.close()


def test_code_refreshed_before_expiry(env):
    backend = Backend()
    backend.code_ttl = 45  # inside the 60 s refresh margin
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    first = pane.text("#code")
    backend.code_ttl = 15 * 60
    pane.wait(lambda: pane.text("#code") != first)
    assert pane.text("#code") == backend.only()["code"]
    assert backend.count("POST", "/api/integration/excel/code") >= 1
    pane.close()


def test_pair_write_new_column_dedupe(env):
    backend = Backend()
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    code = pane.text("#code")
    push = backend.pair(" " + code.lower().replace("-", " ") + " ")
    pane.wait(lambda: pane.visible("#connected"))
    assert "1 Handy verbunden" in pane.text("#status")

    before = pane.doc()
    t1 = "2026-09-30T08:15:00Z"
    id1 = backend.push(push, {"Artikel": "Flansch DN50", "Menge": "20", "Kunde": "Firma Müller"}, created=t1)
    id2 = backend.push(push, {"Artikel": "Dichtung", "Kunde": "Meier", "Menge": "5"}, created="2026-09-30T08:16:00Z")
    pane.wait(lambda: not backend.only()["entries"])
    header, rows, formats, table, sheet = pane.table()
    assert header == ["Artikel", "Menge", "Kunde", "Eingang", "Spables-ID"], header
    assert table["sheet"] == "Spables" and (table["row"], table["col"]) == (0, 0)
    assert rows[0][:3] == ["Flansch DN50", 20, "Firma Müller"], rows[0]
    assert rows[1][:3] == ["Dichtung", 5, "Meier"], rows[1]
    assert abs(rows[0][3] - excel_serial(datetime(2026, 9, 30, 10, 15))) < 1e-6, rows[0][3]  # Berlin = UTC+2
    assert formats[0][3] == "dd.mm.yyyy hh:mm", formats[0][3]
    assert [r[4] for r in rows] == [id1, id2]
    after = pane.doc()
    assert (after["active"], after["selection"]) == (before["active"], before["selection"]), "selection changed"
    assert "2 Einträge übernommen" in pane.text("#status")
    pane.shot("pane-de-connected.png")

    # A new key adds a column before "Eingang"; tricky values stay text.
    id3 = backend.push(push, {"Artikel": "=HYPERLINK(\"http://x\")", "Liefertermin": "2026-10-01",
                               "Telefon": "0171234567"})
    pane.wait(lambda: not backend.only()["entries"])
    header, rows, formats, _, sheet = pane.table()
    assert header == ["Artikel", "Menge", "Kunde", "Liefertermin", "Telefon", "Eingang", "Spables-ID"], header
    assert rows[0][3] == "" and rows[0][6] == id1, rows[0]
    assert rows[2][0] == "=HYPERLINK(\"http://x\")" and formats[2][0] == "@"
    assert not any("formula" in c for c in sheet["cells"].values()), "a value became a formula"
    assert rows[2][3] == excel_serial(datetime(2026, 10, 1)) and formats[2][3] == "dd.mm.yyyy"
    assert rows[2][4] == "0171234567" and formats[2][4] == "@"
    assert rows[2][6] == id3

    # Ack fails: the entry is written, stays queued, and is not written twice.
    backend.fail_ack = 1
    acks = backend.count("POST", "/api/integration/entries/ack")
    id4 = backend.push(push, {"Artikel": "Schraube", "Menge": "100"})
    pane.wait(lambda: "Serverfehler: simulated ack failure" in pane.text("#status"))
    assert backend.count("POST", "/api/integration/entries/ack") == acks + 1
    assert len(pane.table()[1]) == 4 and backend.only()["entries"]
    pane.wait(lambda: not backend.only()["entries"])
    rows = pane.table()[1]
    assert [r[6] for r in rows].count(id4) == 1 and len(rows) == 4, rows
    pane.close()


def test_excel_error_means_no_ack(env):
    backend = Backend()
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    push = backend.pair(pane.text("#code"))
    pane.wait(lambda: pane.visible("#connected"))
    pane.mock("__mock.failNextSync = 'InvalidOperationInCellEditMode'")
    backend.push(push, {"Artikel": "Flansch"})
    pane.wait(lambda: "InvalidOperationInCellEditMode" in pane.text("#status"))
    assert backend.count("POST", "/api/integration/entries/ack") == 0 and backend.only()["entries"]
    pane.wait(lambda: not backend.only()["entries"])
    assert len(pane.table()[1]) == 1
    pane.close()


def test_401_creates_new_integration(env):
    backend = Backend()
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    old = backend.only()["token"]
    backend.integrations.clear()  # integration deleted on the server
    pane.wait(lambda: len(backend.integrations) == 1, timeout=15)
    new = backend.only()
    assert new["token"] != old
    pane.wait(lambda: pane.text("#code") == new["code"])
    assert pane.doc()["settings"]["spablesPollToken"] == new["token"]
    pane.close()


def test_more_phones_and_disconnect(env):
    backend = Backend()
    pane = Pane(env, backend)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    backend.pair(pane.text("#code"))
    pane.wait(lambda: pane.visible("#connected"))

    pane.page.click("#addPhone")
    pane.wait(lambda: pane.visible("#pair") and CODE_RE.match(pane.text("#code")), poke=False)
    assert pane.text("#pairTitle") == "Weiteres Handy verbinden" and pane.visible("#closePair")
    backend.pair(pane.text("#code"))
    pane.wait(lambda: pane.visible("#connected") and "2 Handys verbunden" in pane.text("#status"))

    pane.page.click("#disconnect")
    assert pane.text("#disconnect") == "Wirklich alle Handys trennen?"
    assert backend.count("DELETE", "/api/integration/devices") == 0
    pane.page.click("#disconnect")
    pane.wait(lambda: pane.visible("#pair") and CODE_RE.match(pane.text("#code")), poke=False)
    assert backend.count("DELETE", "/api/integration/devices") == 1
    assert not backend.only()["push_tokens"]
    pane.close()


def test_existing_sheet_keeps_user_data(env):
    doc = {"settings": {}, "active": "Tabelle1", "selection": "Tabelle1!B3",
           "sheets": [{"name": "Tabelle1", "cells": {}},
                      {"name": "Spables", "cells": {"0,0": {"v": "Notizen", "f": "General"},
                                                    "1,0": {"v": "bitte nicht löschen", "f": "General"}}}],
           "tables": []}
    backend = Backend()
    pane = Pane(env, backend, doc=doc)
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    push = backend.pair(pane.text("#code"))
    backend.push(push, {"Artikel": "Flansch"})
    pane.wait(lambda: pane.table() is not None and not backend.only()["entries"])
    header, rows, _, table, sheet = pane.table()
    assert (table["row"], header, rows[0][0]) == (3, ["Artikel", "Eingang", "Spables-ID"], "Flansch")
    assert sheet["cells"]["1,0"]["v"] == "bitte nicht löschen"
    assert pane.doc()["selection"] == "Tabelle1!B3"
    pane.close()


def test_english(env):
    backend = Backend()
    pane = Pane(env, backend, lang="en-US", url="")
    pane.wait(lambda: CODE_RE.match(pane.text("#code")), poke=False)
    assert backend.only()["label"] == "Excel"
    assert pane.text("#pairTitle") == "Connect your phone"
    assert "Settings → Integrations → Connect Excel" in pane.text("#pair")
    pane.shot("pane-en-pairing.png")
    push = backend.pair(pane.text("#code"))
    backend.push(push, {"Item": "Flange"}, created="2026-09-30T08:15:00Z")
    pane.wait(lambda: pane.visible("#connected") and not backend.only()["entries"])
    assert pane.text("#addPhone") == "Connect another phone"
    assert pane.text("#disconnect") == "Disconnect phones"
    assert "1 phone connected" in pane.text("#status") and "1 entry received" in pane.text("#status")
    assert pane.table()[2][0][1] == "yyyy-mm-dd hh:mm"
    pane.shot("pane-en-connected.png")
    pane.close()


def test_mock_rejects_unloaded_reads(env):
    """Sanity check of the mock itself: it must behave like Office.js."""
    backend = Backend()
    pane = Pane(env, backend)
    result = pane.page.evaluate("""() => Excel.run(async (ctx) => {
        const out = [];
        const r = ctx.workbook.worksheets.getItem("Tabelle1").getRange("A1:B1");
        try { r.values; out.push("no throw"); } catch (e) { out.push(e.code); }
        const t = ctx.workbook.tables.getItemOrNullObject("nope");
        try { t.isNullObject; out.push("no throw"); } catch (e) { out.push(e.code); }
        r.load("values");
        await ctx.sync();
        out.push(JSON.stringify(r.values), String(t.isNullObject));
        try { r.values = [["only one"]]; await ctx.sync(); } catch (e) { out.push(e.code); }
        return out;
    })""")
    assert result == ["PropertyNotLoaded", "PropertyNotLoaded", '[["",""]]', "true", "InvalidArgument"], result
    pane.close()


# ---------------------------------------------------------------- runner

class Env:
    def __init__(self, browser, port):
        self.browser = browser
        self.port = port


def _launch(p):
    path = os.environ.get("CHROME_PATH")
    return p.chromium.launch(executable_path=path) if path else p.chromium.launch()


try:
    import pytest

    @pytest.fixture(scope="module")
    def env():
        server = start_server()
        with sync_playwright() as p:
            browser = _launch(p)
            yield Env(browser, server.server_address[1])
            browser.close()
        server.shutdown()
except ImportError:
    pass


def main():
    server = start_server()
    tests = [(n, f) for n, f in globals().items() if n.startswith("test_") and callable(f)]
    failed = 0
    with sync_playwright() as p:
        browser = _launch(p)
        env = Env(browser, server.server_address[1])
        for name, fn in tests:
            start = time.time()
            try:
                fn(env)
                print("PASS %-50s %.1fs" % (name, time.time() - start))
            except Exception:
                failed += 1
                print("FAIL " + name)
                traceback.print_exc()
        browser.close()
    server.shutdown()
    print("Excel API members used (requirement set):")
    for member, api_set in sorted(USED.items()):
        print("  ExcelApi %s  %s" % (api_set, member))
    print("screenshots:", SHOTS)
    print("%d passed, %d failed" % (len(tests) - failed, failed))
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
