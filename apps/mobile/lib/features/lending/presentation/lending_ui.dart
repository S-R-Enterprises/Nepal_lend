import 'package:flutter/material.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/l10n/l10n.dart';

String stakeStatusLabel(BuildContext context, String status) {
  final l10n = L10n.of(context);
  return switch (status) {
    'active' => l10n.stakeStatusActive,
    'returned' => l10n.stakeStatusReturned,
    _ => status,
  };
}

AppTone stakeStatusTone(String status) => switch (status) {
      'active' => AppTone.success,
      'returned' => AppTone.warning,
      _ => AppTone.neutral,
    };

String borrowerLabel(BuildContext context, Loan loan) {
  final name = loan.borrowerName?.trim();
  return name != null && name.isNotEmpty
      ? name
      : L10n.of(context).verifiedBorrowerFallback;
}
