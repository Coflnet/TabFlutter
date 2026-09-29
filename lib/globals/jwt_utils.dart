import 'dart:convert';

/// Returns the `exp` claim of [jwt] as UTC time, or null when the token has
/// no readable `exp` claim. Only decodes; does not verify the signature.
DateTime? jwtExpiry(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final claims = jsonDecode(payload);
    if (claims is! Map) return null;
    final exp = claims['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch((exp * 1000).round(),
        isUtc: true);
  } catch (_) {
    return null;
  }
}

/// True only when [jwt] has a readable `exp` claim that has passed. A token
/// that cannot be decoded is kept; the API rejects it if it is invalid.
bool isJwtExpired(String jwt, {DateTime? now}) {
  final exp = jwtExpiry(jwt);
  if (exp == null) return false;
  return !exp.isAfter((now ?? DateTime.now()).toUtc());
}
