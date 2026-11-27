import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/utils/demo_ui_state.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/l10n/l10n.dart';

enum AppButtonVariant { primary, secondary, text }

enum AppTone { neutral, success, warning, error }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final child = SizedBox(
      width: expand ? double.infinity : null,
      height: 48,
      child: loading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : icon == null
              ? Text(label)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
    );

    VoidCallback? action = enabled ? onPressed : null;
    return switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: action, child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: action, child: child),
      AppButtonVariant.text => TextButton(onPressed: action, child: child),
    };
  }
}

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.prefixText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? prefixText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.lg,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double padding;

  /// Accessible action name for tappable cards. Defaults to a generic "open
  /// details" label so screen readers announce the action, not just the text.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
    if (onTap == null) return card;
    return Semantics(
      button: true,
      label: semanticsLabel ?? L10n.of(context).openDetailsAction,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.grade, required this.band});

  final String grade;
  final String band;

  @override
  Widget build(BuildContext context) {
    final color = switch (band) {
      'low' => AppColors.riskLow,
      'medium' => AppColors.riskMedium,
      _ => AppColors.riskHigh,
    };
    final l10n = L10n.of(context);
    final label = switch (band) {
      'low' => l10n.riskBandLowLabel,
      'medium' => l10n.riskBandMediumLabel,
      _ => l10n.riskBandHighLabel,
    };
    final text = l10n.riskBadgeText(grade, label);
    return Semantics(
      label: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(Icons.verified_user_outlined, size: 15, color: color),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FundingProgress extends StatelessWidget {
  const FundingProgress({super.key, required this.fundedPaisa, required this.amountPaisa});

  final int fundedPaisa;
  final int amountPaisa;

  @override
  Widget build(BuildContext context) {
    final progress = amountPaisa == 0
        ? 0.0
        : (fundedPaisa / amountPaisa).clamp(0.0, 1.0);
    final l10n = L10n.of(context);
    final label = l10n.fundingProgressText(
      formatNPRCompact(fundedPaisa),
      (progress * 100).round(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: label,
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText({super.key, required this.paisa, this.large = false, this.showPaisa = true});

  final int paisa;
  final bool large;
  final bool showPaisa;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatNPR(paisa, showPaisa: showPaisa),
      style: large
          ? Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)
          : Theme.of(context).textTheme.titleMedium,
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.tone = AppTone.neutral});

  final String label;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AppTone.success => AppColors.success,
      AppTone.warning => AppColors.warning,
      AppTone.error => AppColors.error,
      AppTone.neutral => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.message, this.actionLabel, this.onAction});

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(message!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: L10n.of(context).tryAgain, variant: AppButtonVariant.secondary, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key, this.height = 16, this.width = double.infinity});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.outline.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );
}

class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
    this.actionEnabled = true,
  });

  final String title;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ...children,
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: actionEnabled ? onAction : null,
                expand: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (index) {
        final done = index < completed;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.outline,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

/// Offline variant of the four required list/detail states.
class OfflineState extends StatelessWidget {
  const OfflineState({super.key, required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: AppSpacing.md),
            Text(
              L10n.of(context).youAreOffline,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              L10n.of(context).offlineMessage,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: L10n.of(context).tryAgain,
                variant: AppButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared async-state switch for list and detail screens.
///
/// Handles real loading/error/empty conditions and, in mock mode, lets the demo
/// tools panel force any of the four states so reviewers can inspect them
/// without breaking a network connection.
class ScreenStateView extends ConsumerWidget {
  const ScreenStateView({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.builder,
    this.error,
    this.onRetry,
    this.emptyTitle,
    this.emptyMessage,
  });

  final bool isLoading;
  final bool isEmpty;
  final Widget Function(BuildContext context) builder;
  final String? error;
  final VoidCallback? onRetry;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final resolvedEmptyTitle = emptyTitle ?? l10n.nothingHereYet;
    switch (ref.watch(demoUiStateProvider)) {
      case DemoUiState.loading:
        return const Center(child: CircularProgressIndicator());
      case DemoUiState.empty:
        return EmptyState(title: resolvedEmptyTitle, message: emptyMessage);
      case DemoUiState.error:
        return ErrorState(message: l10n.demoErrorStateMessage, onRetry: onRetry);
      case DemoUiState.offline:
        return OfflineState(onRetry: onRetry);
      case DemoUiState.normal:
        break;
    }
    if (error != null) {
      return ErrorState(message: error!, onRetry: onRetry);
    }
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (isEmpty) {
      return EmptyState(title: resolvedEmptyTitle, message: emptyMessage);
    }
    return builder(context);
  }
}
