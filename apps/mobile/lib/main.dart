import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NepalLend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: kInter,
        scaffoldBackgroundColor: AppColors.surface,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          onPrimary: AppColors.white,
          secondary: AppColors.navy,
          surface: AppColors.white,
          error: AppColors.danger,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: AppText.body,
          bodySmall: AppText.bodySm,
          titleLarge: AppText.h2,
          titleMedium: AppText.h3,
          titleSmall: AppText.h4,
          labelMedium: AppText.label,
          labelSmall: AppText.caption,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: InputBorder.none,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
