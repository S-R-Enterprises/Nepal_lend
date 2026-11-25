import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_controller.dart';

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
    await container.read(authProvider.notifier).demoSignIn();
    await container.read(authProvider.notifier).setRole(UserRole.borrower);
  });

  tearDown(() => container.dispose());

  test('submitDocument stores the step and keeps auth unverified', () async {
    await container.read(kycProvider.notifier).load();

    final ok = await container.read(kycProvider.notifier).submitDocument(
          KycStepKind.selfie,
          document: const PickedDocument(
            path: '/tmp/selfie.jpg',
            name: 'selfie.jpg',
          ),
        );

    expect(ok, isTrue);
    expect(
      container.read(kycProvider).profile.step(KycStepKind.selfie).status,
      KycStatus.inReview,
    );
    expect(container.read(authProvider).user?.isVerified, isFalse);
  });

  test('personal details submission is persisted', () async {
    final ok = await container.read(kycProvider.notifier).submitPersonalDetails(
          const {
            'fullName': 'Sita Sharma',
            'citizenshipNumber': '001-02-345678',
            'dateOfBirth': '1998-04-12',
            'bankName': 'Nepal Bank',
            'accountNumber': '1234567890',
          },
        );

    expect(ok, isTrue);
    expect(
      container.read(kycProvider).profile.details['fullName'],
      'Sita Sharma',
    );
    expect(
      container
          .read(kycProvider)
          .profile
          .step(KycStepKind.personalDetails)
          .status,
      KycStatus.inReview,
    );
  });

  test('decide verifies one step; approveAll verifies the user', () async {
    final controller = container.read(kycProvider.notifier);
    await controller.submitDocument(
      KycStepKind.citizenship,
      document: const PickedDocument(path: '/tmp/c.jpg', name: 'c.jpg'),
    );

    expect(
      await controller.decide(KycStepKind.citizenship, KycStatus.verified),
      isTrue,
    );
    expect(container.read(kycProvider).profile.completedCount, 1);
    expect(container.read(authProvider).user?.isVerified, isFalse);

    expect(await controller.approveAll(), isTrue);
    expect(container.read(kycProvider).profile.allVerified, isTrue);
    expect(container.read(authProvider).user?.isVerified, isTrue);
  });

  test('failed decision surfaces a mapped error', () async {
    final controller = container.read(kycProvider.notifier);
    final ok = await controller.decide(
      KycStepKind.selfie,
      KycStatus.verified,
    );

    expect(ok, isFalse);
    expect(container.read(kycProvider).error, contains('Cannot move verification'));
  });
}
