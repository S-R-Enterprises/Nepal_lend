import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists session tokens. The platform (Keychain/Keystore) is the source of
/// truth; when the platform channel is missing (widget/unit tests) or a call
/// fails, a static in-memory copy keeps the session alive for this run.
class TokenStore {
  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  static String? _memAccess;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _memAccess = accessToken;
    try {
      await _storage.write(key: _accessKey, value: accessToken);
      await _storage.write(key: _refreshKey, value: refreshToken);
    } catch (_) {
      // Unavailable platform — in-memory copy carries the access token.
    }
  }

  Future<String?> readAccessToken() async {
    try {
      final v = await _storage.read(key: _accessKey);
      if (v != null) return v;
    } catch (_) {
      // Fall through to the in-memory copy.
    }
    return _memAccess;
  }

  Future<void> clear() async {
    _memAccess = null;
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      // Best-effort.
    }
  }
}
