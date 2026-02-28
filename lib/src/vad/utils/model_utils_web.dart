// lib/src/vad/utils/model_utils_web.dart

import 'dart:js_interop';
import 'package:flutter/services.dart' show ByteData;

Future<String> writeModelToFile(ByteData byteData, String fileName) async {
  // On web, we don't need to write to a file
  throw UnsupportedError('File writing not supported on web');
}

@JS('window.caches.open')
external JSPromise<JSAny> _cachesOpen(JSString cacheName);

@JS('window.fetch')
external JSPromise<JSAny> _fetch(JSString url);

@JS('URL.createObjectURL')
external JSString _createObjectURL(JSAny blob);

extension type CacheProxy(JSObject _) implements JSObject {
  @JS('match')
  external JSPromise<JSAny?> match(JSString request);
  @JS('put')
  external JSPromise<JSAny> put(JSString request, JSAny response);
}

extension type ResponseProxy(JSObject _) implements JSObject {
  @JS('blob')
  external JSPromise<JSAny> blob();
  @JS('clone')
  external ResponseProxy clone();
}

Future<String> getCachedBlobUrl(String url) async {
  try {
    final cacheObj = await _cachesOpen('vad-models-cache'.toJS).toDart;
    final cache = CacheProxy(cacheObj as JSObject);

    final matchObj = await cache.match(url.toJS).toDart;
    if (matchObj != null) {
      final response = ResponseProxy(matchObj as JSObject);
      final blob = await response.blob().toDart;
      return _createObjectURL(blob).toDart;
    }

    // Not in cache, fetch it
    final responseRaw = await _fetch(url.toJS).toDart;
    final response = ResponseProxy(responseRaw as JSObject);

    // Save clone to cache
    await cache.put(url.toJS, response.clone() as JSAny).toDart;

    final blob = await response.blob().toDart;
    return _createObjectURL(blob).toDart;
  } catch (e) {
    print('Failed to cache $url: $e');
    return url; // fallback to original
  }
}
