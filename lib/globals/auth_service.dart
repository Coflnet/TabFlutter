import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_entry/generatedCode/api.dart';

/// Manages Firebase authentication and API JWT tokens.
///
/// Flow:
/// 1. User signs in via Google (through Firebase Auth)
/// 2. Firebase returns an ID token
/// 3. ID token is exchanged for a Spables JWT via /api/auth/firebase
/// 4. JWT is stored in SharedPreferences and passed to all API calls
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _jwtKey = 'auth_jwt_token';
  static const _emailKey = 'auth_user_email';
  static const _uidKey = 'auth_user_uid';

  // The JWT is moved out of SharedPreferences into Keychain (iOS) /
  // Keystore-backed EncryptedSharedPreferences (Android). On web
  // flutter_secure_storage falls back to an HSM-backed IDB key when
  // available, otherwise IndexedDB — still strictly better than
  // localStorage because it isn't reachable from <script> tags loaded by
  // a different origin via document.domain shenanigans.
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _jwtToken;
  String? _email;
  String? _uid;
  bool _loading = false;

  /// The current JWT token for API calls, or null if not authenticated.
  String? get jwtToken => _jwtToken;

  /// The current user's email, or null if not authenticated.
  String? get email => _email;

  /// The current user's Firebase UID, or null if not authenticated.
  String? get uid => _uid;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _jwtToken != null && _jwtToken!.isNotEmpty;

  /// Whether an auth operation is in progress.
  bool get isLoading => _loading;

  /// Initialize the auth service. Call once at app startup.
  /// Restores any saved session from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // One-shot migration: older versions stored the JWT in plain
    // SharedPreferences. Pull it out, move it to secure storage, then wipe
    // the prefs copy so the value never sits unencrypted on disk again.
    final legacyJwt = prefs.getString(_jwtKey);
    if (legacyJwt != null && legacyJwt.isNotEmpty) {
      await _secure.write(key: _jwtKey, value: legacyJwt);
      await prefs.remove(_jwtKey);
    }
    _jwtToken = await _secure.read(key: _jwtKey);
    _email = prefs.getString(_emailKey);
    _uid = prefs.getString(_uidKey);

    // Check if Firebase user is still valid
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && _jwtToken != null) {
      _email = firebaseUser.email ?? _email;
      _uid = firebaseUser.uid;
    } else if (firebaseUser == null) {
      // Firebase session expired, clear stored JWT
      await _clearSession();
    }

    notifyListeners();
  }

  /// Sign in with Google. Works on web and mobile.
  /// Returns true on success, false on failure/cancellation.
  Future<bool> signInWithGoogle() async {
    _loading = true;
    notifyListeners();

    try {
      UserCredential credential;

      if (kIsWeb) {
        // Web: use popup
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        credential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile: use GoogleSignIn package
        final googleAccount = await GoogleSignIn.instance.authenticate(
          scopeHint: ['email'],
        );

        final googleAuth = googleAccount.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential =
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      }

      // Get Firebase ID token
      final idToken = await credential.user?.getIdToken();
      if (idToken == null) {
        _loading = false;
        notifyListeners();
        return false;
      }

      // Exchange Firebase token for Spables JWT
      final success = await _exchangeToken(idToken);

      if (success) {
        _email = credential.user?.email;
        _uid = credential.user?.uid;
        await _saveSession();
      }

      _loading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out and clear all stored auth data.
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
      }
    } catch (_) {}

    await _clearSession();
    notifyListeners();
  }

  /// Exchange a Firebase ID token for a Spables API JWT.
  Future<bool> _exchangeToken(String firebaseIdToken) async {
    try {
      final apiClient = ApiClient(basePath: 'https://tab.coflnet.com');
      final authApi = AuthApi(apiClient);
      final response = await authApi.loginFirebase(
        TokenContainer(authToken: firebaseIdToken),
      );

      if (response != null &&
          response.authToken != null &&
          response.authToken!.isNotEmpty) {
        _jwtToken = response.authToken;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token exchange error: $e');
      return false;
    }
  }

  /// Persist session to SharedPreferences (non-secret bits) + secure storage (JWT).
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_jwtToken != null) await _secure.write(key: _jwtKey, value: _jwtToken);
    if (_email != null) await prefs.setString(_emailKey, _email!);
    if (_uid != null) await prefs.setString(_uidKey, _uid!);
  }

  /// Clear all stored auth data.
  Future<void> _clearSession() async {
    _jwtToken = null;
    _email = null;
    _uid = null;
    final prefs = await SharedPreferences.getInstance();
    await _secure.delete(key: _jwtKey);
    await prefs.remove(_jwtKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_uidKey);
  }
}
