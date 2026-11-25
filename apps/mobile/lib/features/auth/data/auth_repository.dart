import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';

class CodeRequestResult {
  const CodeRequestResult({required this.phone, this.demoCode});

  final String phone;
  final String? demoCode;
}

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AppUser user;
  final String token;
}

/// Boundary between the app and the identity provider.
///
/// Track B adds `FirebaseAuthRepository` behind the same interface; screens
/// and the controller do not change.
abstract class AuthRepository {
  Future<CodeRequestResult> sendCode(String phone);

  Future<AuthSession> verifyCode({
    required String phone,
    required String code,
  });

  Future<AppUser?> restoreSession();

  /// Re-reads the current user after a profile change such as KYC approval.
  Future<AppUser?> currentUser();

  Future<void> saveDeviceToken(String token);

  Future<void> signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(api: ref.watch(apiClientProvider));
});
