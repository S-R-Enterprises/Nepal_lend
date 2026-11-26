import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/features/auth/data/firebase_auth_repository.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';

class CodeRequestResult {
  const CodeRequestResult({required this.phone, this.demoCode, this.verificationId});

  final String phone;

  /// Mock-only shortcut shown in test/dev tooling. Never set by Firebase.
  final String? demoCode;

  /// Firebase verification ID used by [AuthRepository.verifyCode].
  final String? verificationId;
}

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AppUser user;
  final String token;
}

/// Boundary between the app and the identity provider.
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

/// Firebase is the production identity provider. The mock repository remains
/// available for widget tests and for a local backend-free demo when Firebase
/// has not been initialised (for example in `flutter test`).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  if (Firebase.apps.isEmpty) return MockAuthRepository(api: api);
  return FirebaseAuthRepository(api: api);
});
