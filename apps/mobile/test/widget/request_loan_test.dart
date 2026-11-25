import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/loans/presentation/request_loan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 60; i++) {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _shell(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/borrower/request-loan',
    routes: [
      GoRoute(
        path: '/borrower/request-loan',
        builder: (context, state) => const RequestLoanScreen(),
      ),
      GoRoute(
        path: '/borrower/risk-review/:id',
        builder: (context, state) => Text(
          'Risk review ${state.pathParameters['id']}',
        ),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late ProviderContainer container;

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
    await container.read(authProvider.notifier).demoSignIn();
    await container.read(authProvider.notifier).setRole(UserRole.borrower);
    await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    await container.read(authProvider.notifier).refresh();
  });

  tearDown(() => container.dispose());

  testWidgets('request form validates and navigates to risk review',
      (tester) async {
    await tester.pumpWidget(_shell(container));
    await _pumpUntil(tester, find.text('Request a loan'));

    await tester.tap(find.text('See my risk grade'));
    await tester.pump();
    expect(find.text('Describe the purpose.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Business inventory');
    await tester.enterText(fields.at(1), '200000');
    await tester.enterText(fields.at(2), '12');
    await tester.enterText(fields.at(3), '50000');
    await tester.tap(find.text('See my risk grade'));

    await _pumpUntil(tester, find.textContaining('Risk review loan-'));
    expect(find.textContaining('Risk review loan-'), findsOneWidget);
    expect(MockDb.instance.loans, hasLength(1));
    final loan = MockDb.instance.loans.values.single;
    expect(loan.amountPaisa, 20000000);
    expect(loan.riskGrade, 'A');
  });
}
