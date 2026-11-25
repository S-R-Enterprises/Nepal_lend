import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/kyc/data/kyc_gate.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    await MockDb.instance.clear();
    MockDb.instance.kycProfile = KycProfile.initial();
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

  test('signed-out user is unauthorized', () {
    expect(
      () => container.read(requireVerifiedUserProvider)(),
      throwsA(isA<AppFailure>().having(
        (error) => error.code,
        'code',
        'unauthorized',
      )),
    );
  });

  test('unverified user gets kyc_required', () async {
    await container.read(authProvider.notifier).demoSignIn();

    expect(
      () => container.read(requireVerifiedUserProvider)(),
      throwsA(isA<AppFailure>().having(
        (error) => error.code,
        'code',
        'kyc_required',
      )),
    );
  });

  test('verified user is returned by the gate', () async {
    await MockDb.instance.setUser(
      const AppUser(
        id: 'demo-user',
        phone: '+9779800000000',
        role: UserRole.lender,
        kycState: KycStatus.verified,
      ),
    );
    await container.read(authProvider.notifier).refresh();

    final user = container.read(requireVerifiedUserProvider)();
    expect(user.isVerified, isTrue);
    expect(user.role, UserRole.lender);
  });
}
