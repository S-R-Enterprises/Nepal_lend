import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/repositories/ledger_repository.dart';
import 'package:nepal_lend/features/kyc/data/kyc_gate.dart';
import 'package:nepal_lend/features/wallet/data/payment_provider.dart';
import 'package:uuid/uuid.dart';

class WalletState {
  const WalletState({
    this.snapshot,
    this.journal,
    this.busy = false,
    this.error,
    this.lastReceipt,
  });

  final WalletSnapshot? snapshot;
  final JournalTransaction? journal;
  final bool busy;
  final String? error;
  final PaymentReceipt? lastReceipt;

  WalletState copyWith({
    WalletSnapshot? snapshot,
    JournalTransaction? journal,
    bool? busy,
    String? error,
    bool clearError = false,
    PaymentReceipt? lastReceipt,
  }) {
    return WalletState(
      snapshot: snapshot ?? this.snapshot,
      journal: journal ?? this.journal,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
      lastReceipt: lastReceipt ?? this.lastReceipt,
    );
  }
}

/// All money movement goes through this controller. The KYC gate is checked
/// here, not only by the router, so a deep link cannot bypass verification.
class WalletController extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  LedgerRepository get _ledger => ref.read(ledgerRepositoryProvider);
  PaymentProvider get _payments => ref.read(paymentProviderProvider);
  AppUser get _user => ref.read(requireVerifiedUserProvider)();

  Future<void> load() async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      final user = _user;
      final snapshot = await _ledger.loadWallet(user.id);
      state = state.copyWith(snapshot: snapshot, busy: false, clearError: true);
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  Future<void> loadJournal(String id) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      final journal = await _ledger.journal(id);
      state = state.copyWith(journal: journal, busy: false, clearError: true);
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  Future<PaymentReceipt?> topUp(
    int amountPaisa, {
    String? idempotencyKey,
  }) =>
      _move(
        kind: PaymentIntentKind.topup,
        amountPaisa: amountPaisa,
        idempotencyKey: idempotencyKey,
      );

  Future<PaymentReceipt?> withdraw(
    int amountPaisa, {
    String? idempotencyKey,
  }) =>
      _move(
        kind: PaymentIntentKind.withdrawal,
        amountPaisa: amountPaisa,
        idempotencyKey: idempotencyKey,
      );

  Future<PaymentReceipt?> _move({
    required PaymentIntentKind kind,
    required int amountPaisa,
    String? idempotencyKey,
  }) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      final user = _user;
      if (amountPaisa < ProductRules.minStakePaisa) {
        throw AppFailure('below_minimum', messageFor('below_minimum'));
      }
      if (kind == PaymentIntentKind.withdrawal) {
        if (state.snapshot == null) await load();
        final balance = state.snapshot?.balancePaisa ?? 0;
        if (balance < amountPaisa) {
          throw AppFailure(
            'insufficient_balance',
            messageFor('insufficient_balance'),
          );
        }
      }

      final key = idempotencyKey ?? '${kind.name}-${const Uuid().v4()}';
      final journalId = 'txn-${const Uuid().v4()}';
      final intentId = 'pi-${const Uuid().v4()}';
      final payment = kind == PaymentIntentKind.topup
          ? await _payments.charge(
              amountPaisa: amountPaisa,
              idempotencyKey: key,
            )
          : await _payments.payout(
              amountPaisa: amountPaisa,
              idempotencyKey: key,
            );

      final wallet = LedgerAccount.userWallet(user.id);
      final entries = <LedgerEntry>[
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: wallet,
          amountPaisa:
              kind == PaymentIntentKind.topup ? amountPaisa : -amountPaisa,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa:
              kind == PaymentIntentKind.topup ? -amountPaisa : amountPaisa,
        ),
      ];

      final receipt = await _ledger.postJournal(
        journalId: journalId,
        paymentIntentId: intentId,
        idempotencyKey: key,
        kind: kind == PaymentIntentKind.topup
            ? JournalKind.topup
            : JournalKind.withdrawal,
        intentKind: kind,
        userId: user.id,
        referenceId: payment.reference,
        amountPaisa: amountPaisa,
        entries: entries,
      );
      final refreshed = await _ledger.loadWallet(user.id);
      state = state.copyWith(
        snapshot: refreshed,
        lastReceipt: receipt,
        busy: false,
        clearError: true,
      );
      return receipt;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  Future<PaymentReceipt?> reverse(
    String originalJournalId,
    int amountPaisa, {
    required String idempotencyKey,
  }) async {
    try {
      state = state.copyWith(busy: true, clearError: true);
      final user = _user;
      final receipt = await _ledger.reverseJournal(
        journalId: 'txn-${const Uuid().v4()}',
        paymentIntentId: 'pi-${const Uuid().v4()}',
        idempotencyKey: idempotencyKey,
        userId: user.id,
        intentKind: PaymentIntentKind.withdrawal,
        amountPaisa: amountPaisa,
        originalJournalId: originalJournalId,
      );
      final refreshed = await _ledger.loadWallet(user.id);
      state = state.copyWith(
        snapshot: refreshed,
        lastReceipt: receipt,
        busy: false,
        clearError: true,
      );
      return receipt;
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(WalletController.new);
