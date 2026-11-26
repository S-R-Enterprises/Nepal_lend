import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/app.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/features/auth/presentation/login_screen.dart';
import 'package:nepal_lend/features/styleguide/presentation/style_guide_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screenshot pass for the assignment submission.
///
/// Generate the PNGs with:
///   flutter test --update-goldens test/widget/screenshots_test.dart
Widget _app(Widget child) => ProviderScope(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
  });

  testWidgets('screenshot: splash', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const ProviderScope(child: NepalLendApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(NepalLendApp),
      matchesGoldenFile('../../screenshots/splash.png'),
    );

    // Flush AuthController.restore()'s 3s timeout so no timer is left pending.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('screenshot: login', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_app(const LoginScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../../screenshots/login.png'),
    );
  });

  testWidgets('screenshot: component gallery', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_app(const StyleGuideScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('../../screenshots/style_guide.png'),
    );
  });
}
