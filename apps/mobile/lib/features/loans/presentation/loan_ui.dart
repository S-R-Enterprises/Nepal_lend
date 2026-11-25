import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/l10n/app_localizations.dart';
import 'package:nepal_lend/l10n/app_localizations_en.dart';

String loanStatusLabel(LoanStatus status, [AppLocalizations? l10n]) {
  final strings = l10n ?? AppLocalizationsEn();
  return switch (status) {
    LoanStatus.draft => strings.loanStatusDraft,
    LoanStatus.pendingReview => strings.loanStatusPendingReview,
    LoanStatus.open => strings.loanStatusOpenForFunding,
    LoanStatus.funded => strings.loanStatusFunded,
    LoanStatus.active => strings.loanStatusActive,
    LoanStatus.repaid => strings.loanStatusRepaid,
    LoanStatus.rejected => strings.loanStatusRejected,
    LoanStatus.expired => strings.loanStatusExpired,
    LoanStatus.cancelled => strings.loanStatusCancelled,
    LoanStatus.overdue => strings.loanStatusOverdue,
    LoanStatus.defaulted => strings.loanStatusDefaulted,
  };
}

AppTone loanStatusTone(LoanStatus status) => switch (status) {
      LoanStatus.draft => AppTone.neutral,
      LoanStatus.pendingReview => AppTone.warning,
      LoanStatus.open => AppTone.success,
      LoanStatus.funded => AppTone.success,
      LoanStatus.active => AppTone.success,
      LoanStatus.repaid => AppTone.success,
      LoanStatus.rejected || LoanStatus.expired => AppTone.error,
      LoanStatus.cancelled || LoanStatus.defaulted => AppTone.error,
      LoanStatus.overdue => AppTone.warning,
    };

String riskDirectionMarker(RiskDirection direction, [AppLocalizations? l10n]) {
  final strings = l10n ?? AppLocalizationsEn();
  return switch (direction) {
    RiskDirection.positive => strings.riskMarkerPositive,
    RiskDirection.neutral => strings.riskMarkerNeutral,
    RiskDirection.negative => strings.riskMarkerNegative,
  };
}

AppTone riskDirectionTone(RiskDirection direction) => switch (direction) {
      RiskDirection.positive => AppTone.success,
      RiskDirection.neutral => AppTone.neutral,
      RiskDirection.negative => AppTone.error,
    };
