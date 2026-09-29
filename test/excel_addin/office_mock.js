/* In-memory mock of the parts of Office.js / Excel JS API used by
 * web/excel/taskpane.js. Served in place of
 * https://appsforoffice.microsoft.com/lib/1/hosted/office.js by the Playwright
 * harness (test_taskpane.py).
 *
 * Modelled after the real API's batching model:
 * - Every call on a proxy object is queued and only runs on context.sync().
 * - Proxies are resolved in queue order (a range taken after rows.add sees
 *   the added rows).
 * - Reading a property that was not load()ed and synced throws
 *   PropertyNotLoaded; reading isNullObject before sync throws too.
 * - Calls on a null object fail the sync with ItemNotFound.
 * - null inside a 2D values/numberFormat array leaves that cell unchanged.
 * - Writing a string into a non-text cell is parsed like typed input
 *   ("=..." becomes a formula, numeric text becomes a number); cells with
 *   number format "@" keep the string.
 * - worksheets.add() does not activate the new sheet.
 * Only members of ExcelApi <= 1.4 exist; anything else is a TypeError. Every
 * used member is recorded with its requirement set in __mock.used.
 */
(function () {
  "use strict";
  const cfg = window.__officeMockConfig || {};
  const doc = cfg.doc || {
    settings: {},
    sheets: [{ name: "Tabelle1", cells: {} }],
    tables: [],
    active: "Tabelle1",
    selection: "Tabelle1!A1",
  };
  const liveSettings = Object.assign({}, doc.settings);
  const mock = (window.__mock = {
    doc: doc,
    used: {},
    warnings: [],
    failNextSync: null, // set to an error code to make the next sync fail
    export: () => JSON.parse(JSON.stringify(doc)),
  });

  class OfficeError extends Error {
    constructor(code, message) {
      super(message || code);
      this.name = "RichApi.Error";
      this.code = code;
      this.debugInfo = { code: code, message: message };
    }
  }
  window.OfficeExtension = { Error: OfficeError, ErrorCodes: {} };

  const use = (member, set) => { mock.used[member] = set; };

  // ---------- data model ----------
  const sheetByName = (n) => doc.sheets.find((s) => s.name.toLowerCase() === String(n).toLowerCase()) || null;
  const key = (r, c) => r + "," + c;
  const getCell = (sheet, r, c) => sheet.cells[key(r, c)] || { v: "", f: "General" };

  function writeValue(sheet, r, c, value) {
    if (value === null || value === undefined) return; // null = unchanged
    const cell = Object.assign({}, getCell(sheet, r, c));
    delete cell.formula;
    if (typeof value === "string" && cell.f !== "@") {
      if (/^[=+\-]/.test(value) && !/^[+\-]?\d+(\.\d+)?$/.test(value)) {
        cell.formula = value;
        cell.v = "#FORMULA";
      } else if (/^[+\-]?\d+(\.\d+)?$/.test(value)) {
        cell.v = Number(value);
      } else {
        cell.v = value;
      }
    } else {
      cell.v = value;
    }
    sheet.cells[key(r, c)] = cell;
  }

  function writeFormat(sheet, r, c, f) {
    if (f === null || f === undefined) return;
    sheet.cells[key(r, c)] = Object.assign({}, getCell(sheet, r, c), { f: f });
  }

  function colName(i) {
    let s = "";
    for (i += 1; i > 0; i = Math.floor((i - 1) / 26)) s = String.fromCharCode(65 + ((i - 1) % 26)) + s;
    return s;
  }
  function colIndex(letters) {
    let n = 0;
    for (const ch of letters.toUpperCase()) n = n * 26 + ch.charCodeAt(0) - 64;
    return n - 1;
  }
  function parseAddress(sheet, address) {
    let a = address;
    if (a.includes("!")) {
      const parts = a.split("!");
      sheet = sheetByName(parts[0].replace(/'/g, ""));
      a = parts[1];
    }
    const m = /^([A-Z]+)(\d+)(?::([A-Z]+)(\d+))?$/i.exec(a);
    if (!m || !sheet) throw new OfficeError("InvalidArgument", "Bad address " + address);
    const r0 = +m[2] - 1, c0 = colIndex(m[1]);
    const r1 = m[3] ? +m[4] - 1 : r0, c1 = m[3] ? colIndex(m[3]) : c0;
    return { sheet: sheet, r: Math.min(r0, r1), c: Math.min(c0, c1), h: Math.abs(r1 - r0) + 1, w: Math.abs(c1 - c0) + 1 };
  }
  const rectAddress = (x) => x.sheet.name + "!" + colName(x.c) + (x.r + 1) + ":" + colName(x.c + x.w - 1) + (x.r + x.h);

  const tableSheet = (t) => sheetByName(t.sheet);
  const tableRect = (t) => ({ sheet: tableSheet(t), r: t.row, c: t.col, h: t.rows + 1, w: t.cols });
  const headerRect = (t) => ({ sheet: tableSheet(t), r: t.row, c: t.col, h: 1, w: t.cols });
  const bodyRect = (t) => ({ sheet: tableSheet(t), r: t.row + 1, c: t.col, h: t.rows, w: t.cols });
  const tableByName = (n) => doc.tables.find((t) => t.name.toLowerCase() === String(n).toLowerCase()) || null;
  const overlaps = (a, b) => a.sheet === b.sheet && a.r < b.r + b.h && b.r < a.r + a.h && a.c < b.c + b.w && b.c < a.c + a.w;

  function headerNames(t) {
    const sheet = tableSheet(t);
    const names = [];
    for (let i = 0; i < t.cols; i++) names.push(String(getCell(sheet, t.row, t.col + i).v));
    return names;
  }

  function uniqueHeader(t, name) {
    const taken = new Set(headerNames(t).map((h) => h.toLowerCase()));
    if (!taken.has(name.toLowerCase())) return name;
    for (let i = 2; ; i++) if (!taken.has((name + i).toLowerCase())) return name + i;
  }

  // Shift cells of one sheet: rows >= fromRow in columns [c0, c1] down by n,
  // or columns >= fromCol in rows [r0, r1] right by n.
  function shiftDown(sheet, fromRow, c0, c1, n) {
    const moved = {};
    for (const k of Object.keys(sheet.cells)) {
      const [r, c] = k.split(",").map(Number);
      if (r >= fromRow && c >= c0 && c <= c1) moved[key(r + n, c)] = sheet.cells[k];
      else moved[k] = moved[k] || sheet.cells[k];
    }
    sheet.cells = moved;
  }
  function shiftRight(sheet, fromCol, r0, r1, n) {
    const moved = {};
    for (const k of Object.keys(sheet.cells)) {
      const [r, c] = k.split(",").map(Number);
      if (c >= fromCol && r >= r0 && r <= r1) moved[key(r, c + n)] = sheet.cells[k];
      else moved[k] = moved[k] || sheet.cells[k];
    }
    sheet.cells = moved;
  }

  function check2D(arr, h, w, what) {
    if (!Array.isArray(arr) || arr.length !== h || arr.some((row) => !Array.isArray(row) || row.length !== w)) {
      throw new OfficeError("InvalidArgument",
        "The number of rows or columns in the input array doesn't match the size or dimensions of the range (" +
        what + ": expected " + h + "x" + w + ").");
    }
  }

  // ---------- proxy plumbing ----------
  class RequestContext {
    constructor() {
      this.queue = [];
      this.workbook = new Workbook(this);
    }
    push(fn, write) {
      this.queue.push({ fn: fn, write: !!write });
    }
    sync() {
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          const q = this.queue;
          this.queue = [];
          try {
            if (mock.failNextSync) {
              const code = mock.failNextSync;
              mock.failNextSync = null;
              throw new OfficeError(code, "Simulated " + code);
            }
            for (const op of q) op.fn();
            resolve();
          } catch (e) {
            reject(e);
          }
        }, 1);
      });
    }
  }

  const NOT_LOADED = (p) => new OfficeError("PropertyNotLoaded",
    "The property '" + p + "' is not available. Before reading the property's value, call the load method on the containing object and call \"context.sync()\" on the associated request context.");

  class Proxy {
    constructor(ctx, resolver) {
      this._ctx = ctx;
      this._state = "pending"; // pending | resolved | null
      this._value = undefined;
      this._loaded = {};
      ctx.push(() => {
        const v = resolver(); // null = *OrNullObject miss; a throw fails the sync
        this._value = v;
        this._state = v === null ? "null" : "resolved";
      });
    }
    _r() {
      if (this._state === "null") throw new OfficeError("ItemNotFound", "The requested resource doesn't exist.");
      return this._value;
    }
    _op(fn, write) {
      this._ctx.push(() => fn(this._r()), write);
    }
    _prop(p) {
      if (!(p in this._loaded)) throw NOT_LOADED(p);
      return this._loaded[p];
    }
    load(props) {
      const list = typeof props === "string" ? props.split(",").map((s) => s.trim()) : props;
      this._op((v) => { for (const p of list) this._loaded[p] = this._read(p, v); });
      return this;
    }
    get isNullObject() {
      if (this._state === "pending") throw NOT_LOADED("isNullObject");
      return this._state === "null";
    }
  }
  // Proxies derived from a parent: a null parent fails the sync with ItemNotFound.
  const strict = (parent, fn) => () => fn(parent._r());

  class Workbook {
    constructor(ctx) {
      this.worksheets = new WorksheetCollection(ctx);
      this.tables = new TableCollection(ctx, null);
    }
  }

  class WorksheetCollection {
    constructor(ctx) { this._ctx = ctx; }
    getItem(name) {
      use("WorksheetCollection.getItem", "1.1");
      return new Worksheet(this._ctx, () => {
        const s = sheetByName(name);
        if (!s) throw new OfficeError("ItemNotFound", "Sheet " + name);
        return s;
      }, true);
    }
    getItemOrNullObject(name) {
      use("WorksheetCollection.getItemOrNullObject", "1.4");
      return new Worksheet(this._ctx, () => sheetByName(name));
    }
    add(name) {
      use("WorksheetCollection.add", "1.1");
      return new Worksheet(this._ctx, () => {
        if (sheetByName(name)) throw new OfficeError("ItemAlreadyExists", "Sheet " + name + " exists");
        const s = { name: name || "Sheet" + (doc.sheets.length + 1), cells: {} };
        doc.sheets.push(s);
        return s;
      });
    }
  }

  class Worksheet extends Proxy {
    constructor(ctx, resolver) {
      super(ctx, resolver);
      this.tables = new TableCollection(ctx, this);
    }
    _read(p, s) {
      if (p === "name") return s.name;
      throw new TypeError("mock: Worksheet." + p + " not implemented");
    }
    get name() { return this._prop("name"); }
    getRange(address) {
      use("Worksheet.getRange", "1.1");
      return new Range(this._ctx, strict(this, (s) => parseAddress(s, address)));
    }
    getUsedRangeOrNullObject(valuesOnly) {
      use("Worksheet.getUsedRangeOrNullObject", "1.4");
      return new Range(this._ctx, strict(this, (s) => {
        let r0 = Infinity, c0 = Infinity, r1 = -1, c1 = -1;
        for (const k of Object.keys(s.cells)) {
          const cell = s.cells[k];
          if (valuesOnly && (cell.v === "" || cell.v === null)) continue;
          const [r, c] = k.split(",").map(Number);
          r0 = Math.min(r0, r); c0 = Math.min(c0, c); r1 = Math.max(r1, r); c1 = Math.max(c1, c);
        }
        return r1 < 0 ? null : { sheet: s, r: r0, c: c0, h: r1 - r0 + 1, w: c1 - c0 + 1 };
      }));
    }
    activate() {
      use("Worksheet.activate", "1.1");
      this._op((s) => { doc.active = s.name; }, true);
    }
  }

  class TableCollection {
    constructor(ctx, sheet) { this._ctx = ctx; this._sheet = sheet; }
    getItem(name) {
      use("TableCollection.getItem", "1.1");
      return new Table(this._ctx, () => {
        const t = tableByName(name);
        if (!t) throw new OfficeError("ItemNotFound", "Table " + name);
        return t;
      });
    }
    getItemOrNullObject(name) {
      use("TableCollection.getItemOrNullObject", "1.4");
      return new Table(this._ctx, () => tableByName(name));
    }
    add(address, hasHeaders) {
      use("TableCollection.add", "1.1");
      if (!hasHeaders) throw new TypeError("mock: tables.add without headers not implemented");
      const addressProxy = typeof address === "string" ? null : address;
      const sheetProxy = this._sheet;
      return new Table(this._ctx, () => {
        const rect = addressProxy ? addressProxy._r() : parseAddress(sheetProxy ? sheetProxy._r() : null, address);
        if (doc.tables.some((t) => overlaps(tableRect(t), rect))) throw new OfficeError("InvalidOperation", "Tables can't overlap other tables.");
        const t = { name: "Table" + (doc.tables.length + 1), sheet: rect.sheet.name, row: rect.r, col: rect.c, cols: rect.w, rows: Math.max(1, rect.h - 1) };
        const names = new Set();
        for (let i = 0; i < t.cols; i++) {
          let h = String(getCell(rect.sheet, t.row, t.col + i).v);
          if (!h) h = "Column" + (i + 1);
          if (names.has(h.toLowerCase())) throw new Error("mock: duplicate header " + h);
          names.add(h.toLowerCase());
          writeValue(rect.sheet, t.row, t.col + i, h);
        }
        doc.tables.push(t);
        return t;
      });
    }
  }

  class Table extends Proxy {
    constructor(ctx, resolver) {
      super(ctx, resolver);
      this.columns = new TableColumnCollection(ctx, this);
      this.rows = new TableRowCollection(ctx, this);
    }
    _read(p, t) {
      if (p === "name") return t.name;
      throw new TypeError("mock: Table." + p + " not implemented");
    }
    get name() { return this._prop("name"); }
    set name(v) {
      use("Table.name (set)", "1.1");
      this._op((t) => {
        if (doc.tables.some((o) => o !== t && o.name.toLowerCase() === v.toLowerCase())) throw new OfficeError("InvalidArgument", "Table name taken");
        t.name = v;
      }, true);
    }
    getRange() { use("Table.getRange", "1.1"); return new Range(this._ctx, strict(this, tableRect)); }
    getHeaderRowRange() { use("Table.getHeaderRowRange", "1.1"); return new Range(this._ctx, strict(this, headerRect)); }
    getDataBodyRange() { use("Table.getDataBodyRange", "1.1"); return new Range(this._ctx, strict(this, bodyRect)); }
  }

  class TableColumnCollection {
    constructor(ctx, table) { this._ctx = ctx; this._table = table; }
    getItemAt(i) {
      use("TableColumnCollection.getItemAt", "1.1");
      return new TableColumn(this._ctx, strict(this._table, (t) => {
        if (i < 0 || i >= t.cols) throw new OfficeError("InvalidArgument", "column index");
        return { t: t, i: i };
      }));
    }
    add(index, values, name) {
      use("TableColumnCollection.add", index == null || name !== undefined ? "1.4" : "1.1");
      const table = this._table;
      return new TableColumn(this._ctx, strict(table, (t) => {
        const append = index === null || index === undefined || index === -1;
        if (!append && (index < 0 || index > t.cols - 1)) {
          throw new OfficeError("InvalidArgument", "The index value should be equal to or less than the last column's index value.");
        }
        const sheet = tableSheet(t);
        const at = append ? t.cols : index;
        shiftRight(sheet, t.col + at, t.row, t.row + t.rows, 1);
        if (values !== null && values !== undefined) check2D(values, t.rows + 1, 1, "columns.add values");
        const header = uniqueHeader(t, name || (values ? String(values[0][0]) : "Column" + (t.cols + 1)));
        t.cols++;
        writeValue(sheet, t.row, t.col + at, header);
        for (let r = 1; r <= t.rows; r++) {
          sheet.cells[key(t.row + r, t.col + at)] = { v: "", f: getCell(sheet, t.row + r, t.col + (at > 0 ? at - 1 : at + 1)).f };
          if (values) writeValue(sheet, t.row + r, t.col + at, values[r][0]);
        }
        return { t: t, i: at };
      }));
    }
  }

  class TableColumn extends Proxy {
    _read(p, x) {
      if (p === "name") return headerNames(x.t)[x.i];
      throw new TypeError("mock: TableColumn." + p + " not implemented");
    }
    get name() { return this._prop("name"); }
    getDataBodyRange() {
      use("TableColumn.getDataBodyRange", "1.1");
      return new Range(this._ctx, strict(this, (x) => ({ sheet: tableSheet(x.t), r: x.t.row + 1, c: x.t.col + x.i, h: x.t.rows, w: 1 })));
    }
  }

  class TableRowCollection {
    constructor(ctx, table) { this._ctx = ctx; this._table = table; }
    add(index, values) {
      use("TableRowCollection.add", Array.isArray(values) && values.length > 1 ? "1.4" : "1.1");
      if (index !== null && index !== undefined) throw new TypeError("mock: rows.add with index not implemented");
      const table = this._table;
      return new TableRow(this._ctx, strict(table, (t) => {
        const n = values ? values.length : 1;
        if (values) check2D(values, n, t.cols, "rows.add values");
        const sheet = tableSheet(t);
        const at = t.row + 1 + t.rows; // first row below the table
        shiftDown(sheet, at, t.col, t.col + t.cols - 1, n);
        for (let r = 0; r < n; r++) {
          for (let c = 0; c < t.cols; c++) {
            // New table rows take the formatting of the row above.
            sheet.cells[key(at + r, t.col + c)] = { v: "", f: getCell(sheet, at - 1, t.col + c).f };
            if (values) writeValue(sheet, at + r, t.col + c, values[r][c]);
          }
        }
        t.rows += n;
        return { t: t, i: t.rows - n };
      }));
    }
  }

  class TableRow extends Proxy {
    _read(p) { throw new TypeError("mock: TableRow." + p + " not implemented"); }
  }

  class Range extends Proxy {
    constructor(ctx, resolver) {
      super(ctx, resolver);
      const self = this;
      this.format = {
        autofitColumns() {
          use("RangeFormat.autofitColumns", "1.2");
          self._op(() => {}, true);
        },
      };
    }
    _read(p, x) {
      const grid = (fn) => {
        const out = [];
        for (let r = 0; r < x.h; r++) {
          const row = [];
          for (let c = 0; c < x.w; c++) row.push(fn(getCell(x.sheet, x.r + r, x.c + c)));
          out.push(row);
        }
        return out;
      };
      switch (p) {
        case "values": use("Range.values (get)", "1.1"); return grid((cell) => cell.v);
        case "numberFormat": use("Range.numberFormat (get)", "1.1"); return grid((cell) => cell.f);
        case "rowIndex": use("Range.rowIndex", "1.1"); return x.r;
        case "rowCount": use("Range.rowCount", "1.1"); return x.h;
        case "columnIndex": use("Range.columnIndex", "1.1"); return x.c;
        case "columnCount": use("Range.columnCount", "1.1"); return x.w;
        case "address": use("Range.address", "1.1"); return rectAddress(x);
        default: throw new TypeError("mock: Range." + p + " not implemented");
      }
    }
    get values() { return this._prop("values"); }
    set values(v) {
      use("Range.values (set)", "1.1");
      this._op((x) => {
        check2D(v, x.h, x.w, "values");
        for (let r = 0; r < x.h; r++) for (let c = 0; c < x.w; c++) writeValue(x.sheet, x.r + r, x.c + c, v[r][c]);
      }, true);
    }
    get numberFormat() { return this._prop("numberFormat"); }
    set numberFormat(v) {
      use("Range.numberFormat (set)", "1.1");
      this._op((x) => {
        check2D(v, x.h, x.w, "numberFormat");
        for (let r = 0; r < x.h; r++) for (let c = 0; c < x.w; c++) writeFormat(x.sheet, x.r + r, x.c + c, v[r][c]);
      }, true);
    }
    get rowIndex() { return this._prop("rowIndex"); }
    get rowCount() { return this._prop("rowCount"); }
    get address() { return this._prop("address"); }
    getLastRow() {
      use("Range.getLastRow", "1.1");
      return new Range(this._ctx, strict(this, (x) => Object.assign({}, x, { r: x.r + x.h - 1, h: 1 })));
    }
    getOffsetRange(dr, dc) {
      use("Range.getOffsetRange", "1.1");
      return new Range(this._ctx, strict(this, (x) => {
        if (x.r + dr < 0 || x.c + dc < 0) throw new OfficeError("InvalidArgument", "offset outside the sheet");
        return Object.assign({}, x, { r: x.r + dr, c: x.c + dc });
      }));
    }
    getBoundingRect(other) {
      use("Range.getBoundingRect", "1.1");
      return new Range(this._ctx, strict(this, (x) => {
        const o = typeof other === "string" ? parseAddress(x.sheet, other) : other._r();
        const r = Math.min(x.r, o.r), c = Math.min(x.c, o.c);
        return { sheet: x.sheet, r: r, c: c, h: Math.max(x.r + x.h, o.r + o.h) - r, w: Math.max(x.c + x.w, o.c + o.w) - c };
      }));
    }
    select() {
      use("Range.select", "1.1");
      this._op((x) => { doc.active = x.sheet.name; doc.selection = rectAddress(x); }, true);
    }
  }

  window.Excel = {
    run: async function (batch) {
      const ctx = new RequestContext();
      const result = await batch(ctx);
      if (ctx.queue.some((op) => op.write)) mock.warnings.push("Excel.run ended with unsynced writes");
      return result;
    },
    RequestContext: RequestContext,
  };

  // ---------- Office common API ----------
  function versionAtMost(v, max) {
    const a = String(v).split(".").map(Number), b = String(max).split(".").map(Number);
    return a[0] < b[0] || (a[0] === b[0] && (a[1] || 0) <= (b[1] || 0));
  }

  window.Office = {
    HostType: { Excel: "Excel", Word: "Word" },
    PlatformType: { PC: "PC", OfficeOnline: "OfficeOnline", Mac: "Mac" },
    AsyncResultStatus: { Succeeded: "succeeded", Failed: "failed" },
    context: {
      displayLanguage: cfg.displayLanguage || "de-DE",
      requirements: {
        isSetSupported: (name, version) =>
          name === "ExcelApi" && versionAtMost(version || "1.1", cfg.excelApi || "1.4"),
      },
      document: {
        url: cfg.url === undefined ? "https://contoso.sharepoint.com/Shared%20Documents/Bestellungen.xlsx" : cfg.url,
        settings: {
          get: (name) => (name in liveSettings ? liveSettings[name] : null),
          set: (name, value) => { liveSettings[name] = JSON.parse(JSON.stringify(value)); },
          remove: (name) => { delete liveSettings[name]; },
          saveAsync: (options, callback) => {
            const cb = typeof options === "function" ? options : callback;
            setTimeout(() => {
              doc.settings = Object.assign({}, liveSettings);
              if (cb) cb({ status: "succeeded", value: null });
            }, 1);
          },
        },
      },
    },
    onReady: function (cb) {
      const info = { host: cfg.host === undefined ? "Excel" : cfg.host, platform: "PC" };
      return new Promise((resolve) => setTimeout(() => { if (cb) cb(info); resolve(info); }, 5));
    },
  };
})();
