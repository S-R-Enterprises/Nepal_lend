import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/router/app_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/l10n/app_localizations.dart';
import 'package:nepal_lend/features/notifications/data/push_registration.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class NepalLendApp extends ConsumerWidget {
  const NepalLendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps FCM token registration alive for the lifetime of the app.
    ref.watch(pushRegistrationProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: L10n.of(context).appTitle,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
