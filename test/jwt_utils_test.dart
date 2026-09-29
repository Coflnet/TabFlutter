import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:table_entry/globals/jwt_utils.dart';

String jwtWith(Object payload) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part(payload)}.sig';
}

void main() {
  final now = DateTime.utc(2026, 9, 30, 12);
  int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  test('token whose exp has passed is expired', () {
    final jwt =
        jwtWith({'exp': secs(now.subtract(const Duration(minutes: 1)))});
    expect(isJwtExpired(jwt, now: now), isTrue);
  });

  test('token with exp in the future is kept', () {
    final jwt = jwtWith({
      'exp': secs(now.add(const Duration(days: 7))),
      'name': 'Jürgen', // non-ASCII payload, unpadded base64url
    });
    expect(isJwtExpired(jwt, now: now), isFalse);
    expect(jwtExpiry(jwt), now.add(const Duration(days: 7)));
  });

  test('undecodable or exp-less tokens are kept', () {
    expect(isJwtExpired('not-a-jwt', now: now), isFalse);
    expect(isJwtExpired('a.b.c', now: now), isFalse);
    expect(isJwtExpired('a.%%%.c', now: now), isFalse);
    expect(isJwtExpired(jwtWith({'sub': '1'}), now: now), isFalse);
    expect(isJwtExpired(jwtWith({'exp': 'soon'}), now: now), isFalse);
    expect(isJwtExpired(jwtWith([1, 2]), now: now), isFalse);
    expect(isJwtExpired('', now: now), isFalse);
  });
}
