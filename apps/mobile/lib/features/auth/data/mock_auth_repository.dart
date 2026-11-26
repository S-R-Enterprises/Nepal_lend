import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/phone_number.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';

/// Demo identity provider. The fixed code is shown in the mock UI only —
/// production uses Firebase phone sign-in and has no in-app code shortcut.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({required this.api});

  final ApiClient api;

  static const String demoCode = '123456';
  static const String tooManyRequestsCode = '000000';
  static const String offlineCode = '999999';
  static const String defaultDemoPhone = '9800000000';

  final Map<String, String> _sentCodes = <String, String>{};

  @override
  Future<CodeRequestResult> sendCode(String phone) async {
    final local = localDigits(phone);
    if (!isValidNepaliMobile(local)) {
      throw const AppFailure(
        'validation_error',
        'Enter a valid 10-digit Nepali mobile number.',
      );
    }
    _sentCodes[local] = demoCode;
    return CodeRequestResult(
      phone: toE164(local),
      demoCode: api.env.isMock ? demoCode : null,
    );
  }

  @override
  Future<AuthSession> verifyCode({
    required String phone,
    required String code,
  }) async {
    final local = localDigits(phone);
    if (code == tooManyRequestsCode) {
      throw const AppFailure(
        'rate_limited',
        'Too many attempts. Please wait a moment and try again.',
      );
    }
    if (code == offlineCode) {
      throw const AppFailure(
        'offline',
        'No connection. Check your internet and try again.',
      );
    }
    if (!_sentCodes.containsKey(local)) {
      throw const AppFailure(
        'code_not_requested',
        'Request a code before entering it.',
      );
    }
    if (code != demoCode) {
      throw const AppFailure('invalid_code', 'That code is not correct.');
    }

    final response = await api.postJson(
      '/auth/session',
      data: <String, dynamic>{'phone': toE164(local)},
    );
    final user = AppUser.fromJson(response['user'] as Map<String, dynamic>);
    return AuthSession(
      user: user,
      token: 'mock-id-token-${user.id}',
    );
  }

  /// The demo session is the persisted [MockDb] user. This deliberately avoids
  /// platform token storage: `ENV=mock` has no real credentials, and a device
  /// plugin failure must never trap the splash screen.
  @override
  Future<AppUser?> restoreSession() async {
    await MockDb.instance.ensureLoaded();
    return MockDb.instance.currentUser;
  }

  @override
  Future<AppUser?> currentUser() async {
    await MockDb.instance.ensureLoaded();
    return MockDb.instance.currentUser;
  }

  @override
  Future<void> saveDeviceToken(String token) async {
    await api.postJson(
      '/me/devices',
      data: <String, dynamic>{'fcmToken': token, 'platform': 'android'},
    );
  }

  @override
  Future<void> signOut() async {
    await MockDb.instance.clear();
  }

  static String normalizePhone(String phone) => NepaliPhone.normalize(phone);

  /// Strip the country code so code requests and verification use one key.
  static String localDigits(String phone) => NepaliPhone.localDigits(phone);

  static String toE164(String phone) => NepaliPhone.toE164(phone);

  static bool isValidNepaliMobile(String digits) =>
      NepaliPhone.isValid(digits);
}
