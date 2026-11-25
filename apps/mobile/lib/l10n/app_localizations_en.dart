// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NepalLend';

  @override
  String get navHomeLabel => 'Home';

  @override
  String get navLoansLabel => 'Loans';

  @override
  String get navProfileLabel => 'Profile';

  @override
  String get navBrowseLabel => 'Browse';

  @override
  String get navPortfolioLabel => 'Portfolio';

  @override
  String get navWalletLabel => 'Wallet';

  @override
  String get stepNotFoundTitle => 'Step not found';

  @override
  String get stepNotFoundDescription =>
      'That verification step does not exist.';

  @override
  String get helpAndSafetyTitle => 'Help and safety';

  @override
  String get helpAndSafetyDescription =>
      'How lending works, fees, and what to do if an account is suspended.';

  @override
  String get myLoansTitle => 'My loans';

  @override
  String get myLoansDescription =>
      'Requests, agreements and repayment schedules.';

  @override
  String get borrowerProfileTitle => 'Profile';

  @override
  String get borrowerProfileDescription =>
      'Phone, role and verification status.';

  @override
  String get lenderProfileTitle => 'Profile';

  @override
  String get lenderProfileDescription => 'Phone, role and verification status.';

  @override
  String get riskBandLowLabel => 'Low risk';

  @override
  String get riskBandMediumLabel => 'Medium risk';

  @override
  String get riskBandHighLabel => 'High risk';

  @override
  String riskBadgeText(Object grade, Object label) {
    return '$grade · $label';
  }

  @override
  String fundingProgressText(Object fundedAmount, Object percent) {
    return '$percent% funded · $fundedAmount';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get demoErrorStateMessage =>
      'Something went wrong (demo error state).';

  @override
  String get youAreOffline => 'You are offline';

  @override
  String get offlineMessage => 'Check your connection and try again.';

  @override
  String get openDetailsAction => 'Open details';

  @override
  String get splashAppName => 'NepalLend';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get loginEnterPhoneTitle => 'Enter your phone number';

  @override
  String get loginPhoneExplanation =>
      'We use your number to keep your account secure. Standard SMS rates may apply.';

  @override
  String get mobileNumberLabel => 'Mobile number';

  @override
  String get mobileNumberHint => '9800000000';

  @override
  String get nepalPhonePrefix => '+977 ';

  @override
  String get invalidMobileNumberError =>
      'Enter a valid 10-digit Nepali mobile number.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get useDemoAccountButton => 'Use demo account';

  @override
  String get loginDemoCodeHint =>
      'Demo only: code 123456 · wrong 111111 · busy 000000 · offline 999999';

  @override
  String get verifyNumberTitle => 'Verify your number';

  @override
  String get requestCodeBeforeEnteringError =>
      'Request a code before entering it.';

  @override
  String get enterSixDigitCodeTitle => 'Enter the 6-digit code';

  @override
  String sentToPhoneText(Object phone) {
    return 'Sent to $phone';
  }

  @override
  String get otpCodeLabel => 'Code';

  @override
  String get otpCodeHint => '000000';

  @override
  String get enterAllSixDigitsError => 'Enter all 6 digits.';

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String resendCountdown(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifyAndContinueButton => 'Verify and continue';

  @override
  String otpDemoCodeNotice(Object demoCode) {
    return 'Demo code: $demoCode. The fixed code is only shown in mock mode.';
  }

  @override
  String get onboardingSlide1Title => 'Lend and borrow directly';

  @override
  String get onboardingSlide1Body =>
      'NepalLend connects verified borrowers with lenders across Nepal.';

  @override
  String get onboardingSlide2Title => 'Know who you deal with';

  @override
  String get onboardingSlide2Body =>
      'Identity checks and an explainable risk grade on every loan.';

  @override
  String get onboardingSlide3Title => 'Every paisa accounted for';

  @override
  String get onboardingSlide3Body =>
      'Clear terms, exact instalments and a receipt for every money move.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get getStartedButton => 'Get started';

  @override
  String get nextButton => 'Next';

  @override
  String get chooseRoleTitle => 'Choose your role';

  @override
  String get roleUsageQuestion => 'How will you use NepalLend?';

  @override
  String get roleSelectionExplanation =>
      'Your role decides which tools you see. It can only be chosen once.';

  @override
  String get borrowerRoleTitle => 'Borrower';

  @override
  String get borrowerRoleDescription =>
      'Request a loan, review your risk grade and repay in instalments.';

  @override
  String get continueAsBorrower => 'Continue as borrower';

  @override
  String get lenderRoleTitle => 'Lender';

  @override
  String get lenderRoleDescription =>
      'Browse verified loans, fund a part of one and track your returns.';

  @override
  String get continueAsLender => 'Continue as lender';

  @override
  String signedInAsPhone(Object phone) {
    return 'Signed in as $phone';
  }

  @override
  String get verifyIdentityTitle => 'Verify your identity';

  @override
  String get kycChecklistIntro =>
      'Complete four steps to unlock borrowing and lending';

  @override
  String get kycDocumentUsageNote =>
      'Your documents are used only to verify your identity.';

  @override
  String kycVerifiedCount(Object count) {
    return '$count of 4 verified';
  }

  @override
  String get demoAdminTitle => 'Demo admin';

  @override
  String get demoAdminDescription =>
      'No reviewer is online in mock mode. Approve the four submitted steps to continue the demo.';

  @override
  String get approveAllStepsButton => 'Approve all steps';

  @override
  String get kycStatusVerified => 'Verified';

  @override
  String get kycStatusInReview => 'In review';

  @override
  String get kycStatusRejected => 'Rejected';

  @override
  String get kycStatusNotStarted => 'Not started';

  @override
  String kycStepNumberTitle(Object number, Object stepLabel) {
    return '$number. $stepLabel';
  }

  @override
  String kycRejectionReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get captureDocumentFirstError => 'Capture or choose a document first.';

  @override
  String kycStepProgress(Object stepNumber) {
    return 'Step $stepNumber of 4';
  }

  @override
  String kycRejectedNotice(Object reason) {
    return 'Rejected: $reason. Check the details and submit again.';
  }

  @override
  String get kycRejectedNoticeNoReason =>
      'Rejected. Check the details and submit again.';

  @override
  String get resubmitForReviewButton => 'Resubmit for review';

  @override
  String get submitForReviewButton => 'Submit for review';

  @override
  String get backToChecklistButton => 'Back to checklist';

  @override
  String get takePhotoButton => 'Take photo';

  @override
  String get chooseFromGalleryButton => 'Choose from gallery';

  @override
  String selectedDocumentText(Object fileName) {
    return 'Selected: $fileName';
  }

  @override
  String get chooseDifferentPhotoButton => 'Choose a different photo';

  @override
  String get fullNameLabel => 'Full name (as on citizenship)';

  @override
  String get fullNameHint => 'Sita Sharma';

  @override
  String get enterFullNameError => 'Enter your full name.';

  @override
  String get citizenshipNumberLabel => 'Citizenship number';

  @override
  String get citizenshipNumberHint => '000-00-000000';

  @override
  String get enterCitizenshipNumberError => 'Enter your citizenship number.';

  @override
  String get dateOfBirthLabel => 'Date of birth';

  @override
  String get dateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get invalidDateFormatError => 'Use the format YYYY-MM-DD.';

  @override
  String get bankNameLabel => 'Bank name';

  @override
  String get bankNameHint => 'e.g. Nepal Bank Limited';

  @override
  String get enterBankNameError => 'Enter your bank name.';

  @override
  String get bankAccountNumberLabel => 'Bank account number';

  @override
  String get bankAccountNumberHint => '0000000000';

  @override
  String get enterFiveToTwentyDigitsError => 'Enter 5–20 digits.';

  @override
  String kycStepVerifiedTitle(Object stepLabel) {
    return '$stepLabel verified';
  }

  @override
  String get kycStepLockedNote =>
      'This step is locked. Your reviewer approved it.';

  @override
  String kycStepSubmittedTitle(Object stepLabel) {
    return '$stepLabel submitted';
  }

  @override
  String get kycStepReviewNote =>
      'Your submission is in review. You can continue once a reviewer approves it.';

  @override
  String get demoReviewerTitle => 'Demo reviewer';

  @override
  String get rejectionReasonLabel => 'Rejection reason (optional)';

  @override
  String get rejectionReasonHint => 'Photo is blurry';

  @override
  String get approveStepButton => 'Approve step';

  @override
  String get rejectStepButton => 'Reject step';

  @override
  String get borrowerFallbackName => 'there';

  @override
  String get borrowerHomeTitle => 'Borrower home';

  @override
  String namasteGreeting(Object name) {
    return 'Namaste, $name';
  }

  @override
  String get borrowerHomeIntro =>
      'Request a verified loan and see exactly what you will repay.';

  @override
  String get requestLoanButton => 'Request a loan';

  @override
  String get makeRepaymentButton => 'Make a repayment';

  @override
  String get yourApplicationsTitle => 'Your applications';

  @override
  String get noLoanRequestsYet => 'No loan requests yet';

  @override
  String get noLoanRequestsMessage =>
      'Your applications and agreements will appear here.';

  @override
  String tenorMonthsText(Object count) {
    return '$count months';
  }

  @override
  String get loanStatusDraft => 'Draft';

  @override
  String get loanStatusPendingReview => 'Pending review';

  @override
  String get loanStatusOpenForFunding => 'Open for funding';

  @override
  String get loanStatusFunded => 'Funded';

  @override
  String get loanStatusActive => 'Active';

  @override
  String get loanStatusRepaid => 'Repaid';

  @override
  String get loanStatusRejected => 'Rejected';

  @override
  String get loanStatusExpired => 'Expired';

  @override
  String get loanStatusCancelled => 'Cancelled';

  @override
  String get loanStatusOverdue => 'Overdue';

  @override
  String get loanStatusDefaulted => 'Defaulted';

  @override
  String get riskMarkerPositive => '+';

  @override
  String get riskMarkerNeutral => '•';

  @override
  String get riskMarkerNegative => '−';

  @override
  String get riskDirectionPositiveLabel => 'Positive factor';

  @override
  String get riskDirectionNeutralLabel => 'Neutral factor';

  @override
  String get riskDirectionNegativeLabel => 'Negative factor';

  @override
  String loanAmountOutOfRangeError(Object maxAmount, Object minAmount) {
    return 'Enter an amount between $minAmount and $maxAmount.';
  }

  @override
  String get invalidTenorRangeError =>
      'Choose a tenor between 3 and 60 months.';

  @override
  String get enterMonthlyIncomeError => 'Enter your monthly income.';

  @override
  String get requestLoanTitle => 'Request a loan';

  @override
  String get requestLoanIntro =>
      'Tell lenders what you need. We will show the rate, exact instalment and the reasons behind your grade.';

  @override
  String get purposeLabel => 'Purpose';

  @override
  String get purposeHint => 'e.g. Business inventory';

  @override
  String get describePurposeError => 'Describe the purpose.';

  @override
  String get loanAmountLabel => 'Loan amount';

  @override
  String get loanAmountHint => '2,00,000';

  @override
  String get nprPrefix => 'NPR ';

  @override
  String get enterAmountError => 'Enter an amount.';

  @override
  String get tenorLabel => 'Tenor (months)';

  @override
  String get tenorHint => '12';

  @override
  String get enterWholeMonthsError => 'Enter whole months.';

  @override
  String get monthlyIncomeLabel => 'Monthly income';

  @override
  String get monthlyIncomeHint => '50,000';

  @override
  String get seeMyRiskGradeButton => 'See my risk grade';

  @override
  String get requestLoanDemoNote =>
      'Demo mode: no credit bureau call and no real money moves.';

  @override
  String get riskReviewTitle => 'Your risk review';

  @override
  String loanTermsSummary(Object months, Object rate) {
    return '$months months · $rate p.a.';
  }

  @override
  String riskScoreText(Object score) {
    return 'Score $score/100';
  }

  @override
  String get whyThisGradeTitle => 'Why this grade';

  @override
  String riskModelExplanation(Object modelVersion) {
    return 'Model $modelVersion · affordability, amount, tenor, verification and history.';
  }

  @override
  String get manualReviewNotice =>
      'This request is flagged for manual review. Use the demo control to approve it.';

  @override
  String get demoApproveRequestButton => 'Demo approve request';

  @override
  String get continueToAgreementButton => 'Continue to agreement';

  @override
  String get repaymentPreviewTitle => 'Repayment preview';

  @override
  String get monthlyInstalmentLabel => 'Monthly instalment';

  @override
  String get totalRepayableLabel => 'Total repayable';

  @override
  String get interestLabel => 'Interest';

  @override
  String get platformFeeLabel => 'Platform fee (10% of interest)';

  @override
  String get typeFullNameToSignError => 'Type your full name to sign.';

  @override
  String get acceptTermsBeforeSigningError =>
      'Accept the terms before signing.';

  @override
  String get loanAgreementTitle => 'Loan agreement';

  @override
  String termsVersionText(Object version) {
    return 'Terms version $version';
  }

  @override
  String termsHashText(Object hash) {
    return 'Terms hash: $hash';
  }

  @override
  String get signedFundsDisbursedChip => 'Signed · funds disbursed';

  @override
  String signedByOnText(Object signedAt, Object signedBy) {
    return 'Signed by $signedBy on $signedAt';
  }

  @override
  String get viewDisbursementReceiptButton => 'View disbursement receipt';

  @override
  String get typeFullNameToSignLabel => 'Type your full name to sign';

  @override
  String get legalNameHint => 'Your legal name';

  @override
  String get acceptTermsCheckboxLabel =>
      'I accept these terms and the repayment schedule.';

  @override
  String get signAndReceiveFundsButton => 'Sign and receive funds';

  @override
  String get approveBeforeSigningNotice =>
      'Approve the request on the risk review screen before signing.';

  @override
  String get demoEscrowNote =>
      'Demo escrow is simulated: signing records the escrow → wallet journal after lenders fund the loan.';

  @override
  String repaymentScheduleWithCount(Object count) {
    return 'Repayment schedule ($count instalments)';
  }

  @override
  String instalmentNumberText(Object number) {
    return '$number.';
  }

  @override
  String displayDate(Object day, Object month, Object year) {
    return '$day/$month/$year';
  }

  @override
  String get stakeStatusActive => 'Active';

  @override
  String get stakeStatusReturned => 'Returned after expiry';

  @override
  String get verifiedBorrowerFallback => 'Verified borrower';

  @override
  String get lenderHomeTitle => 'Lender home';

  @override
  String get lenderHomeIntro => 'Your lending at a glance';

  @override
  String get walletBalanceLabel => 'Wallet balance';

  @override
  String get activeStakesLabel => 'Active stakes';

  @override
  String activeStakesCount(Object count) {
    return '$count';
  }

  @override
  String get amountCommittedLabel => 'Amount committed';

  @override
  String get browseVerifiedLoansButton => 'Browse verified loans';

  @override
  String get viewMyPortfolioButton => 'View my portfolio';

  @override
  String get addMoneyToWalletButton => 'Add money to wallet';

  @override
  String openLoansSummary(Object count) {
    return '$count loans currently open for funding.';
  }

  @override
  String openLoansSummarySingular(Object count) {
    return '$count loan currently open for funding.';
  }

  @override
  String get browseLoansTitle => 'Browse loans';

  @override
  String get fundVerifiedBorrower => 'Fund a verified borrower';

  @override
  String get riskBandLabel => 'Risk band';

  @override
  String get riskBandAll => 'All bands';

  @override
  String get riskBandLow => 'Low';

  @override
  String get riskBandMedium => 'Medium';

  @override
  String get riskBandHigh => 'High';

  @override
  String get minAmountLabel => 'Min amount';

  @override
  String get minAmountHint => '10000';

  @override
  String get maxAmountLabel => 'Max amount';

  @override
  String get maxAmountHint => '200000';

  @override
  String get maxTenorLabel => 'Max tenor (months)';

  @override
  String get maxTenorHint => '12';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortAmountAscending => 'Amount ↑';

  @override
  String get sortAmountDescending => 'Amount ↓';

  @override
  String get sortLowestRisk => 'Lowest risk';

  @override
  String get applyFiltersButton => 'Apply filters';

  @override
  String get openLoansTitle => 'Open loans';

  @override
  String openLoansCount(Object count) {
    return '$count';
  }

  @override
  String get noLoansMatch => 'No loans match';

  @override
  String get noLoansMatchMessage => 'Try widening the amount or tenor filters.';

  @override
  String tenorMonthsShort(Object count) {
    return '$count mo';
  }

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get yourStakesTitle => 'Your stakes';

  @override
  String activePrincipalText(Object amount) {
    return 'Active principal: $amount';
  }

  @override
  String get noStakesYet => 'No stakes yet';

  @override
  String get noStakesMessage =>
      'Browse verified loans and fund one to get started.';

  @override
  String stakeInLoanText(Object loanId) {
    return 'Stake in $loanId';
  }

  @override
  String get loanDetailsTitle => 'Loan details';

  @override
  String needsMoreByDate(Object amount, Object date) {
    return 'Needs $amount more by $date.';
  }

  @override
  String get identityVerifiedNote => 'Identity verified · KYC complete';

  @override
  String get riskFactorsTitle => 'Risk factors';

  @override
  String riskFactorLine(Object name, Object note) {
    return '$name: $note';
  }

  @override
  String modelScoreSummary(Object modelVersion, Object score) {
    return 'Model $modelVersion · score $score/100.';
  }

  @override
  String get fundThisLoanButton => 'Fund this loan';

  @override
  String get loanNotOpenForFunding =>
      'This loan is no longer open for funding.';

  @override
  String get dateToBeConfirmed => 'a date to be confirmed';

  @override
  String get fundLoanTitle => 'Fund loan';

  @override
  String stillNeededOfTotalText(Object remaining, Object total) {
    return '$remaining still needed of $total.';
  }

  @override
  String get amountToStakeLabel => 'Amount to stake';

  @override
  String get amountToStakeHint => '1000';

  @override
  String get walletBeforeLabel => 'Wallet before';

  @override
  String get interestShareLabel => 'Your interest share';

  @override
  String get walletAfterLabel => 'Wallet after';

  @override
  String get confirmFundingButton => 'Confirm funding';

  @override
  String get demoFundingNote =>
      'Demo funding debits your simulated wallet and credits the loan escrow. No real money moves.';

  @override
  String minimumStakeError(Object amount) {
    return 'The minimum stake is $amount.';
  }

  @override
  String onlyStillNeededError(Object amount) {
    return 'Only $amount is still needed.';
  }

  @override
  String get topUpWalletFirstError => 'Top up your wallet first.';

  @override
  String get stakeDetailsTitle => 'Stake details';

  @override
  String get yourStakeTitle => 'Your stake';

  @override
  String stakeLoanLine(Object purpose) {
    return 'Loan: $purpose';
  }

  @override
  String stakeBorrowerLine(Object borrowerName) {
    return 'Borrower: $borrowerName';
  }

  @override
  String fundedOnDateText(Object date) {
    return 'Funded $date';
  }

  @override
  String get ledgerTrailTitle => 'Ledger trail';

  @override
  String get viewFundingReceiptButton => 'View funding receipt';

  @override
  String get viewExpiryReversalButton => 'View expiry reversal';

  @override
  String get stakeReturnedNote =>
      'The loan expired before it was fully funded. Escrow was reversed and this stake returned to your wallet.';

  @override
  String get unknownDateText => 'on an unknown date';

  @override
  String get confirmRepaymentTitle => 'Confirm repayment';

  @override
  String repaymentSheetDetail(
    Object fee,
    Object instalmentNumber,
    Object provider,
  ) {
    return 'A simulated $provider payment pays instalment $instalmentNumber. The platform fee is $fee.';
  }

  @override
  String get payInstalmentButton => 'Pay instalment';

  @override
  String get makeRepaymentTitle => 'Make a repayment';

  @override
  String get payOneAtATimeTitle => 'Pay one instalment at a time';

  @override
  String get repaymentSplitNote =>
      'Principal and interest are split across every lender stake automatically. A 10% platform fee is taken from interest.';

  @override
  String get nothingToRepayYet => 'Nothing to repay yet';

  @override
  String get nothingToRepayMessage =>
      'Once a loan is funded and signed, your instalments will appear here.';

  @override
  String instalmentProgressText(Object number, Object total) {
    return 'Instalment $number of $total';
  }

  @override
  String dueDateText(Object date) {
    return 'Due $date';
  }

  @override
  String get amountToPayLabel => 'Amount to pay';

  @override
  String get principalLabel => 'Principal';

  @override
  String get lendersReceiveLabel => 'Lenders receive';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get paymentProviderEsewaLabel => 'eSewa (simulated)';

  @override
  String get paymentProviderKhaltiLabel => 'Khalti (simulated)';

  @override
  String payAmountButton(Object amount) {
    return 'Pay $amount';
  }

  @override
  String get instalmentPaidChip => 'Paid';

  @override
  String get instalmentDueChip => 'Due';

  @override
  String get repaymentStatusProcessing => 'Processing';

  @override
  String get repaymentStatusLate => 'Late';

  @override
  String get repaymentStatusNextUp => 'Next up';

  @override
  String get providerLabelKhalti => 'Khalti';

  @override
  String get providerLabelEsewa => 'eSewa';

  @override
  String get repaymentScheduleTitle => 'Repayment schedule';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String unreadCountBadge(Object count) {
    return '$count';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllReadButton => 'Mark all read';

  @override
  String get allCaughtUpText => 'You are all caught up';

  @override
  String unreadCountText(Object count) {
    return '$count unread';
  }

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noNotificationsMessage =>
      'Funding, repayments and payment reminders will appear here.';

  @override
  String get notificationNewChip => 'New';

  @override
  String demoClockLabel(Object date) {
    return 'Demo clock: $date';
  }

  @override
  String get clockAdvanceOneDay => '+1 day';

  @override
  String get clockAdvanceSevenDays => '+7 days';

  @override
  String get clockAdvanceOneMonth => '+1 month';

  @override
  String get clockResetButton => 'Reset';

  @override
  String get demoRemindersButton => 'Reminders';

  @override
  String paymentRemindersSentSnackbar(Object count) {
    return 'Payment reminders sent: $count';
  }

  @override
  String get demoMarkOverdueButton => 'Mark overdue';

  @override
  String loansMarkedOverdueSnackbar(Object count) {
    return 'Loans marked overdue: $count';
  }

  @override
  String get demoReconcileButton => 'Reconcile';

  @override
  String ledgerCleanSnackbar(Object count) {
    return 'Ledger clean ($count journals)';
  }

  @override
  String ledgerIssuesSnackbar(Object negativeCount, Object unbalancedCount) {
    return 'Ledger issues: $unbalancedCount unbalanced, $negativeCount negative';
  }

  @override
  String get demoStateTitle => 'Screen state';

  @override
  String get demoStateNormal => 'Normal';

  @override
  String get demoStateLoading => 'Loading';

  @override
  String get demoStateEmpty => 'Empty';

  @override
  String get demoStateError => 'Error';

  @override
  String get demoStateOffline => 'Offline';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get availableBalanceLabel => 'Available balance';

  @override
  String get topUpButton => 'Top up';

  @override
  String get withdrawButton => 'Withdraw';

  @override
  String get recentActivityTitle => 'Recent activity';

  @override
  String get noWalletActivityYet => 'No wallet activity yet';

  @override
  String get noWalletActivityMessage => 'Top up your wallet to start lending.';

  @override
  String get minimumAmountError => 'Minimum amount is NPR 1,000.';

  @override
  String get amountExceedsBalanceError =>
      'Amount is more than your wallet balance.';

  @override
  String get confirmTopUpSheetTitle => 'Confirm top-up';

  @override
  String get confirmWithdrawalSheetTitle => 'Confirm withdrawal';

  @override
  String get topUpSheetDetail =>
      'A simulated payment adds this amount to your wallet.';

  @override
  String get withdrawalSheetDetail =>
      'This amount leaves your wallet and is sent to your bank.';

  @override
  String get confirmTopUpButton => 'Confirm top-up';

  @override
  String get confirmWithdrawalButton => 'Confirm withdrawal';

  @override
  String get topUpWalletTitle => 'Top up wallet';

  @override
  String get withdrawToBankTitle => 'Withdraw to bank';

  @override
  String get topUpIntro => 'Add money to your wallet to fund loans.';

  @override
  String get withdrawalIntro =>
      'Move money from your wallet to your bank account.';

  @override
  String get amountToAddLabel => 'Amount to add';

  @override
  String get amountToWithdrawLabel => 'Amount to withdraw';

  @override
  String get walletAmountHint => '10,000';

  @override
  String get reviewTopUpButton => 'Review top-up';

  @override
  String get reviewWithdrawalButton => 'Review withdrawal';

  @override
  String get demoPaymentGatewayNote =>
      'Demo mode uses a simulated payment gateway. No real money moves.';

  @override
  String get transactionReceiptTitle => 'Transaction receipt';

  @override
  String get moneyMoveRecordedText => 'Money move recorded';

  @override
  String get referenceLabel => 'Reference';

  @override
  String journalIdLine(Object journalId) {
    return 'Journal: $journalId';
  }

  @override
  String journalTypeLine(Object journalType) {
    return 'Type: $journalType';
  }

  @override
  String journalCreatedLine(Object date) {
    return 'Created: $date';
  }

  @override
  String get replayedRequestChip => 'Replayed request';

  @override
  String get ledgerEntriesTitle => 'Ledger entries';

  @override
  String get styleGuideTitle => 'Style guide';

  @override
  String get styleGuideColoursSection => 'Colours';

  @override
  String get swatchPrimaryLabel => 'primary';

  @override
  String get swatchSuccessLabel => 'success';

  @override
  String get swatchWarningLabel => 'warning';

  @override
  String get swatchErrorLabel => 'error';

  @override
  String get swatchRiskLowLabel => 'risk low';

  @override
  String get swatchRiskMediumLabel => 'risk medium';

  @override
  String get swatchRiskHighLabel => 'risk high';

  @override
  String get styleGuideTypographySection => 'Typography';

  @override
  String get typographyDisplayTitle => 'Display title';

  @override
  String get typographyTitleSample => 'Title';

  @override
  String get typographyBodySample => 'Body text';

  @override
  String get typographyCaptionSample => 'Caption text';

  @override
  String get styleGuideButtonsSection => 'Buttons';

  @override
  String get styleGuidePrimaryAction => 'Primary action';

  @override
  String get styleGuideSecondaryAction => 'Secondary action';

  @override
  String get styleGuideDisabledButton => 'Disabled';

  @override
  String get styleGuideInputsSection => 'Inputs';

  @override
  String get styleGuideAmountHint => '1,00,000';

  @override
  String get styleGuideCardsSection => 'Cards and amounts';

  @override
  String get styleGuideDemoGrade => 'B';

  @override
  String get styleGuideProgressSection => 'Progress and statuses';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusInReview => 'In review';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusOpen => 'Open';

  @override
  String get styleGuideStatesSection => 'States';

  @override
  String get styleGuideNoLoansYet => 'No loans yet';

  @override
  String get styleGuideNoLoansMessage => 'New requests will appear here.';

  @override
  String get styleGuideErrorStateMessage => 'Could not load loans.';

  @override
  String get styleGuideBottomSheetSection => 'Bottom sheet';

  @override
  String get openConfirmationSheetButton => 'Open confirmation sheet';

  @override
  String get confirmFundingSheetTitle => 'Confirm funding';

  @override
  String get confirmAndFundButton => 'Confirm and fund';

  @override
  String get expectedInterestDemoText => 'Expected interest: NPR 410.00';
}
