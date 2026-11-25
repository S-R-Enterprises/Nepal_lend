import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/repositories/funding_repository.dart';
import 'package:nepal_lend/data/repositories/ledger_repository.dart';
import 'package:nepal_lend/features/kyc/data/kyc_gate.dart';

class LendingState {
  const LendingState({
    this.loans = const <Loan>[],
    this.currentLoan,
    this.stakes = const <Stake>[],
    this.currentStake,
    this.walletBalancePaisa = 0,
    this.busy = false,
    this.error,
  });

  final List<Loan> loans;
  final Loan? currentLoan;
  final List<Stake> stakes;
  final StakeDetail? currentStake;
  final int walletBalancePaisa;
  final bool busy;
  final String? error;

  LendingState copyWith({
    List<Loan>? loans,
    Loan? currentLoan,
    List<Stake>? stakes,
    StakeDetail? currentStake,
    int? walletBalancePaisa,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      LendingState(
        loans: loans ?? this.loans,
        currentLoan: currentLoan ?? this.currentLoan,
        stakes: stakes ?? this.stakes,
        currentStake: currentStake ?? this.currentStake,
        walletBalancePaisa: walletBalancePaisa ?? this.walletBalancePaisa,
        busy: busy ?? this.busy,
        error: clearError ? null : error ?? this.error,
      );
}

/// Lender-side flow. The KYC/role gate runs here as well as in the router so
/// a stale widget or deep link cannot move money.
class LendingController extends Notifier<LendingState> {
  @override
  LendingState build() => const LendingState();

  FundingRepository get _repository => ref.read(fundingRepositoryProvider);

  AppUser get _user {
    final user = ref.read(requireVerifiedUserProvider)();
    if (user.role != UserRole.lender) {
      throw const AppFailure(
        'role_required',
        'Only a lender account can fund loans.',
      );
    }
    return user;
  }

  Future<int> _walletBalance() async {
    final snapshot = await ref
        .read(ledgerRepositoryProvider)
        .loadWallet(_user.id);
    return snapshot.balancePaisa;
  }

  Future<void> browse({
    RiskBand? riskBand,
    int? minAmountPaisa,
    int? maxAmountPaisa,
    int? maxTenorMonths,
    String sort = 'newest',
  }) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      _user;
      final loans = await _repository.browseLoans(
        riskBand: riskBand,
        minAmountPaisa: minAmountPaisa,
        maxAmountPaisa: maxAmountPaisa,
        maxTenorMonths: maxTenorMonths,
        sort: sort,
      );
      final balance = await _walletBalance();
      state = state.copyWith(
        loans: loans,
        walletBalancePaisa: balance,
        busy: false,
        clearError: true,
      );
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  Future<Loan?> loadLoan(String id) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      _user;
      final loan = await _repository.loanDetails(id);
      final balance = await _walletBalance();
      state = state.copyWith(
        currentLoan: loan,
        walletBalancePaisa: balance,
        busy: false,
        clearError: true,
      );
      return loan;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  Future<void> loadStakes() async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      _user;
      final stakes = await _repository.myStakes();
      state = state.copyWith(
        stakes: stakes,
        busy: false,
        clearError: true,
      );
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  Future<StakeDetail?> loadStake(String id) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      _user;
      final detail = await _repository.stake(id);
      state = state.copyWith(
        currentStake: detail,
        busy: false,
        clearError: true,
      );
      return detail;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  Future<Stake?> fund({
    required String loanId,
    required int amountPaisa,
    required String idempotencyKey,
  }) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      _user;
      final stake = await _repository.fund(
        loanId: loanId,
        amountPaisa: amountPaisa,
        idempotencyKey: idempotencyKey,
      );
      final updatedLoan = await _repository.loanDetails(loanId);
      final balance = await _walletBalance();
      state = state.copyWith(
        loans: [
          updatedLoan,
          ...state.loans.where((item) => item.id != loanId),
        ],
        currentLoan: updatedLoan,
        stakes: [stake, ...state.stakes.where((item) => item.id != stake.id)],
        walletBalancePaisa: balance,
        busy: false,
        clearError: true,
      );
      return stake;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final lendingControllerProvider =
    NotifierProvider<LendingController, LendingState>(LendingController.new);
