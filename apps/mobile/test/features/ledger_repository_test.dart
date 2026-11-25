import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/repositories/ledger_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late LedgerRepository repository;
  const userId = 'u1';
  final wallet = LedgerAccount.userWallet(userId);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    await MockDb.instance.setUser(
      const AppUser(
        id: userId,
        phone: '+9779800000000',
        role: UserRole.lender,
        kycState: KycStatus.verified,
      ),
    );
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
    repository = container.read(ledgerRepositoryProvider);
  });

  tearDown(() => container.dispose());

  Future<dynamic> post({
    required String key,
    required String journalId,
    required int walletDelta,
    PaymentIntentKind kind = PaymentIntentKind.topup,
  }) {
    final amount = walletDelta.abs();
    return repository.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-$journalId',
      idempotencyKey: key,
      kind: kind == PaymentIntentKind.topup
          ? JournalKind.topup
          : JournalKind.withdrawal,
      intentKind: kind,
      userId: userId,
      referenceId: 'sim-$journalId',
      amountPaisa: amount,
      entries: [
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: wallet,
          amountPaisa: walletDelta,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -walletDelta,
        ),
      ],
    );
  }

  test('top-up posts a balanced journal and updates the wallet snapshot',
      () async {
    final receipt = await post(key: 'topup-1', journalId: 'txn-1', walletDelta: 1000000);

    expect(receipt.replayed, isFalse);
    expect(MockDb.instance.journals, hasLength(1));
    expect(MockDb.instance.journals.single.sumPaisa, 0);
    expect(MockDb.instance.balanceFor(wallet), 1000000);

    final snapshot = await repository.loadWallet(userId);
    expect(snapshot.balancePaisa, 1000000);
    expect(snapshot.transactions, hasLength(1));
    expect(snapshot.transactions.single.title, 'Wallet top-up');
  });

  test('withdrawal reduces balance and overdrafts are rejected', () async {
    await post(key: 'topup-2', journalId: 'txn-2', walletDelta: 1000000);
    await post(
      key: 'withdraw-2',
      journalId: 'txn-3',
      walletDelta: -250000,
      kind: PaymentIntentKind.withdrawal,
    );

    expect(MockDb.instance.balanceFor(wallet), 750000);

    expect(
      () => post(
        key: 'withdraw-too-much',
        journalId: 'txn-4',
        walletDelta: -800000,
        kind: PaymentIntentKind.withdrawal,
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'insufficient_balance',
        ),
      ),
    );
    expect(MockDb.instance.journals, hasLength(2));
  });

  test('replaying an idempotency key returns the original receipt', () async {
    await post(key: 'same-key', journalId: 'txn-5', walletDelta: 500000);
    final replay = await post(
      key: 'same-key',
      journalId: 'txn-6',
      walletDelta: 500000,
    );

    expect(replay.replayed, isTrue);
    expect(replay.journalId, 'txn-5');
    expect(MockDb.instance.journals, hasLength(1));
    expect(MockDb.instance.balanceFor(wallet), 500000);
  });

  test('reversal negates the original journal', () async {
    final original =
        await post(key: 'topup-7', journalId: 'txn-7', walletDelta: 600000);
    final reversal = await repository.reverseJournal(
      journalId: 'txn-8',
      paymentIntentId: 'pi-txn-8',
      idempotencyKey: 'reverse-txn-7',
      userId: userId,
      intentKind: PaymentIntentKind.withdrawal,
      amountPaisa: 600000,
      originalJournalId: original.journalId,
    );

    expect(reversal.replayed, isFalse);
    expect(MockDb.instance.journals, hasLength(2));
    expect(MockDb.instance.journals.last.sumPaisa, 0);
    expect(MockDb.instance.journals.last.reversalOfId, 'txn-7');
    expect(MockDb.instance.balanceFor(wallet), 0);
  });
}
