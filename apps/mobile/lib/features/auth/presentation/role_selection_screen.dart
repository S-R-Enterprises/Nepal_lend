import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chooseRoleTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.roleUsageQuestion,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.roleSelectionExplanation,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              _RoleCard(
                icon: Icons.request_quote_outlined,
                title: l10n.borrowerRoleTitle,
                description: l10n.borrowerRoleDescription,
                actionLabel: l10n.continueAsBorrower,
                onAction: () => ref
                    .read(authProvider.notifier)
                    .setRole(UserRole.borrower),
              ),
              const SizedBox(height: AppSpacing.lg),
              _RoleCard(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.lenderRoleTitle,
                description: l10n.lenderRoleDescription,
                actionLabel: l10n.continueAsLender,
                onAction: () =>
                    ref.read(authProvider.notifier).setRole(UserRole.lender),
              ),
              if (user != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.signedInAsPhone(user.phone),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: actionLabel, onPressed: onAction, expand: true),
        ],
      ),
    );
  }
}
