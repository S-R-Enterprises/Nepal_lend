import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';

JournalTransaction _journal({
  required String id,
  required String wallet,
  required int walletDelta,
  JournalKind kind = JournalKind.topup,
}) =>
    JournalTransaction(
      id: id,
      kind: kind,
      referenceId: 'sim-$id',
      idempotencyKey: 'key-$id',
      createdAt: DateTime(2026, 1, 15),
      entries: [
        LedgerEntry(
          id: '$id-1',
          journalId: id,
          accountId: wallet,
          amountPaisa: walletDelta,
        ),
        LedgerEntry(
          id: '$id-2',
          journalId: id,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -walletDelta,
        ),
      ],
    );

void main() {
  const wallet = 'user_wallet:u1';

  test('account ids are stable and wallet detection works', () {
    expect(LedgerAccount.userWallet('u1'), wallet);
    expect(LedgerAccount.loanEscrow('loan-1'), 'loan_escrow:loan-1');
    expect(LedgerAccount.platformFee, 'platform_fee');
    expect(LedgerAccount.isUserWallet(wallet), isTrue);
    expect(LedgerAccount.isUserWallet(LedgerAccount.externalCash), isFalse);
  });

  test('journal json round-trips with signed entries', () {
    final journal = _journal(id: 'txn-1', wallet: wallet, walletDelta: 100000);
    final decoded = JournalTransaction.fromJson(journal.toJson());

    expect(decoded.id, 'txn-1');
    expect(decoded.kind, JournalKind.topup);
    expect(decoded.sumPaisa, 0);
    expect(decoded.amountFor(wallet), 100000);
    expect(decoded.entries, hasLength(2));
  });

  test('unbalanced journals are rejected', () {
    final entries = [
      LedgerEntry(
        id: 'e1',
        journalId: 'txn-2',
        accountId: wallet,
        amountPaisa: 100,
      ),
    ];
    expect(
      () => assertBalancedJournal(entries),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'ledger_unbalanced',
        ),
      ),
    );
  });

  test('wallet transaction is derived from the journal', () {
    final journal = _journal(
      id: 'txn-3',
      wallet: wallet,
      walletDelta: -250000,
      kind: JournalKind.withdrawal,
    );
    final tx = WalletTransaction.fromJournal(journal, wallet);

    expect(tx.id, 'txn-3');
    expect(tx.kind, JournalKind.withdrawal);
    expect(tx.title, 'Withdrawal');
    expect(tx.amountPaisa, -250000);
  });
}
