import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/lending/presentation/fund_loan_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_browse_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $finder');
}

/// Lets the post-frame callback and the mock HTTP future finish before the
/// widget tree is disposed. `pumpAndSettle` can hang on Dio's zero-delay timer.
Future<void> _pumpLendingIdle(
  WidgetTester tester,
  ProviderContainer container,
) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (i > 1 && !container.read(lendingControllerProvider).busy) {
      await tester.pump(const Duration(milliseconds: 50));
      return;
    }
  }
  fail('Lending controller stayed busy');
}

void main() {
  late ProviderContainer container;
  late String lenderId;

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
    final auth = container.read(authProvider.notifier);
    await auth.demoSignIn();
    await auth.setRole(UserRole.lender);
    await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    await auth.refresh();
    lenderId = container.read(authProvider).user!.id;
  });

  tearDown(() => container.dispose());

  Future<void> seedLoan() => MockDb.instance.setLoan(
        Loan(
          id: 'loan-1',
          borrowerId: 'borrower-1',
          purpose: 'Business inventory',
          amountPaisa: 20000000,
          tenorMonths: 12,
          rateBps: 1200,
          status: LoanStatus.open,
          borrowerName: 'Test Borrower',
          riskGrade: 'A',
          riskBand: RiskBand.low,
          fundingDeadline: DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  Future<void> topUp(int amount) async {
    const journalId = 'txn-test-topup-widget';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-test-topup-widget',
      idempotencyKey: 'test-topup-widget',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: lenderId,
      referenceId: 'demo',
      amountPaisa: amount,
      entries: [
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -amount,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.userWallet(lenderId),
          amountPaisa: amount,
        ),
      ],
    );
  }

  Widget shell({required String initialLocation}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/lender/browse',
          builder: (context, state) => const LenderBrowseScreen(),
        ),
        GoRoute(
          path: '/lender/loan-details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return Scaffold(
              appBar: AppBar(title: const Text('Loan details')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.go('/lender/fund-loan/$id'),
                  child: const Text('Fund this loan'),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/lender/fund-loan/:id',
          builder: (context, state) => FundLoanScreen(
            loanId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/stakes/:id',
          builder: (context, state) =>
              Text('Receipt ${state.pathParameters['id']}'),
        ),
      ],
    );
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('browse shows an empty state when no loans match', (tester) async {
    await tester.pumpWidget(shell(initialLocation: '/lender/browse'));

    await _pumpLendingIdle(tester, container);
    expect(find.text('No loans match'), findsOneWidget);
    expect(find.text('Fund a verified borrower'), findsOneWidget);
    expect(MockDb.instance.stakes, isEmpty);
  });

  testWidgets('browse → fund → stake receipt posts one balanced stake',
      (tester) async {
    await seedLoan();
    await topUp(20000000);
    await tester.pumpWidget(shell(initialLocation: '/lender/browse'));

    await _pumpLendingIdle(tester, container);
    expect(find.text('Business inventory'), findsOneWidget);
    expect(find.text('Open loans'), findsOneWidget);
    final card = find.ancestor(
      of: find.text('Business inventory'),
      matching: find.byType(InkWell),
    );
    await tester.scrollUntilVisible(
      card.first,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(card.first);

    await _pumpUntil(tester, find.text('Fund this loan'));
    await tester.tap(find.text('Fund this loan'));

    await _pumpUntil(tester, find.text('Fund loan'));
    await _pumpLendingIdle(tester, container);
    await _pumpUntil(tester, find.text('Confirm funding'));

    final amountField = find.byType(TextFormField);
    expect(amountField, findsOneWidget);

    await tester.enterText(amountField, '500');
    await tester.tap(find.text('Confirm funding'));
    await tester.pump();
    expect(find.textContaining('minimum stake'), findsOneWidget);
    expect(MockDb.instance.stakes, isEmpty);

    await tester.enterText(amountField, '200000');
    await tester.tap(find.text('Confirm funding'));

    await _pumpUntil(tester, find.textContaining('Receipt stake-'));
    await _pumpLendingIdle(tester, container);
    expect(MockDb.instance.stakes, hasLength(1));
    expect(MockDb.instance.balanceFor(LedgerAccount.loanEscrow('loan-1')),
        20000000);
    expect(MockDb.instance.balanceFor(LedgerAccount.userWallet(lenderId)), 0);
    expect(MockDb.instance.loan('loan-1')!.status, LoanStatus.funded);
  });
}
