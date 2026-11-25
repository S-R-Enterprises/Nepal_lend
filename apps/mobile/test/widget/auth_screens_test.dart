import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/presentation/login_screen.dart';
import 'package:nepal_lend/features/auth/presentation/otp_screen.dart';
import 'package:nepal_lend/features/auth/presentation/role_selection_screen.dart';

Widget _app(ProviderContainer container, String initialLocation) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
          GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
          GoRoute(
            path: '/role-selection',
            builder: (context, state) => const RoleSelectionScreen(),
          ),
        ],
      ),
    ),
  );
}

void main() {
  late ProviderContainer container;

  setUp(() async {
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
  });

  tearDown(() => container.dispose());

  testWidgets('login rejects a phone number that is not Nepali', (tester) async {
    await tester.pumpWidget(_app(container, '/login'));
    await tester.tap(find.text('Send code'));
    await tester.pump();

    expect(
      find.text('Enter a valid 10-digit Nepali mobile number.'),
      findsOneWidget,
    );
  });

  testWidgets('otp resend timer counts down to a resend button', (tester) async {
    await container.read(authProvider.notifier).sendCode('9800000000');
    await tester.pumpWidget(_app(container, '/otp'));

    expect(find.textContaining('Resend in'), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
    expect(find.text('Resend code'), findsOneWidget);
  });

  testWidgets('otp shows the wrong-code error inline', (tester) async {
    await container.read(authProvider.notifier).sendCode('9800000000');
    await tester.pumpWidget(_app(container, '/otp'));

    await tester.enterText(find.byType(TextFormField).first, '111111');
    await tester.tap(find.text('Verify and continue'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('That code is not correct.'), findsOneWidget);
  });

  testWidgets('role selection offers borrower and lender', (tester) async {
    await tester.pumpWidget(_app(container, '/role-selection'));

    expect(find.text('Continue as borrower'), findsOneWidget);
    expect(find.text('Continue as lender'), findsOneWidget);
  });
}
