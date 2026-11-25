import 'package:flutter/material.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';

/// Shared confirmation step for top-up and withdrawal money moves.
class WalletConfirmationSheet extends StatelessWidget {
  const WalletConfirmationSheet({
    super.key,
    required this.title,
    required this.amountPaisa,
    required this.detail,
    required this.confirmLabel,
    required this.onConfirm,
    this.busy = false,
  });

  final String title;
  final int amountPaisa;
  final String detail;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      title: title,
      actionLabel: confirmLabel,
      actionEnabled: !busy,
      onAction: onConfirm,
      children: [
        Text(
          formatNPR(amountPaisa),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        if (busy) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(minHeight: 4),
        ],
      ],
    );
  }
}
