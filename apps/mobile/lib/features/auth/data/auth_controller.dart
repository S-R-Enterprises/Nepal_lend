import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.pendingPhone,
    this.error,
    this.isBusy = false,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? pendingPhone;
  final String? error;
  final bool isBusy;

  bool get isSignedIn => status == AuthStatus.signedIn && user != null;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? pendingPhone,
    bool clearPendingPhone = false,
    String? error,
    bool clearError = false,
    bool? isBusy,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingPhone:
          clearPendingPhone ? null : pendingPhone ?? this.pendingPhone,
      error: clearError ? null : error ?? this.error,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

/// Owns the sign-in flow and the session snapshot consumed by the router.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unknown);

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> restore() async {
    try {
      // A platform plugin can fail or stall on an old device. Never leave the
      // router in `unknown` forever: fall back to signed-out instead.
      final user = await _repository.restoreSession().timeout(
            const Duration(seconds: 3),
          );
      state = AuthState(
        status: user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
        user: user,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.signedOut);
    }
  }

  /// Re-reads the user after KYC or profile changes so router guards see the
  /// new verification state immediately.
  Future<void> refresh() async {
    final user = await _repository.currentUser();
    if (user == null) {
      state = const AuthState(status: AuthStatus.signedOut);
      return;
    }
    state = AuthState(status: AuthStatus.signedIn, user: user);
  }

  Future<void> sendCode(String phone) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final result = await _repository.sendCode(phone);
      state = state.copyWith(isBusy: false, pendingPhone: result.phone);
    } on AppFailure catch (failure) {
      state = state.copyWith(isBusy: false, error: failure.message);
    }
  }

  Future<bool> verifyCode(String code) async {
    final phone = state.pendingPhone;
    if (phone == null) {
      state = state.copyWith(error: 'Request a code first.');
      return false;
    }
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final session = await _repository.verifyCode(phone: phone, code: code);
      state = AuthState(
        status: AuthStatus.signedIn,
        user: session.user,
        isBusy: false,
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isBusy: false, error: failure.message);
      return false;
    }
  }

  /// One-tap sign-in used by the mock login screen and tests.
  Future<void> demoSignIn() async {
    await sendCode(MockAuthRepository.defaultDemoPhone);
    await verifyCode(MockAuthRepository.demoCode);
  }

  void cancelCode() {
    state = state.copyWith(clearPendingPhone: true, clearError: true);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> setRole(UserRole role) async {
    final user = state.user;
    if (user == null || user.role != null) return;
    final updated = user.copyWith(role: role);
    await MockDb.instance.setUser(updated);
    state = AuthState(status: AuthStatus.signedIn, user: updated);
  }

  /// Kept for the older demo shortcut; the real flow uses KycController.
  Future<void> setKycVerified() async {
    final user = state.user;
    if (user == null) return;
    await MockDb.instance.setKyc(
      (MockDb.instance.kycProfile ?? KycProfile.initial()).approveAll(),
    );
    await refresh();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.signedOut);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
