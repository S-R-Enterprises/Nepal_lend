import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/firebase_auth_repository.dart';

void main() {
  group('mapFirebaseAuthError', () {
    test('maps phone verification failures to stable UI codes', () {
      expect(
        mapFirebaseAuthError(code: 'invalid-phone-number').code,
        'validation_error',
      );
      for (final code in <String>[
        'invalid-verification-code',
        'invalid-verification-id',
        'session-expired',
        'code-expired',
      ]) {
        expect(mapFirebaseAuthError(code: code).code, 'invalid_code');
      }
    });

    test('maps throttling, offline and disabled accounts', () {
      expect(mapFirebaseAuthError(code: 'too-many-requests').code, 'rate_limited');
      expect(
        mapFirebaseAuthError(code: 'network-request-failed').code,
        'offline',
      );
      expect(mapFirebaseAuthError(code: 'user-disabled').code, 'account_suspended');
    });

    test('keeps the Firebase code and message for unknown errors', () {
      final failure = mapFirebaseAuthError(
        code: 'web-context-cancelled',
        message: 'Try again',
      );
      expect(failure.code, 'auth_web-context-cancelled');
      expect(failure.message, 'Try again');
    });
  });

  group('profileFromFirebase', () {
    const cached = AppUser(
      id: 'local-1',
      phone: '+9779800000000',
      name: 'Rohan',
      role: UserRole.borrower,
      kycState: KycStatus.verified,
      firebaseUid: 'uid-1',
    );

    test('reuses role/KYC for the same Firebase identity', () {
      final user = profileFromFirebase(
        uid: 'uid-1',
        phone: '',
        cached: cached,
      );
      expect(user.id, 'local-1');
      expect(user.phone, '+9779800000000');
      expect(user.name, 'Rohan');
      expect(user.role, UserRole.borrower);
      expect(user.kycState, KycStatus.verified);
      expect(user.firebaseUid, 'uid-1');
    });

    test('does not inherit verification from a different phone', () {
      final user = profileFromFirebase(
        uid: 'uid-2',
        phone: '+9779811111111',
        cached: cached,
      );
      expect(user.id, 'uid-2');
      expect(user.phone, '+9779811111111');
      expect(user.name, isNull);
      expect(user.role, isNull);
      expect(user.kycState, KycStatus.notStarted);
      expect(user.status, AccountStatus.active);
      expect(user.firebaseUid, 'uid-2');
    });

    test('new sign-in with no cached session starts unverified', () {
      final user = profileFromFirebase(uid: 'uid-3', phone: '+9779822222222');
      expect(user.id, 'uid-3');
      expect(user.role, isNull);
      expect(user.kycState, KycStatus.notStarted);
    });
  });
}
