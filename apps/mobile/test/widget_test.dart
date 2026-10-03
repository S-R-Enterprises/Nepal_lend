import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_lend/main.dart';
import 'package:nepal_lend/screens/onboarding/onboarding_screen.dart';

import 'load_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('splash shows brand then routes to onboarding', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NepalLend'), findsOneWidget);
    expect(find.text('NL'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
