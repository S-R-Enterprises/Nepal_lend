import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';

void main() {
  test('new profile has four not-started steps', () {
    final profile = KycProfile.initial();

    expect(profile.steps, hasLength(4));
    expect(profile.completedCount, 0);
    expect(profile.allVerified, isFalse);
    expect(profile.overallState, KycStatus.notStarted);
    expect(
      profile.steps.map((step) => step.kind).toList(),
      KycStepKind.values,
    );
  });

  group('state machine', () {
    test('allows submit, decision and rejected retry', () {
      expect(
        KycTransitions.canTransition(KycStatus.notStarted, KycStatus.inReview),
        isTrue,
      );
      expect(
        KycTransitions.canTransition(KycStatus.inReview, KycStatus.verified),
        isTrue,
      );
      expect(
        KycTransitions.canTransition(KycStatus.inReview, KycStatus.rejected),
        isTrue,
      );
      expect(
        KycTransitions.canTransition(KycStatus.rejected, KycStatus.inReview),
        isTrue,
      );
    });

    test('blocks skipping and unlocking verified steps', () {
      expect(
        KycTransitions.canTransition(KycStatus.notStarted, KycStatus.verified),
        isFalse,
      );
      expect(
        KycTransitions.canTransition(KycStatus.verified, KycStatus.rejected),
        isFalse,
      );
      expect(
        () => KycTransitions.check(
          KycStatus.notStarted,
          KycStatus.verified,
        ),
        throwsA(isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'invalid_transition',
        )),
      );
    });
  });

  test('overall state is derived from the four steps', () {
    var profile = KycProfile.initial();
    final now = DateTime(2026, 11, 24);

    profile = profile.submit(
      KycStepKind.citizenship,
      documentPath: '/tmp/citizenship.jpg',
      now: now,
    );
    expect(profile.overallState, KycStatus.inReview);

    profile = profile.decide(
      KycStepKind.citizenship,
      KycStatus.rejected,
      reason: 'Blurry',
      now: now,
    );
    expect(profile.overallState, KycStatus.rejected);

    profile = profile.submit(
      KycStepKind.citizenship,
      documentPath: '/tmp/citizenship-2.jpg',
      now: now,
    );
    expect(profile.step(KycStepKind.citizenship).reason, isNull);
    expect(profile.overallState, KycStatus.inReview);
  });

  test('approveAll reaches verified and survives json round-trip', () {
    final profile = KycProfile.initial().approveAll(
      now: DateTime(2026, 11, 24),
    );

    expect(profile.allVerified, isTrue);
    expect(profile.overallState, KycStatus.verified);
    expect(profile.completedCount, 4);

    final restored = KycProfile.fromJson(profile.toJson());
    expect(restored.allVerified, isTrue);
    expect(
      restored.details['fullName'],
      profile.details['fullName'],
    );
  });

  test('document steps require a file', () {
    expect(
      () => KycProfile.initial().submit(KycStepKind.selfie),
      throwsA(isA<AppFailure>().having(
        (error) => error.code,
        'code',
        'validation_error',
      )),
    );
  });

  test('rejecting without a reason is blocked', () {
    var profile = KycProfile.initial().submit(
      KycStepKind.selfie,
      documentPath: '/tmp/selfie.jpg',
    );
    expect(
      () => profile.decide(KycStepKind.selfie, KycStatus.rejected),
      throwsA(isA<AppFailure>().having(
        (error) => error.code,
        'code',
        'validation_error',
      )),
    );
    profile = profile.decide(
      KycStepKind.selfie,
      KycStatus.rejected,
      reason: 'Face not visible',
    );
    expect(profile.step(KycStepKind.selfie).reason, 'Face not visible');
  });
}
