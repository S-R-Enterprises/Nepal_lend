import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/repositories/ledger_repository.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/wallet/data/payment_provider.dart';
import 'package:nepal_lend/features/wallet/data/wallet_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLedgerRepository implements LedgerRepository {
  final List<JournalTransaction> journals = <JournalTransaction>[];
  final Map<String, PaymentReceipt> receipts = <String, PaymentReceipt>{};
  int _balance = 0;

  @override
  Future<WalletSnapshot> loadWallet(String userId) async => WalletSnapshot(
        accountId: LedgerAccount.userWallet(userId),
        balancePaisa: _balance,
        transactions: journals
            .map(
              (journal) =>
                  WalletTransaction.fromJournal(journal, journal.entries.first.accountId),
            )
            .toList(growable: false),
      );

  @override
  Future<PaymentReceipt> postJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required JournalKind kind,
    required PaymentIntentKind intentKind,
    required String userId,
    required String referenceId,
    required int amountPaisa,
    required List<LedgerEntry> entries,
    String? reversalOfId,
  }) async {
    final existing = receipts[idempotencyKey];
    if (existing != null) return existing.copyWith(replayed: true);

    final wallet = LedgerAccount.userWallet(userId);
    final delta = entries
        .where((entry) => entry.accountId == wallet)
        .fold<int>(0, (sum, entry) => sum + entry.amountPaisa);
    if (_balance + delta < 0) {
      throw const AppFailure('insufficient_balance', 'Balance too low.');
    }

    final journal = JournalTransaction(
      id: journalId,
      kind: kind,
      referenceId: referenceId,
      idempotencyKey: idempotencyKey,
      createdAt: DateTime(2026, 1, 15),
      entries: entries,
      reversalOfId: reversalOfId,
    );
    journals.add(journal);
    _balance += delta;
    final receipt = PaymentReceipt(
      id: journalId,
      journalId: journalId,
      paymentIntentId: paymentIntentId,
      idempotencyKey: idempotencyKey,
      kind: intentKind,
      amountPaisa: amountPaisa,
      createdAt: journal.createdAt,
      referenceId: referenceId,
    );
    receipts[idempotencyKey] = receipt;
    return receipt;
  }

  @override
  Future<JournalTransaction> journal(String id) =>
      Future.value(journals.firstWhere((item) => item.id == id));

  @override
  Future<PaymentReceipt> reverseJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required String userId,
    required PaymentIntentKind intentKind,
    required int amountPaisa,
    required String originalJournalId,
  }) =>
      throw UnimplementedError('Reversal is covered by repository tests.');
}

void main() {
  late ProviderContainer container;
  late FakeLedgerRepository ledger;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    ledger = FakeLedgerRepository();
    container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
        ledgerRepositoryProvider.overrideWithValue(ledger),
        simulatedPaymentProviderProvider
            .overrideWithValue(SimulatedPaymentProvider()),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> signIn({bool verified = true}) async {
    await container.read(authProvider.notifier).demoSignIn();
    await container.read(authProvider.notifier).setRole(UserRole.lender);
    if (verified) {
      await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    }
    await container.read(authProvider.notifier).refresh();
  }

  test('unverified users are blocked by the provider gate', () async {
    await signIn(verified: false);
    final controller = container.read(walletControllerProvider.notifier);

    final receipt = await controller.topUp(100000);

    expect(receipt, isNull);
    expect(
      container.read(walletControllerProvider).error,
      contains('verification'),
    );
    expect(ledger.journals, isEmpty);
  });

  test('top-up moves through the payment provider into the ledger', () async {
    await signIn();
    final controller = container.read(walletControllerProvider.notifier);

    final receipt = await controller.topUp(1000000, idempotencyKey: 'topup-1');

    expect(receipt, isNotNull);
    expect(receipt!.amountPaisa, 1000000);
    expect(ledger.journals, hasLength(1));
    expect(ledger.journals.single.sumPaisa, 0);
    expect(
      container.read(walletControllerProvider).snapshot?.balancePaisa,
      1000000,
    );
  });

  test('withdrawals cannot exceed the wallet balance', () async {
    await signIn();
    final controller = container.read(walletControllerProvider.notifier);
    await controller.topUp(100000, idempotencyKey: 'seed');

    final receipt = await controller.withdraw(200000, idempotencyKey: 'over');

    expect(receipt, isNull);
    expect(container.read(walletControllerProvider).error, isNotNull);
    expect(ledger.journals, hasLength(1));
  });

  test('a failed payment never posts a journal', () async {
    await signIn();
    container.read(simulatedPaymentProviderProvider).failNextPayment();

    final receipt =
        await container.read(walletControllerProvider.notifier).topUp(200000);

    expect(receipt, isNull);
    expect(
      container.read(walletControllerProvider).error,
      contains('payment'),
    );
    expect(ledger.journals, isEmpty);
  });

  test('replaying an idempotency key reuses the receipt', () async {
    await signIn();
    final controller = container.read(walletControllerProvider.notifier);

    final first = await controller.topUp(300000, idempotencyKey: 'same');
    final replay = await controller.topUp(300000, idempotencyKey: 'same');

    expect(first?.replayed, isFalse);
    expect(replay?.replayed, isTrue);
    expect(replay?.journalId, first?.journalId);
    expect(ledger.journals, hasLength(1));
    expect(
      container.read(walletControllerProvider).snapshot?.balancePaisa,
      300000,
    );
  });
}
