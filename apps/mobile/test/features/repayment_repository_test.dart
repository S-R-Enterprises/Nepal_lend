import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/repositories/notifications_repository.dart';
import 'package:nepal_lend/data/repositories/repayment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late RepaymentRepository repayment;
  late NotificationsRepository notifications;
  const loanId = 'loan-api';
  const borrowerId = 'borrower-1';
  const lenderId = 'lender-1';
  const amount = 300000;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
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
    repayment = container.read(repaymentRepositoryProvider);
    notifications = container.read(notificationsRepositoryProvider);
    await MockDb.instance.setUser(
      const AppUser(
        id: borrowerId,
        phone: '+9779800000000',
        role: UserRole.borrower,
        kycState: KycStatus.verified,
      ),
    );
  });

  tearDown(() => container.dispose());

  Future<void> seedActiveLoan() async {
    final start = DateTime(2026, 1, 1);
    final schedule = Money.schedule(
      principalPaisa: amount,
      rateBps: 1200,
      tenorMonths: 3,
      startDate: start,
    );
    await MockDb.instance.setLoan(
      Loan(
        id: loanId,
        borrowerId: borrowerId,
        purpose: 'Business inventory',
        amountPaisa: amount,
        tenorMonths: 3,
        rateBps: 1200,
        status: LoanStatus.active,
        fundedPaisa: amount,
        agreement: Agreement(
          id: 'agr-$loanId',
          loanId: loanId,
          termsVersion: 'v1',
          termsHash: 'hash',
          signedBy: 'Test Borrower',
          signedAt: start,
          disbursementJournalId: 'txn-disburse-$loanId',
        ),
        instalments: schedule
            .map(
              (item) => Instalment(
                id: '$loanId-inst-${item.number}',
                loanId: loanId,
                number: item.number,
                dueDate: item.dueDate,
                principalPaisa: item.principalPaisa,
                interestPaisa: item.interestPaisa,
              ),
            )
            .toList(growable: false),
      ),
    );
    await MockDb.instance.setStake(
      Stake(
        id: 'stake-api',
        loanId: loanId,
        lenderId: lenderId,
        amountPaisa: amount,
        idempotencyKey: 'fund-api',
        fundingJournalId: 'txn-fund-api',
        createdAt: start,
      ),
    );
    const journalId = 'txn-api-topup';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-api-topup',
      idempotencyKey: 'api-topup',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: borrowerId,
      referenceId: 'demo',
      amountPaisa: amount * 2,
      entries: [
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -amount * 2,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.userWallet(borrowerId),
          amountPaisa: amount * 2,
        ),
      ],
    );
  }

  test('repay endpoint posts one journal and feeds the notification inbox',
      () async {
    await seedActiveLoan();

    final outcome = await repayment.pay(
      loanId: loanId,
      instalmentNumber: 1,
      provider: 'esewa',
      idempotencyKey: 'api-repay-1',
    );

    expect(outcome.receipt.kind, PaymentIntentKind.repayment);
    expect(outcome.instalment.isPaid, isTrue);
    final items = await notifications.mine();
    expect(items, isNotEmpty);
    expect(items.any((item) => item.title == 'Repayment recorded'), isTrue);

    final unread = items.where((item) => item.isUnread).length;
    final changed = await notifications.markRead(items.first.id);
    expect(changed, 1);
    final afterOne = await notifications.mine();
    expect(
      afterOne.where((item) => item.isUnread).length,
      unread - 1,
    );
    await notifications.markAllRead();
    expect((await notifications.mine()).every((item) => item.isRead), isTrue);
  });

  test('repay endpoint enforces borrower role and verified KYC', () async {
    await seedActiveLoan();
    await MockDb.instance.setUser(
      const AppUser(
        id: lenderId,
        phone: '+9779800000001',
        role: UserRole.lender,
        kycState: KycStatus.verified,
      ),
    );
    await expectLater(
      repayment.pay(
        loanId: loanId,
        instalmentNumber: 1,
        provider: 'esewa',
        idempotencyKey: 'api-wrong-role',
      ),
      throwsA(
        isA<AppFailure>()
            .having((error) => error.code, 'code', 'role_required'),
      ),
    );

    await MockDb.instance.setUser(
      const AppUser(
        id: borrowerId,
        phone: '+9779800000000',
        role: UserRole.borrower,
        kycState: KycStatus.notStarted,
      ),
    );
    await expectLater(
      repayment.pay(
        loanId: loanId,
        instalmentNumber: 1,
        provider: 'esewa',
        idempotencyKey: 'api-unverified',
      ),
      throwsA(
        isA<AppFailure>()
            .having((error) => error.code, 'code', 'kyc_required'),
      ),
    );
  });

  test('job endpoints report reminders, overdue markers and a clean ledger',
      () async {
    await seedActiveLoan();
    expect(await repayment.sendReminders(), 1);
    expect(await repayment.markOverdue(), 1);
    final reconciliation = await repayment.reconcile();
    expect(reconciliation.journalsChecked, greaterThan(0));
    expect(reconciliation.isClean, isTrue);
    expect(
      (await notifications.mine())
          .where((item) => item.type == NotificationType.paymentDue),
      isNotEmpty,
    );
  });
}
