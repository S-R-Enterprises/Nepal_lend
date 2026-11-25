enum UserRole { borrower, lender }

enum KycStatus { notStarted, inReview, verified, rejected }

enum AccountStatus { active, suspended }

enum KycStepKind { citizenship, selfie, personalDetails, bankStatement }

enum LoanStatus {
  draft,
  pendingReview,
  open,
  funded,
  active,
  repaid,
  rejected,
  expired,
  cancelled,
  overdue,
  defaulted,
}

enum RiskBand { low, medium, high }

enum JournalKind { topup, withdrawal, fund, disburse, repayment, fee, reversal }

enum NotificationType {
  kycApproved,
  kycRejected,
  loanFunded,
  loanExpired,
  paymentDue,
  paymentReceived,
  security,
}
