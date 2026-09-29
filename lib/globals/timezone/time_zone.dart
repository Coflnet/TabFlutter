import 'time_zone_stub.dart' if (dart.library.js_interop) 'time_zone_web.dart'
    as impl;

/// The device's IANA time zone id (e.g. "Europe/Berlin"), or null when it is
/// not available cheaply. The server then uses Europe/Berlin.
String? localTimeZoneId() {
  try {
    final id = impl.localTimeZoneId();
    if (id == null || id.isEmpty || !id.contains('/')) return null;
    return id;
  } catch (_) {
    return null;
  }
}
