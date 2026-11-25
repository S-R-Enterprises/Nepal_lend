import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'u-property';
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
  });

  test('random journal sequences stay balanced and never overdraw a wallet',
      () async {
    final random = Random(20261125);
    var expectedBalance = 0;

    for (var i = 0; i < 200; i++) {
      final amount = 100000 + random.nextInt(500000);
      final canWithdraw = expectedBalance >= amount;
      final isTopup = !canWithdraw || random.nextBool();
      final walletDelta = isTopup ? amount : -amount;
      final journalId = 'txn-p-$i';

      final receipt = await MockDb.instance.postJournal(
        journalId: journalId,
        paymentIntentId: 'pi-p-$i',
        idempotencyKey: 'key-p-$i',
        kind: isTopup ? JournalKind.topup : JournalKind.withdrawal,
        intentKind: isTopup
            ? PaymentIntentKind.topup
            : PaymentIntentKind.withdrawal,
        userId: userId,
        referenceId: 'sim-p-$i',
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

      expect(receipt.replayed, isFalse);
      expectedBalance += walletDelta;
      expect(MockDb.instance.balanceFor(wallet), expectedBalance);
      expect(expectedBalance, greaterThanOrEqualTo(0));
    }

    expect(MockDb.instance.journals, hasLength(200));
    for (final journal in MockDb.instance.journals) {
      expect(journal.sumPaisa, 0);
    }
  });

  test('replaying one idempotency key never appends a second journal',
      () async {
    Future<void> post(String key, String journalId) =>
        MockDb.instance.postJournal(
          journalId: journalId,
          paymentIntentId: 'pi-$journalId',
          idempotencyKey: key,
          kind: JournalKind.topup,
          intentKind: PaymentIntentKind.topup,
          userId: userId,
          referenceId: 'sim-$journalId',
          amountPaisa: 100000,
          entries: [
            LedgerEntry(
              id: '$journalId-1',
              journalId: journalId,
              accountId: wallet,
              amountPaisa: 100000,
            ),
            LedgerEntry(
              id: '$journalId-2',
              journalId: journalId,
              accountId: LedgerAccount.externalCash,
              amountPaisa: -100000,
            ),
          ],
        );

    await post('stable-key', 'txn-idempotent-1');
    final replay = await MockDb.instance.postJournal(
      journalId: 'txn-idempotent-2',
      paymentIntentId: 'pi-txn-idempotent-2',
      idempotencyKey: 'stable-key',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: userId,
      referenceId: 'sim-idempotent-2',
      amountPaisa: 100000,
      entries: const [],
    );

    expect(replay.replayed, isTrue);
    expect(replay.journalId, 'txn-idempotent-1');
    expect(MockDb.instance.journals, hasLength(1));
    expect(MockDb.instance.balanceFor(wallet), 100000);
  });
}
