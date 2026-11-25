import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/kyc/data/kyc_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

/// Four-step verification checklist. Verification gates borrowing and funding
/// through the router and the domain services, not by hiding buttons here.
class KycChecklistScreen extends ConsumerStatefulWidget {
  const KycChecklistScreen({super.key});

  @override
  ConsumerState<KycChecklistScreen> createState() => _KycChecklistScreenState();
}

class _KycChecklistScreenState extends ConsumerState<KycChecklistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(kycProvider.notifier).load();
    });
  }

  void _openStep(KycStepKind kind) => context.go('/kyc/${kind.routeSegment}');

  Future<void> _approveAll() async {
    final ok = await ref.read(kycProvider.notifier).approveAll();
    if (!mounted || !ok) return;
    if (ref.read(kycProvider).profile.allVerified) {
      final role = ref.read(authProvider).user?.role;
      context.go(role == null || role == UserRole.borrower
          ? '/borrower/home'
          : '/lender/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final kyc = ref.watch(kycProvider);
    final profile = kyc.profile;
    final isMock = ref.watch(envProvider).isMock;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyIdentityTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.kycChecklistIntro,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.kycDocumentUsageNote,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              StepIndicator(total: 4, completed: profile.completedCount),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.kycVerifiedCount(profile.completedCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ScreenStateView(
                  isLoading: kyc.isBusy && profile.completedCount == 0,
                  isEmpty: profile.steps.isEmpty,
                  error: kyc.error,
                  onRetry: () => ref.read(kycProvider.notifier).load(),
                  emptyTitle: l10n.verifyIdentityTitle,
                  builder: (_) => ListView.separated(
                    itemCount: profile.steps.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final step = profile.steps[index];
                      return _StepTile(
                        step: step,
                        number: index + 1,
                        onTap: () => _openStep(step.kind),
                      );
                    },
                  ),
                ),
              ),
              if (isMock) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings_outlined,
                              color: AppColors.muted, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.demoAdminTitle,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.demoAdminDescription,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.approveAllStepsButton,
                        variant: AppButtonVariant.secondary,
                        loading: kyc.isBusy,
                        onPressed: _approveAll,
                        expand: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.number,
    required this.onTap,
  });

  final KycStep step;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final rejectionReason = step.reason;
    final tone = switch (step.status) {
      KycStatus.verified => AppTone.success,
      KycStatus.inReview => AppTone.warning,
      KycStatus.rejected => AppTone.error,
      KycStatus.notStarted => AppTone.neutral,
    };
    final statusLabel = switch (step.status) {
      KycStatus.verified => l10n.kycStatusVerified,
      KycStatus.inReview => l10n.kycStatusInReview,
      KycStatus.rejected => l10n.kycStatusRejected,
      KycStatus.notStarted => l10n.kycStatusNotStarted,
    };
    final icon = switch (step.kind) {
      KycStepKind.citizenship => Icons.credit_card_outlined,
      KycStepKind.selfie => Icons.face_outlined,
      KycStepKind.personalDetails => Icons.person_outline,
      KycStepKind.bankStatement => Icons.account_balance_outlined,
    };

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.kycStepNumberTitle(number, step.kind.label),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  step.kind.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (step.isRejected && rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.kycRejectionReason(rejectionReason),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                StatusChip(label: statusLabel, tone: tone),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
