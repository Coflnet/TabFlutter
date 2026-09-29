/* Spables Excel add-in task pane. Plain ES2017, no build step.
 * Pairs the workbook with phones through a pairing code, polls the queued
 * entries and appends them to the table "Spables". Contract: see §2 and §3 of
 * the Spables Excel sync contract. Needs ExcelApi 1.4. */
(function () {
  "use strict";

  const isLocal = /^(localhost|127\.0\.0\.1)$/.test(location.hostname);
  const API = (isLocal && new URLSearchParams(location.search).get("api")) || "https://tab.coflnet.com";

  const SHEET = "Spables";
  const TABLE = "Spables";
  const RECEIVED = "Eingang";
  const ID_COL = "Spables-ID";
  const KEY_TOKEN = "spablesPollToken";
  const KEY_ID = "spablesIntegrationId";
  const POLL_VISIBLE = 5000;
  const POLL_HIDDEN = 30000;
  const STATUS_EVERY = 60000;   // refresh the phone count this often once paired
  const CODE_MARGIN = 60000;    // fetch a new code this long before expiry
  const MAX_ENTRIES = 100;      // the server returns at most this many per poll

  const STRINGS = {
    de: {
      loading: "Verbinde mit Spables …",
      pairTitle: "Handy verbinden",
      pairTitleMore: "Weiteres Handy verbinden",
      step1: "Spables-App auf dem Handy öffnen",
      step2: "Einstellungen → Integrationen → Excel verbinden",
      step3: "Diesen Code eingeben:",
      codeHint: (t) => "Gültig bis " + t + ". Danach erscheint automatisch ein neuer Code.",
      close: "Schließen",
      connectedTitle: "Verbunden",
      connectedText: "Neue Einträge aus der Spables-App erscheinen als Zeilen in der Tabelle „Spables“ auf dem Blatt „Spables“. Dieser Bereich muss dafür geöffnet sein.",
      addPhone: "Weiteres Handy verbinden",
      disconnect: "Handys trennen",
      confirmDisconnect: "Wirklich alle Handys trennen?",
      devices: (n) => (n === 1 ? "1 Handy verbunden" : n + " Handys verbunden"),
      lastSync: (t) => "Letzter Abgleich " + t,
      written: (n) => n + (n === 1 ? " Eintrag" : " Einträge") + " übernommen",
      reconnecting: "Die Verbindung wurde entfernt. Es wird ein neuer Code erstellt.",
      errNetwork: "Server nicht erreichbar. Neuer Versuch läuft automatisch.",
      errExcel: (m) => "Excel konnte nicht schreiben (" + m + "). Neuer Versuch läuft automatisch.",
      errServer: (m) => "Serverfehler: " + m,
      errHost: "Bitte in Excel öffnen.",
      errApi: "Diese Excel-Version wird nicht unterstützt (ExcelApi 1.4 nötig).",
    },
    en: {
      loading: "Connecting to Spables …",
      pairTitle: "Connect your phone",
      pairTitleMore: "Connect another phone",
      step1: "Open the Spables app on your phone",
      step2: "Settings → Integrations → Connect Excel",
      step3: "Enter this code:",
      codeHint: (t) => "Valid until " + t + ". A new code appears automatically after that.",
      close: "Close",
      connectedTitle: "Connected",
      connectedText: "New entries from the Spables app appear as rows in the table “Spables” on the sheet “Spables”. This pane has to be open for that.",
      addPhone: "Connect another phone",
      disconnect: "Disconnect phones",
      confirmDisconnect: "Really disconnect all phones?",
      devices: (n) => (n === 1 ? "1 phone connected" : n + " phones connected"),
      lastSync: (t) => "Last sync " + t,
      written: (n) => n + (n === 1 ? " entry" : " entries") + " received",
      reconnecting: "The connection was removed. Creating a new code.",
      errNetwork: "Server not reachable. Retrying automatically.",
      errExcel: (m) => "Excel could not write (" + m + "). Retrying automatically.",
      errServer: (m) => "Server error: " + m,
      errHost: "Please open this in Excel.",
      errApi: "This Excel version is not supported (needs ExcelApi 1.4).",
    },
  };

  let lang = "en";
  let t = STRINGS.en;

  const state = {
    token: null,
    devices: null,        // null = unknown yet
    lastStatus: 0,
    code: null,
    codeExpires: 0,
    moreCode: false,      // user asked to connect another phone
    devicesAtCode: 0,
    lastSync: null,
    written: 0,
    error: null,
    notice: null,
    busy: false,
    again: false,
    timer: null,
  };

  const $ = (id) => document.getElementById(id);

  class AuthError extends Error {}
  class ServerError extends Error {}

  // ---------- backend ----------

  async function api(method, path, body) {
    const headers = {};
    if (state.token) headers["X-Integration-Token"] = state.token;
    if (body !== undefined) headers["Content-Type"] = "application/json";
    const res = await fetch(API + path, {
      method: method,
      headers: headers,
      body: body === undefined ? undefined : JSON.stringify(body),
      cache: "no-store",
    });
    if (res.status === 401 && state.token) throw new AuthError("401");
    const text = await res.text();
    let json = null;
    try { json = text ? JSON.parse(text) : null; } catch (e) { /* not JSON */ }
    if (!res.ok) throw new ServerError((json && json.error) || "HTTP " + res.status);
    return json;
  }

  function settings() { return Office.context.document.settings; }

  function saveSettings() {
    // In desktop Excel the settings are written to the file on the next save.
    return new Promise((resolve) => settings().saveAsync(() => resolve()));
  }

  function workbookLabel() {
    const url = Office.context.document.url || "";
    const name = url.split(/[\\/]/).pop();
    try { return decodeURIComponent(name) || "Excel"; } catch (e) { return name || "Excel"; }
  }

  async function createIntegration() {
    const r = await api("POST", "/api/integration/excel", { label: workbookLabel() });
    state.token = r.pollToken;
    settings().set(KEY_TOKEN, r.pollToken);
    settings().set(KEY_ID, r.integrationId);
    settings().set("Office.AutoShowTaskpaneWithDocument", true);
    await saveSettings();
    state.devices = 0;
    state.lastStatus = Date.now();
    setCode(r);
  }

  async function forgetIntegration() {
    settings().remove(KEY_TOKEN);
    settings().remove(KEY_ID);
    await saveSettings();
    Object.assign(state, { token: null, devices: null, code: null, codeExpires: 0, moreCode: false });
  }

  function setCode(r) {
    state.code = r.pairingCode;
    state.codeExpires = Date.parse(r.pairingExpiresAt) || Date.now() + 15 * 60000;
  }

  async function refreshStatus() {
    const s = await api("GET", "/api/integration/status");
    if (state.devices !== null && s.devices > state.devices) state.code = null; // code was used
    if (state.moreCode && s.devices > state.devicesAtCode) state.moreCode = false;
    state.devices = s.devices;
    state.lastStatus = Date.now();
  }

  const needsCode = () => state.devices === 0 || state.moreCode;

  // ---------- Excel ----------

  function colName(i) {
    let s = "";
    for (i += 1; i > 0; i = Math.floor((i - 1) / 26)) s = String.fromCharCode(65 + ((i - 1) % 26)) + s;
    return s;
  }

  function address(row, col, rows, cols) {
    return colName(col) + (row + 1) + ":" + colName(col + cols - 1) + (row + rows);
  }

  const norm = (s) => String(s).trim().toLowerCase();

  // Excel serial date in local time (days since 1899-12-30).
  function excelDate(ms) {
    return (ms - new Date(ms).getTimezoneOffset() * 60000) / 86400000 + 25569;
  }

  const dateFormat = () => (lang === "de" ? "dd.mm.yyyy" : "yyyy-mm-dd");
  const dateTimeFormat = () => dateFormat() + " hh:mm";

  // Plain numbers (up to 10 integer digits, longer ones are ids or phone
  // numbers) become numbers, ISO dates become dates, everything else is text
  // ("@"), so Excel never turns a value into a formula or drops leading zeros.
  function cell(value) {
    if (typeof value === "number" || typeof value === "boolean") return [value, "General"];
    const s = value == null ? "" : typeof value === "object" ? JSON.stringify(value) : String(value);
    if (/^-?(0|[1-9]\d{0,9})(\.\d+)?$/.test(s)) return [Number(s), "General"];
    const d = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
    if (d) {
      const ms = Date.UTC(+d[1], +d[2] - 1, +d[3]);
      if (!isNaN(ms) && new Date(ms).getUTCDate() === +d[3]) return [ms / 86400000 + 25569, dateFormat()];
    }
    return [s, "@"];
  }

  // Header = data keys in first-seen order, then Eingang and Spables-ID.
  function wantedColumns(entries) {
    const cols = [];
    const seen = new Set([norm(RECEIVED), norm(ID_COL)]);
    for (const e of entries) {
      for (const k of Object.keys(e.data || {})) {
        if (k.trim() && !seen.has(norm(k))) { seen.add(norm(k)); cols.push(k.trim()); }
      }
    }
    return cols.concat([RECEIVED, ID_COL]);
  }

  // One values row and one numberFormat row per entry. null = leave the cell
  // alone (keeps formulas of calculated columns the user added).
  function toRows(entries, header) {
    const index = new Map(header.map((h, i) => [norm(h), i]));
    const values = [];
    const formats = [];
    for (const e of entries) {
      const v = header.map(() => null);
      const f = header.map(() => null);
      for (const k of Object.keys(e.data || {})) {
        const i = index.get(norm(k));
        if (i === undefined || norm(k) === norm(RECEIVED) || norm(k) === norm(ID_COL)) continue;
        [v[i], f[i]] = cell(e.data[k]);
      }
      const r = index.get(norm(RECEIVED));
      v[r] = excelDate(Date.parse(e.createdAt) || Date.now());
      f[r] = dateTimeFormat();
      const id = index.get(norm(ID_COL));
      v[id] = e.entryId;
      f[id] = "@";
      values.push(v);
      formats.push(f);
    }
    return { values: values, formats: formats };
  }

  // Appends the entries to the table and returns how many rows were added.
  // Never activates a sheet or changes the selection.
  function writeEntries(entries) {
    return Excel.run(async (ctx) => {
      const wb = ctx.workbook;
      const wanted = wantedColumns(entries);
      const table = wb.tables.getItemOrNullObject(TABLE);
      await ctx.sync();

      if (table.isNullObject) {
        const unique = entries.filter((e, i) => entries.findIndex((x) => x.entryId === e.entryId) === i);
        await createTable(ctx, wanted, unique);
        return unique.length;
      }

      // Add missing columns: data keys before "Eingang", meta columns at the end.
      const headerRange = table.getHeaderRowRange().load("values");
      await ctx.sync();
      const header = headerRange.values[0].map(String);
      const has = new Set(header.map(norm));
      let pos = header.findIndex((h) => norm(h) === norm(RECEIVED));
      for (const name of wanted) {
        if (has.has(norm(name))) continue;
        const append = name === RECEIVED || name === ID_COL || pos < 0;
        const at = append ? header.length : pos++;
        table.columns.add(append ? null : at, null, name); // null appends (ExcelApi 1.4)
        header.splice(at, 0, name);
        has.add(norm(name));
      }

      // Dedupe against the IDs already in the table.
      const idRange = table.columns.getItemAt(header.findIndex((h) => norm(h) === norm(ID_COL)))
        .getDataBodyRange().load("values");
      await ctx.sync();
      const known = new Set(idRange.values.map((r) => String(r[0])));
      const fresh = entries.filter((e) => !known.has(e.entryId) && known.add(e.entryId));
      if (!fresh.length) return 0;

      const rows = toRows(fresh, header);
      for (let i = 0; i < fresh.length; i++) table.rows.add(null);
      const last = table.getDataBodyRange().getLastRow();
      const target = last.getOffsetRange(1 - fresh.length, 0).getBoundingRect(last);
      target.numberFormat = rows.formats;
      target.values = rows.values;
      await ctx.sync();
      return fresh.length;
    });
  }

  async function createTable(ctx, header, entries) {
    const wb = ctx.workbook;
    let sheet = wb.worksheets.getItemOrNullObject(SHEET);
    await ctx.sync();
    let startRow = 0;
    if (sheet.isNullObject) {
      sheet = wb.worksheets.add(SHEET); // does not activate the new sheet
    } else {
      // The sheet exists without our table: start below the user's data.
      const used = sheet.getUsedRangeOrNullObject(true).load("rowIndex,rowCount");
      await ctx.sync();
      if (!used.isNullObject) startRow = used.rowIndex + used.rowCount + 1;
    }
    const rows = toRows(entries, header);
    const range = sheet.getRange(address(startRow, 0, entries.length + 1, header.length));
    range.numberFormat = [header.map(() => "@")].concat(rows.formats);
    range.values = [header].concat(rows.values);
    const table = sheet.tables.add(range, true);
    table.name = TABLE;
    table.getRange().format.autofitColumns();
    await ctx.sync();
  }

  // ---------- loop ----------

  function schedule(delay) {
    clearTimeout(state.timer);
    if (delay == null) delay = document.hidden ? POLL_HIDDEN : POLL_VISIBLE;
    state.timer = setTimeout(tick, delay);
  }

  async function tick() {
    if (state.busy) { state.again = true; return; }
    clearTimeout(state.timer);
    state.busy = true;
    state.again = false;
    let delay = null;
    try {
      if (!state.token) await createIntegration();
      if (state.devices === null || needsCode() || Date.now() - state.lastStatus > STATUS_EVERY) await refreshStatus();
      if (needsCode() && (!state.code || state.codeExpires - Date.now() < CODE_MARGIN)) await newCode();
      render();

      const entries = await api("GET", "/api/integration/entries");
      if (entries.length) {
        state.written += await writeEntries(entries);
        await api("POST", "/api/integration/entries/ack", { entryIds: entries.map((e) => e.entryId) });
        if (entries.length >= MAX_ENTRIES) delay = 0;
      }
      state.lastSync = new Date();
      state.error = null;
      state.notice = null;
    } catch (e) {
      if (e instanceof AuthError) {
        // The integration is gone: start over with a new one and a new code.
        await forgetIntegration();
        state.notice = t.reconnecting;
        state.error = null;
      } else {
        state.error = describe(e);
      }
    } finally {
      state.busy = false;
      render();
      schedule(state.again ? 0 : delay);
    }
  }

  async function newCode() {
    setCode(await api("POST", "/api/integration/excel/code"));
  }

  function describe(e) {
    if (e instanceof ServerError) return t.errServer(e.message);
    if (e instanceof TypeError) return t.errNetwork; // fetch network failure
    if (typeof OfficeExtension !== "undefined" && e instanceof OfficeExtension.Error) return t.errExcel(e.code);
    return t.errServer(e && e.message ? e.message : String(e));
  }

  // ---------- UI ----------

  function time(d) {
    return d.toLocaleTimeString(lang, { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  }

  function render() {
    const known = state.devices !== null && !(needsCode() && !state.code);
    $("loading").hidden = known;
    $("pair").hidden = !known || !needsCode();
    $("connected").hidden = !known || needsCode();
    if (known && needsCode()) {
      $("pairTitle").textContent = state.moreCode && state.devices > 0 ? t.pairTitleMore : t.pairTitle;
      $("code").textContent = state.code;
      $("codeHint").textContent = t.codeHint(new Date(state.codeExpires).toLocaleTimeString(lang, { hour: "2-digit", minute: "2-digit" }));
      $("closePair").hidden = !(state.moreCode && state.devices > 0);
    }

    const status = $("status");
    status.textContent = "";
    const parts = [];
    if (state.devices) parts.push(t.devices(state.devices));
    if (state.lastSync) parts.push(t.lastSync(time(state.lastSync)));
    if (state.written) parts.push(t.written(state.written));
    status.append(parts.join(" · "));
    for (const msg of [state.notice, state.error]) {
      if (!msg) continue;
      const span = document.createElement("span");
      span.className = "error";
      span.textContent = msg;
      status.append(span);
    }
  }

  function applyStrings() {
    document.documentElement.lang = lang;
    for (const el of document.querySelectorAll("[data-i18n]")) el.textContent = t[el.dataset.i18n];
  }

  function fatal(msg) {
    $("loading").textContent = msg;
  }

  async function onAddPhone() {
    state.moreCode = true;
    state.devicesAtCode = state.devices || 0;
    try {
      await newCode();
      state.error = null;
    } catch (e) {
      state.moreCode = false;
      if (e instanceof AuthError) { await forgetIntegration(); state.notice = t.reconnecting; tick(); }
      else state.error = describe(e);
    }
    render();
  }

  let confirmTimer = null;
  async function onDisconnect() {
    const btn = $("disconnect");
    if (!confirmTimer) {
      // Two-step confirm: window.confirm() is blocked inside Office add-ins.
      btn.textContent = t.confirmDisconnect;
      btn.classList.add("danger");
      confirmTimer = setTimeout(resetDisconnect, 5000);
      return;
    }
    resetDisconnect();
    btn.disabled = true;
    try {
      await api("DELETE", "/api/integration/devices");
      state.devices = 0;
      state.code = null;
      state.error = null;
    } catch (e) {
      if (e instanceof AuthError) { await forgetIntegration(); state.notice = t.reconnecting; }
      else state.error = describe(e);
    }
    btn.disabled = false;
    render();
    tick();
  }

  function resetDisconnect() {
    clearTimeout(confirmTimer);
    confirmTimer = null;
    $("disconnect").textContent = t.disconnect;
    $("disconnect").classList.remove("danger");
  }

  Office.onReady(function (info) {
    lang = /^de/i.test(Office.context.displayLanguage || "") ? "de" : "en";
    t = STRINGS[lang];
    applyStrings();
    if (info.host !== Office.HostType.Excel) return fatal(t.errHost);
    if (!Office.context.requirements.isSetSupported("ExcelApi", "1.4")) return fatal(t.errApi);

    state.token = settings().get(KEY_TOKEN) || null;
    if (state.token && settings().get("Office.AutoShowTaskpaneWithDocument") !== true) {
      settings().set("Office.AutoShowTaskpaneWithDocument", true);
      saveSettings();
    }
    $("addPhone").addEventListener("click", onAddPhone);
    $("disconnect").addEventListener("click", onDisconnect);
    $("closePair").addEventListener("click", () => { state.moreCode = false; render(); });
    document.addEventListener("visibilitychange", () => (document.hidden ? schedule() : tick()));
    render();
    tick();
  });
})();
