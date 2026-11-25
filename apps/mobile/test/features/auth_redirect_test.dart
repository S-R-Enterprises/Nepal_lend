import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/router/app_router.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';

void main() {
  test('unknown auth state waits on splash', () {
    expect(
      authRedirect(const AuthState(status: AuthStatus.unknown), '/lender/home'),
      '/splash',
    );
  });

  test('signed out users go to login except on public and auth routes', () {
    const state = AuthState(status: AuthStatus.signedOut);
    expect(authRedirect(state, '/lender/home'), '/login');
    expect(authRedirect(state, '/splash'), '/login');
    expect(authRedirect(state, '/login'), isNull);
    expect(authRedirect(state, '/help'), isNull);
    expect(authRedirect(state, '/otp'), '/login');
  });

  test('otp is reachable once a code was requested', () {
    const state = AuthState(
      status: AuthStatus.signedOut,
      pendingPhone: '+9779800000000',
    );
    expect(authRedirect(state, '/otp'), isNull);
  });

  test('role then KYC gates apply in order', () {
    const noRole = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(id: 'u', phone: '+9779800000000'),
    );
    expect(authRedirect(noRole, '/kyc'), '/role-selection');

    const unverified = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'u',
        phone: '+9779800000000',
        role: UserRole.borrower,
      ),
    );
    expect(authRedirect(unverified, '/borrower/home'), '/kyc');
    expect(authRedirect(unverified, '/kyc/selfie'), isNull);
  });

  test('verified users are sent home from auth routes', () {
    const state = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'u',
        phone: '+9779800000000',
        role: UserRole.lender,
        kycState: KycStatus.verified,
      ),
    );
    expect(authRedirect(state, '/login'), '/lender/home');
    expect(authRedirect(state, '/lender/portfolio'), isNull);
  });

  test('wallet routes are restricted to verified lenders', () {
    const borrower = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'u',
        phone: '+9779800000000',
        role: UserRole.borrower,
        kycState: KycStatus.verified,
      ),
    );
    expect(authRedirect(borrower, '/lender/wallet'), '/borrower/home');
    expect(authRedirect(borrower, '/lender/wallet/topup'), '/borrower/home');
    expect(authRedirect(borrower, '/lender/wallet/withdraw'), '/borrower/home');

    const lender = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'u',
        phone: '+9779800000000',
        role: UserRole.lender,
        kycState: KycStatus.verified,
      ),
    );
    expect(authRedirect(lender, '/lender/wallet/topup'), isNull);
    expect(authRedirect(lender, '/wallet/transactions/txn-1'), isNull);
  });

  test('unverified deep links cannot reach receipts', () {
    const unverified = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'u',
        phone: '+9779800000000',
        role: UserRole.lender,
      ),
    );
    expect(authRedirect(unverified, '/wallet/transactions/txn-1'), '/kyc');
  });
}
