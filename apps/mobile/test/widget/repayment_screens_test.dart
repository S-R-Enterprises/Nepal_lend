import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/notifications/presentation/notifications_screen.dart';
import 'package:nepal_lend/features/repayments/data/repayment_controller.dart';
import 'package:nepal_lend/features/repayments/presentation/repayment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 120; i++) {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $finder');
}

/// Dio's mock adapter schedules a zero-delay timer; give it time to drain so
/// the test binding does not report a pending timer at disposal.
Future<void> _pumpIdle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late ProviderContainer container;
  late String borrowerId;
  const loanId = 'loan-widget';
  const lenderId = 'lender-widget';
  const amount = 300000;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    DemoClock.instance.reset();
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
    final auth = container.read(authProvider.notifier);
    await auth.demoSignIn();
    await auth.setRole(UserRole.borrower);
    await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    await auth.refresh();
    borrowerId = container.read(authProvider).user!.id;
  });

  tearDown(() {
    DemoClock.instance.reset();
    container.dispose();
  });

  Future<void> seedRepayableLoan() async {
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
        id: 'stake-widget',
        loanId: loanId,
        lenderId: lenderId,
        amountPaisa: amount,
        idempotencyKey: 'fund-widget',
        fundingJournalId: 'txn-fund-widget',
        createdAt: start,
      ),
    );
    const journalId = 'txn-widget-topup';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-widget-topup',
      idempotencyKey: 'widget-topup',
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

  Widget shell({required String initialLocation}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/borrower/repay/:id',
          builder: (context, state) => RepaymentScreen(
            loanId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/wallet/transactions/:id',
          builder: (context, state) =>
              Text('Receipt ${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    );
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('repay screen confirms and posts one instalment journal',
      (tester) async {
    // Test views use a 3x device pixel ratio, so multiply logical sizes by 3.
    // A tall view keeps the confirmation sheet fully on-screen for the tap.
    tester.view.physicalSize = const Size(2400, 5400);
    addTearDown(() => tester.view.physicalSize = const Size(2400, 1800));
    await seedRepayableLoan();
    await tester.pumpWidget(
      shell(initialLocation: '/borrower/repay/$loanId'),
    );

    await _pumpUntil(tester, find.text('Instalment 1 of 3'));
    expect(find.textContaining('Platform fee (10% of interest)'), findsOneWidget);
    final payButton = find.textContaining('Pay NPR').first;
    await tester.ensureVisible(payButton);
    await tester.pump();

    await tester.tap(payButton);
    await _pumpUntil(tester, find.text('Confirm repayment'));
    // The modal sheet enters from below; let its entrance animation settle so
    // the confirm button is hit-testable at its final on-screen position.
    await _pumpIdle(tester);
    final confirm = find.text('Pay instalment');
    await tester.ensureVisible(confirm);
    await tester.pump();
    await tester.tap(confirm);
    await _pumpUntil(tester, find.textContaining('Receipt txn-repay-'));

    expect(
      MockDb.instance.journals
          .where((item) => item.kind == JournalKind.repayment),
      hasLength(1),
    );
    final loan = MockDb.instance.loan(loanId)!;
    expect(loan.paidInstalmentCount, 1);
    expect(container.read(repaymentControllerProvider).next?.number, 2);
    await _pumpIdle(tester);
  });

  testWidgets('notification inbox shows the demo clock and marks all read',
      (tester) async {
    await MockDb.instance.setNotification(
      AppNotification(
        id: 'notif-widget',
        userId: borrowerId,
        type: NotificationType.paymentReceived,
        title: 'Repayment recorded',
        body: 'Instalment 1 was paid.',
        createdAt: DateTime(2026, 1, 2),
        route: '/borrower/repay/$loanId',
      ),
    );
    await tester.pumpWidget(shell(initialLocation: '/notifications'));

    await _pumpUntil(tester, find.textContaining('Demo clock'));
    await _pumpUntil(tester, find.text('Repayment recorded'));
    expect(find.text('1 unread'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await _pumpUntil(tester, find.text('You are all caught up'));
    expect(
      MockDb.instance.notificationsFor(borrowerId).first.isRead,
      isTrue,
    );
    await _pumpIdle(tester);
  });

  testWidgets('advancing the demo clock refreshes the displayed date',
      (tester) async {
    await tester.pumpWidget(shell(initialLocation: '/notifications'));
    await _pumpUntil(tester, find.textContaining('Demo clock'));

    final before = tester.widget<Text>(find.textContaining('Demo clock')).data;
    DemoClock.instance.advance(const Duration(days: 1));
    await tester.pump();
    final after = tester.widget<Text>(find.textContaining('Demo clock')).data;
    expect(after, isNot(before));
    await _pumpIdle(tester);
  });
}
