import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/app.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/features/styleguide/presentation/style_guide_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
  });

  testWidgets('style guide renders the component gallery', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StyleGuideScreen())),
    );

    expect(find.text('Style guide'), findsWidgets);
    expect(find.byType(AppButton), findsWidgets);
    expect(find.text('B · Medium risk'), findsOneWidget);
    expect(find.byType(FundingProgress), findsOneWidget);
  });

  testWidgets('app starts on the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NepalLendApp()));

    expect(find.text('NepalLend'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Flush AuthController.restore()'s 3s timeout so no timer is left pending.
    await tester.pump(const Duration(seconds: 4));
  });
}
