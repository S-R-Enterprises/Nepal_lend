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
import 'package:nepal_lend/features/kyc/data/kyc_controller.dart';
import 'package:nepal_lend/features/kyc/presentation/kyc_checklist_screen.dart';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50; i++) {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _shell(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/kyc',
        routes: [
          GoRoute(
            path: '/kyc',
            builder: (context, state) => const KycChecklistScreen(),
          ),
          GoRoute(
            path: '/borrower/home',
            builder: (context, state) => const Text('Borrower home'),
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
    MockDb.instance.kycProfile = KycProfile.initial();
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
  });

  tearDown(() => container.dispose());

  testWidgets('checklist renders steps and demo approval unlocks the shell',
      (tester) async {
    await tester.pumpWidget(_shell(container));
    await _pumpUntil(tester, find.textContaining('Citizenship document'));

    expect(find.textContaining('Citizenship document'), findsOneWidget);
    expect(find.textContaining('Selfie'), findsOneWidget);
    expect(container.read(kycProvider).profile.steps, hasLength(4));
    expect(
      container.read(kycProvider).profile.steps.map((step) => step.status),
      everyElement(KycStatus.notStarted),
    );

    await _pumpUntil(tester, find.text('Approve all steps'));
    await tester.ensureVisible(find.text('Approve all steps'));
    await tester.tap(find.text('Approve all steps'));
    await _pumpUntil(tester, find.text('Borrower home'));

    expect(container.read(authProvider).user?.isVerified, isTrue);
  });
}
