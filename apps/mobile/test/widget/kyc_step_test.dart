import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
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
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_controller.dart';
import 'package:nepal_lend/features/kyc/presentation/kyc_step_screen.dart';

class _FakePicker implements DocumentPicker {
  const _FakePicker(this.path);

  final String path;

  @override
  Future<PickedDocument?> pick(PickSource source) async => PickedDocument(
        path: path,
        name: 'document.png',
      );
}

const _onePixelPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl2nKkAAAAASUVORK5CYII=';

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50; i++) {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The mock adapter resolves after 80 ms; give it room without waiting on the
/// finite animations that `pumpAndSettle` would keep chasing.
Future<void> _settleTimers(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
  await tester.pump();
}

Widget _shell(ProviderContainer container, String location) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: '/kyc/:step',
            builder: (context, state) {
              final name = state.pathParameters['step'];
              final kind = KycStepKind.values
                  .where((item) => item.name == name)
                  .firstOrNull;
              return kind == null
                  ? const SizedBox.shrink()
                  : KycStepScreen(kind: kind);
            },
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
    final image = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}nepallend_test_document.png',
    );
    await image.writeAsBytes(base64Decode(_onePixelPng));
    container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
        documentPickerProvider.overrideWithValue(_FakePicker(image.path)),
      ],
    );
    await container.read(authProvider.notifier).demoSignIn();
    await container.read(authProvider.notifier).setRole(UserRole.borrower);
  });

  tearDown(() => container.dispose());

  testWidgets('document step renders capture actions', (tester) async {
    await tester.pumpWidget(_shell(container, '/kyc/selfie'));
    await _pumpUntil(tester, find.text('Take photo'));
    await _pumpUntil(tester, find.text('Submit for review'));
    await _settleTimers(tester);

    expect(
      container.read(kycProvider).profile.step(KycStepKind.selfie).status,
      KycStatus.notStarted,
    );
    expect(find.text('Choose from gallery'), findsOneWidget);
  });

  testWidgets('personal details form validates required fields',
      (tester) async {
    await tester.pumpWidget(_shell(container, '/kyc/personalDetails'));
    await _pumpUntil(tester, find.text('Submit for review'));
    await _settleTimers(tester);

    await tester.tap(find.text('Submit for review'));
    await tester.pump();
    expect(find.text('Enter your full name.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(5));
    await tester.enterText(fields.at(0), 'Sita Sharma');
    await tester.enterText(fields.at(1), '001-02-345678');
    await tester.enterText(fields.at(2), '1998-04-12');
    await tester.enterText(fields.at(3), 'Nepal Bank');
    await tester.enterText(fields.at(4), '1234567890');

    expect(
      tester.widget<TextFormField>(fields.at(0)).controller?.text,
      'Sita Sharma',
    );
  });

  testWidgets('in-review step shows demo approve and reject actions',
      (tester) async {
    await tester.runAsync(
      () => MockDb.instance.setKyc(
        KycProfile.initial().submit(
          KycStepKind.citizenship,
          documentPath: '/tmp/c.jpg',
          documentName: 'c.jpg',
        ),
      ),
    );

    await tester.pumpWidget(_shell(container, '/kyc/citizenship'));
    await _pumpUntil(tester, find.text('Approve step'));
    await _settleTimers(tester);

    expect(find.text('Approve step'), findsOneWidget);
    expect(find.text('Reject step'), findsOneWidget);
  });
}
