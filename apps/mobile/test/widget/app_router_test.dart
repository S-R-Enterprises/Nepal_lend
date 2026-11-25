import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/app.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/features/auth/presentation/login_screen.dart';
import 'package:nepal_lend/shared/widgets/placeholder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
  });

  testWidgets('splash leaves for login once auth restore completes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envProvider.overrideWithValue(
            const Env(
              environment: AppEnvironment.mock,
              apiBaseUrl: 'https://mock.local/api/v1',
            ),
          ),
        ],
        child: const NepalLendApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);

    for (var i = 0; i < 100; i++) {
      if (tester.any(find.byType(LoginScreen))) break;
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
