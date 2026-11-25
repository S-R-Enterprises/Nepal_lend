import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/demo_ui_state.dart';
import 'package:nepal_lend/l10n/app_localizations.dart';

class _PinnedDemoUiState extends DemoUiStateController {
  _PinnedDemoUiState(this.value);
  final DemoUiState value;

  @override
  DemoUiState build() => value;
}

Widget _harness(Widget child, DemoUiState state, {Locale? locale}) {
  return ProviderScope(
    key: ValueKey(state),
    overrides: [
      demoUiStateProvider.overrideWith(() => _PinnedDemoUiState(state)),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Phase 8 localisation', () {
    testWidgets('English strings render through the generated localizations',
        (tester) async {
      await tester.pumpWidget(
        _harness(const RiskBadge(grade: 'B', band: 'medium'), DemoUiState.normal),
      );

      expect(find.text('B · Medium risk'), findsOneWidget);
    });

    testWidgets('Nepali locale renders translated strings', (tester) async {
      // The forced empty state resolves its title through l10n.
      await tester.pumpWidget(
        _harness(
          const ScreenStateView(
            isLoading: false,
            isEmpty: true,
            builder: _noopBuilder,
          ),
          DemoUiState.normal,
          locale: const Locale('ne'),
        ),
      );

      expect(find.text('अहिले केही छैन'), findsOneWidget);
    });
  });

  group('Phase 8 four states', () {
    testWidgets('loading, empty, error and offline states are selectable',
        (tester) async {
      for (final state in DemoUiState.values) {
        if (state == DemoUiState.normal) continue;
        await tester.pumpWidget(
          _harness(
            const ScreenStateView(
              isLoading: false,
              isEmpty: false,
              builder: _noopBuilder,
              onRetry: _noop,
            ),
            state,
          ),
        );

        switch (state) {
          case DemoUiState.loading:
            expect(find.byType(CircularProgressIndicator), findsOneWidget);
          case DemoUiState.empty:
            expect(find.text('Nothing here yet'), findsOneWidget);
          case DemoUiState.error:
            expect(
              find.text('Something went wrong (demo error state).'),
              findsOneWidget,
            );
          case DemoUiState.offline:
            expect(find.text('You are offline'), findsOneWidget);
            expect(find.text('Try again'), findsOneWidget);
          case DemoUiState.normal:
            break;
        }
      }
    });
  });

  group('Phase 8 accessibility and responsive layout', () {
    testWidgets('RiskBadge exposes a semantics label', (tester) async {
      await tester.pumpWidget(
        _harness(const RiskBadge(grade: 'A', band: 'low'), DemoUiState.normal),
      );

      final semantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.text('A · Low risk'),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, 'A · Low risk');
    });

    testWidgets('shared components render at 360 dp with 1.3x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(360, 800),
                textScaler: TextScaler.linear(1.3),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      RiskBadge(grade: 'B', band: 'medium'),
                      StatusChip(label: 'Open for funding', tone: AppTone.success),
                      FundingProgress(fundedPaisa: 5000000, amountPaisa: 10000000),
                      AppButton(label: 'Review and continue', onPressed: null),
                      SizedBox(height: 800),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('B · Medium risk'), findsOneWidget);
      expect(find.text('Review and continue'), findsOneWidget);
    });

    testWidgets('primary buttons have >= 48 dp touch targets', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppButton(label: 'Tap me', onPressed: _noop),
          DemoUiState.normal,
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}

Widget _noopBuilder(BuildContext context) => const SizedBox.shrink();

void _noop() {}
