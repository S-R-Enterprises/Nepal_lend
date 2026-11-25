import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

/// Generic stub used by Phase 1 routes. Phase 2+ replaces these one by one.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final IconData icon;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: actionLabel!, onPressed: onAction, expand: true),
              ],
              if (secondaryActionLabel != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: secondaryActionLabel!,
                  variant: AppButtonVariant.secondary,
                  onPressed: onSecondaryAction,
                  expand: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Router-friendly stub that can read providers for its demo actions.
class StubActionScreen extends ConsumerWidget {
  const StubActionScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final IconData icon;
  final String? description;
  final String? actionLabel;
  final void Function(WidgetRef ref)? onAction;
  final String? secondaryActionLabel;
  final void Function(WidgetRef ref)? onSecondaryAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      title: title,
      icon: icon,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction == null ? null : () => onAction!(ref),
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction:
          onSecondaryAction == null ? null : () => onSecondaryAction!(ref),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(authProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 72, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.splashAppName,
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
