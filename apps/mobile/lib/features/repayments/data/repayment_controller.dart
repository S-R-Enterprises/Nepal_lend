import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/repositories/loan_repository.dart';
import 'package:nepal_lend/data/repositories/repayment_repository.dart';
import 'package:nepal_lend/features/kyc/data/kyc_gate.dart';

class RepaymentState {
  const RepaymentState({
    this.loan,
    this.next,
    this.schedule = const <Instalment>[],
    this.provider = 'esewa',
    this.feePaisa = 0,
    this.busy = false,
    this.error,
    this.lastReceipt,
  });

  final Loan? loan;
  final Instalment? next;
  final List<Instalment> schedule;
  final String provider;
  final int feePaisa;
  final bool busy;
  final String? error;
  final PaymentReceipt? lastReceipt;

  RepaymentState copyWith({
    Loan? loan,
    Instalment? next,
    List<Instalment>? schedule,
    String? provider,
    int? feePaisa,
    bool? busy,
    String? error,
    bool clearError = false,
    bool clearLoan = false,
    PaymentReceipt? lastReceipt,
  }) =>
      RepaymentState(
        loan: clearLoan ? null : loan ?? this.loan,
        next: clearLoan ? null : next ?? this.next,
        schedule: clearLoan ? const <Instalment>[] : schedule ?? this.schedule,
        provider: provider ?? this.provider,
        feePaisa: feePaisa ?? this.feePaisa,
        busy: busy ?? this.busy,
        error: clearError ? null : error ?? this.error,
        lastReceipt: lastReceipt ?? this.lastReceipt,
      );
}

/// Borrower-side repayment flow. The role/KYC gate runs here before any money
/// request leaves the widget tree, matching the mock API and router guards.
class RepaymentController extends Notifier<RepaymentState> {
  @override
  RepaymentState build() => const RepaymentState();

  RepaymentRepository get _repository =>
      ref.read(repaymentRepositoryProvider);

  AppUser get _user {
    final user = ref.read(requireVerifiedUserProvider)();
    if (user.role != UserRole.borrower) {
      throw const AppFailure(
        'role_required',
        'Only a borrower account can repay a loan.',
      );
    }
    return user;
  }

  Future<void> load(String loanId) async {
    try {
      _user;
      state = state.copyWith(busy: true, clearError: true);
      final loan = await ref.read(loanRepositoryProvider).loan(loanId);
      _apply(loan);
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  /// Used by `/borrower/repay` when no loan id is supplied.
  Future<void> loadAny() async {
    try {
      _user;
      state = state.copyWith(busy: true, clearError: true);
      final loans = await ref.read(loanRepositoryProvider).myLoans();
      final repayable = loans.where(
        (loan) =>
            loan.status == LoanStatus.active ||
            loan.status == LoanStatus.overdue,
      );
      if (repayable.isEmpty) {
        state = state.copyWith(
          busy: false,
          clearLoan: true,
          clearError: true,
        );
        return;
      }
      _apply(repayable.first);
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  void setProvider(String provider) =>
      state = state.copyWith(provider: provider);

  void clearError() => state = state.copyWith(clearError: true);

  Future<PaymentReceipt?> pay({required String loanId}) async {
    final next = state.next;
    if (next == null) return null;
    try {
      _user;
      state = state.copyWith(busy: true, clearError: true);
      final key = 'repay-${next.id}';
      final outcome = await _repository.pay(
        loanId: loanId,
        instalmentNumber: next.number,
        provider: state.provider,
        idempotencyKey: key,
      );
      _apply(outcome.loan, receipt: outcome.receipt, feePaisa: outcome.feePaisa);
      return outcome.receipt;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  void _apply(
    Loan loan, {
    PaymentReceipt? receipt,
    int? feePaisa,
  }) {
    final instalments = <Instalment>[...loan.instalments]
      ..sort((a, b) => a.number.compareTo(b.number));
    final next = loan.nextInstalment;
    state = state.copyWith(
      loan: loan,
      next: next,
      schedule: List<Instalment>.unmodifiable(instalments),
      feePaisa: feePaisa ?? (next == null ? 0 : _feeFor(next)),
      lastReceipt: receipt,
      busy: false,
      clearError: true,
    );
  }

  int _feeFor(Instalment instalment) =>
      Money.feeForInterest(instalment.interestPaisa);
}

final repaymentControllerProvider =
    NotifierProvider<RepaymentController, RepaymentState>(
  RepaymentController.new,
);
