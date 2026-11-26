import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/phone_number.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';

/// Firebase Phone OTP identity provider.
///
/// The HTTP API and ledgers stay behind their existing boundaries; Firebase is
/// the source of truth for identity, verification and the ID token used as the
/// bearer credential. The local profile row keeps role/KYC state until the
/// backend session endpoint is connected.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required this.api});

  final ApiClient api;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> _verificationIds = <String, String>{};
  final Map<String, int> _resendTokens = <String, int>{};
  final Map<String, PhoneAuthCredential> _instantCredentials =
      <String, PhoneAuthCredential>{};

  @override
  Future<CodeRequestResult> sendCode(String phone) async {
    final local = NepaliPhone.localDigits(phone);
    if (!NepaliPhone.isValid(local)) {
      throw const AppFailure(
        'validation_error',
        'Enter a valid 10-digit Nepali mobile number.',
      );
    }
    final e164 = NepaliPhone.toE164(local);
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendTokens[local],
      verificationCompleted: (credential) {
        _instantCredentials[local] = credential;
        if (!completer.isCompleted) completer.complete('instant');
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(_mapAuthError(error));
        }
      },
      codeSent: (verificationId, resendToken) {
        _verificationIds[local] = verificationId;
        if (resendToken != null) _resendTokens[local] = resendToken;
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationIds[local] = verificationId;
      },
    );

    final verificationId = await completer.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () => throw const AppFailure(
        'verification_timeout',
        'We could not send the code. Please try again.',
      ),
    );
    return CodeRequestResult(
      phone: e164,
      verificationId: verificationId,
    );
  }

  @override
  Future<AuthSession> verifyCode({
    required String phone,
    required String code,
  }) async {
    final local = NepaliPhone.localDigits(phone);
    final instant = _instantCredentials.remove(local);
    final verificationId = _verificationIds[local];
    if (instant == null && verificationId == null) {
      throw const AppFailure(
        'code_not_requested',
        'Request a code before entering it.',
      );
    }

    try {
      final credential = instant ??
          PhoneAuthProvider.credential(
            verificationId: verificationId!,
            smsCode: code,
          );
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AppFailure('unauthorized', 'Please sign in again.');
      }
      final user = await _profileFor(firebaseUser);
      final token = await firebaseUser.getIdToken();
      if (token == null) {
        throw const AppFailure('unauthorized', 'Please sign in again.');
      }
      return AuthSession(user: user, token: token);
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      await MockDb.instance.clearSession();
      return null;
    }
    return _profileFor(firebaseUser);
  }

  @override
  Future<AppUser?> currentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _profileFor(firebaseUser);
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
    await _auth.signOut();
    _verificationIds.clear();
    _resendTokens.clear();
    _instantCredentials.clear();
    await MockDb.instance.clearSession();
  }

  Future<AppUser> _profileFor(User firebaseUser) async {
    await MockDb.instance.ensureLoaded();
    final user = profileFromFirebase(
      uid: firebaseUser.uid,
      phone: firebaseUser.phoneNumber ?? '',
      cached: MockDb.instance.currentUser,
    );
    await MockDb.instance.setUser(user);
    return user;
  }

  AppFailure _mapAuthError(FirebaseAuthException error) =>
      mapFirebaseAuthError(code: error.code, message: error.message);
}

/// Maps a Firebase user onto the local profile row without touching plugins.
///
/// Role/KYC fields are kept only for the same identity (matching Firebase UID
/// or phone). A different phone must never inherit another user's verification.
AppUser profileFromFirebase({
  required String uid,
  required String phone,
  AppUser? cached,
}) {
  final sameIdentity = cached != null &&
      (cached.firebaseUid == uid ||
          (phone.isNotEmpty && cached.phone == phone));
  final existing = sameIdentity ? cached : null;
  return AppUser(
    id: existing?.id ?? uid,
    phone: phone.isNotEmpty ? phone : (existing?.phone ?? ''),
    name: existing?.name,
    email: existing?.email,
    role: existing?.role,
    kycState: existing?.kycState ?? KycStatus.notStarted,
    status: existing?.status ?? AccountStatus.active,
    avatarPath: existing?.avatarPath,
    firebaseUid: uid,
  );
}

/// Maps Firebase Auth codes to the stable failures used by the UI.
AppFailure mapFirebaseAuthError({required String code, String? message}) =>
    switch (code) {
      'invalid-phone-number' => const AppFailure(
          'validation_error',
          'Enter a valid 10-digit Nepali mobile number.',
        ),
      'invalid-verification-code' ||
      'invalid-verification-id' ||
      'session-expired' ||
      'code-expired' =>
        const AppFailure('invalid_code', 'That code is not correct.'),
      'too-many-requests' => const AppFailure(
          'rate_limited',
          'Too many attempts. Please wait a moment and try again.',
        ),
      'network-request-failed' => const AppFailure(
          'offline',
          'No connection. Check your internet and try again.',
        ),
      'user-disabled' => const AppFailure(
          'account_suspended',
          'This account is suspended.',
        ),
      _ => AppFailure('auth_$code', message ?? messageFor('auth')),
    };
