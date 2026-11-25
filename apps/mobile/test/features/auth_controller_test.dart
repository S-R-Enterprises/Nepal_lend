import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    await MockDb.instance.clear();
    container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('restore reports signed out when no session exists', () async {
    await container.read(authProvider.notifier).restore();
    expect(container.read(authProvider).status, AuthStatus.signedOut);
  });

  test('full sign-in, role selection and verification sequence', () async {
    final auth = container.read(authProvider.notifier);

    await auth.restore();
    expect(container.read(authProvider).status, AuthStatus.signedOut);

    await auth.sendCode('9800000000');
    expect(container.read(authProvider).pendingPhone, '+9779800000000');

    final rejected = await auth.verifyCode('000000');
    expect(rejected, isFalse);
    expect(container.read(authProvider).error, contains('Too many'));

    final accepted = await auth.verifyCode(MockAuthRepository.demoCode);
    expect(accepted, isTrue);
    expect(container.read(authProvider).isSignedIn, isTrue);
    expect(container.read(authProvider).error, isNull);

    await auth.setRole(UserRole.lender);
    expect(container.read(authProvider).user!.role, UserRole.lender);

    await auth.setKycVerified();
    expect(container.read(authProvider).user!.isVerified, isTrue);

    await auth.signOut();
    expect(container.read(authProvider).status, AuthStatus.signedOut);
  });

  test('demo sign-in works in one step', () async {
    await container.read(authProvider.notifier).demoSignIn();
    expect(container.read(authProvider).isSignedIn, isTrue);
  });

  test('restore falls back to signed out when platform storage fails', () async {
    final failingContainer = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
        authRepositoryProvider.overrideWithValue(_FailingAuthRepository()),
      ],
    );
    addTearDown(failingContainer.dispose);

    await failingContainer.read(authProvider.notifier).restore();
    expect(failingContainer.read(authProvider).status, AuthStatus.signedOut);
  });
}

class _FailingAuthRepository implements AuthRepository {
  @override
  Future<CodeRequestResult> sendCode(String phone) =>
      throw StateError('platform unavailable');

  @override
  Future<AuthSession> verifyCode({required String phone, required String code}) =>
      throw StateError('platform unavailable');

  @override
  Future<AppUser?> restoreSession() =>
      throw StateError('platform unavailable');

  @override
  Future<AppUser?> currentUser() => throw StateError('platform unavailable');

  @override
  Future<void> saveDeviceToken(String token) =>
      throw StateError('platform unavailable');

  @override
  Future<void> signOut() => throw StateError('platform unavailable');
}
