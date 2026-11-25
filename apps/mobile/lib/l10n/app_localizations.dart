import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NepalLend'**
  String get appTitle;

  /// No description provided for @navHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// No description provided for @navLoansLabel.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get navLoansLabel;

  /// No description provided for @navProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfileLabel;

  /// No description provided for @navBrowseLabel.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowseLabel;

  /// No description provided for @navPortfolioLabel.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolioLabel;

  /// No description provided for @navWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWalletLabel;

  /// No description provided for @stepNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Step not found'**
  String get stepNotFoundTitle;

  /// No description provided for @stepNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'That verification step does not exist.'**
  String get stepNotFoundDescription;

  /// No description provided for @helpAndSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Help and safety'**
  String get helpAndSafetyTitle;

  /// No description provided for @helpAndSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'How lending works, fees, and what to do if an account is suspended.'**
  String get helpAndSafetyDescription;

  /// No description provided for @myLoansTitle.
  ///
  /// In en, this message translates to:
  /// **'My loans'**
  String get myLoansTitle;

  /// No description provided for @myLoansDescription.
  ///
  /// In en, this message translates to:
  /// **'Requests, agreements and repayment schedules.'**
  String get myLoansDescription;

  /// No description provided for @borrowerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get borrowerProfileTitle;

  /// No description provided for @borrowerProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Phone, role and verification status.'**
  String get borrowerProfileDescription;

  /// No description provided for @lenderProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get lenderProfileTitle;

  /// No description provided for @lenderProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Phone, role and verification status.'**
  String get lenderProfileDescription;

  /// No description provided for @riskBandLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low risk'**
  String get riskBandLowLabel;

  /// No description provided for @riskBandMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium risk'**
  String get riskBandMediumLabel;

  /// No description provided for @riskBandHighLabel.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskBandHighLabel;

  /// No description provided for @riskBadgeText.
  ///
  /// In en, this message translates to:
  /// **'{grade} · {label}'**
  String riskBadgeText(Object grade, Object label);

  /// No description provided for @fundingProgressText.
  ///
  /// In en, this message translates to:
  /// **'{percent}% funded · {fundedAmount}'**
  String fundingProgressText(Object fundedAmount, Object percent);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @demoErrorStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong (demo error state).'**
  String get demoErrorStateMessage;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get youAreOffline;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get offlineMessage;

  /// No description provided for @openDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get openDetailsAction;

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'NepalLend'**
  String get splashAppName;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @loginEnterPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get loginEnterPhoneTitle;

  /// No description provided for @loginPhoneExplanation.
  ///
  /// In en, this message translates to:
  /// **'We use your number to keep your account secure. Standard SMS rates may apply.'**
  String get loginPhoneExplanation;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumberLabel;

  /// No description provided for @mobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'9800000000'**
  String get mobileNumberHint;

  /// No description provided for @nepalPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'+977 '**
  String get nepalPhonePrefix;

  /// No description provided for @invalidMobileNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Nepali mobile number.'**
  String get invalidMobileNumberError;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @useDemoAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Use demo account'**
  String get useDemoAccountButton;

  /// No description provided for @loginDemoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Demo only: code 123456 · wrong 111111 · busy 000000 · offline 999999'**
  String get loginDemoCodeHint;

  /// No description provided for @verifyNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyNumberTitle;

  /// No description provided for @requestCodeBeforeEnteringError.
  ///
  /// In en, this message translates to:
  /// **'Request a code before entering it.'**
  String get requestCodeBeforeEnteringError;

  /// No description provided for @enterSixDigitCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterSixDigitCodeTitle;

  /// No description provided for @sentToPhoneText.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String sentToPhoneText(Object phone);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get otpCodeLabel;

  /// No description provided for @otpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get otpCodeHint;

  /// No description provided for @enterAllSixDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits.'**
  String get enterAllSixDigitsError;

  /// No description provided for @resendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeButton;

  /// No description provided for @resendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendCountdown(Object seconds);

  /// No description provided for @verifyAndContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get verifyAndContinueButton;

  /// No description provided for @otpDemoCodeNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo code: {demoCode}. The fixed code is only shown in mock mode.'**
  String otpDemoCodeNotice(Object demoCode);

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Lend and borrow directly'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'NepalLend connects verified borrowers with lenders across Nepal.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Know who you deal with'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Identity checks and an explainable risk grade on every loan.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Every paisa accounted for'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Clear terms, exact instalments and a receipt for every money move.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStartedButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @chooseRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseRoleTitle;

  /// No description provided for @roleUsageQuestion.
  ///
  /// In en, this message translates to:
  /// **'How will you use NepalLend?'**
  String get roleUsageQuestion;

  /// No description provided for @roleSelectionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your role decides which tools you see. It can only be chosen once.'**
  String get roleSelectionExplanation;

  /// No description provided for @borrowerRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrower'**
  String get borrowerRoleTitle;

  /// No description provided for @borrowerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Request a loan, review your risk grade and repay in instalments.'**
  String get borrowerRoleDescription;

  /// No description provided for @continueAsBorrower.
  ///
  /// In en, this message translates to:
  /// **'Continue as borrower'**
  String get continueAsBorrower;

  /// No description provided for @lenderRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Lender'**
  String get lenderRoleTitle;

  /// No description provided for @lenderRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse verified loans, fund a part of one and track your returns.'**
  String get lenderRoleDescription;

  /// No description provided for @continueAsLender.
  ///
  /// In en, this message translates to:
  /// **'Continue as lender'**
  String get continueAsLender;

  /// No description provided for @signedInAsPhone.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {phone}'**
  String signedInAsPhone(Object phone);

  /// No description provided for @verifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyIdentityTitle;

  /// No description provided for @kycChecklistIntro.
  ///
  /// In en, this message translates to:
  /// **'Complete four steps to unlock borrowing and lending'**
  String get kycChecklistIntro;

  /// No description provided for @kycDocumentUsageNote.
  ///
  /// In en, this message translates to:
  /// **'Your documents are used only to verify your identity.'**
  String get kycDocumentUsageNote;

  /// No description provided for @kycVerifiedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 verified'**
  String kycVerifiedCount(Object count);

  /// No description provided for @demoAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo admin'**
  String get demoAdminTitle;

  /// No description provided for @demoAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'No reviewer is online in mock mode. Approve the four submitted steps to continue the demo.'**
  String get demoAdminDescription;

  /// No description provided for @approveAllStepsButton.
  ///
  /// In en, this message translates to:
  /// **'Approve all steps'**
  String get approveAllStepsButton;

  /// No description provided for @kycStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get kycStatusVerified;

  /// No description provided for @kycStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get kycStatusInReview;

  /// No description provided for @kycStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get kycStatusRejected;

  /// No description provided for @kycStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get kycStatusNotStarted;

  /// No description provided for @kycStepNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'{number}. {stepLabel}'**
  String kycStepNumberTitle(Object number, Object stepLabel);

  /// No description provided for @kycRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String kycRejectionReason(Object reason);

  /// No description provided for @captureDocumentFirstError.
  ///
  /// In en, this message translates to:
  /// **'Capture or choose a document first.'**
  String get captureDocumentFirstError;

  /// No description provided for @kycStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {stepNumber} of 4'**
  String kycStepProgress(Object stepNumber);

  /// No description provided for @kycRejectedNotice.
  ///
  /// In en, this message translates to:
  /// **'Rejected: {reason}. Check the details and submit again.'**
  String kycRejectedNotice(Object reason);

  /// No description provided for @kycRejectedNoticeNoReason.
  ///
  /// In en, this message translates to:
  /// **'Rejected. Check the details and submit again.'**
  String get kycRejectedNoticeNoReason;

  /// No description provided for @resubmitForReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Resubmit for review'**
  String get resubmitForReviewButton;

  /// No description provided for @submitForReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReviewButton;

  /// No description provided for @backToChecklistButton.
  ///
  /// In en, this message translates to:
  /// **'Back to checklist'**
  String get backToChecklistButton;

  /// No description provided for @takePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhotoButton;

  /// No description provided for @chooseFromGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGalleryButton;

  /// No description provided for @selectedDocumentText.
  ///
  /// In en, this message translates to:
  /// **'Selected: {fileName}'**
  String selectedDocumentText(Object fileName);

  /// No description provided for @chooseDifferentPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Choose a different photo'**
  String get chooseDifferentPhotoButton;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name (as on citizenship)'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Sita Sharma'**
  String get fullNameHint;

  /// No description provided for @enterFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get enterFullNameError;

  /// No description provided for @citizenshipNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Citizenship number'**
  String get citizenshipNumberLabel;

  /// No description provided for @citizenshipNumberHint.
  ///
  /// In en, this message translates to:
  /// **'000-00-000000'**
  String get citizenshipNumberHint;

  /// No description provided for @enterCitizenshipNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter your citizenship number.'**
  String get enterCitizenshipNumberError;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirthLabel;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateOfBirthHint;

  /// No description provided for @invalidDateFormatError.
  ///
  /// In en, this message translates to:
  /// **'Use the format YYYY-MM-DD.'**
  String get invalidDateFormatError;

  /// No description provided for @bankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get bankNameLabel;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nepal Bank Limited'**
  String get bankNameHint;

  /// No description provided for @enterBankNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your bank name.'**
  String get enterBankNameError;

  /// No description provided for @bankAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank account number'**
  String get bankAccountNumberLabel;

  /// No description provided for @bankAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'0000000000'**
  String get bankAccountNumberHint;

  /// No description provided for @enterFiveToTwentyDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter 5–20 digits.'**
  String get enterFiveToTwentyDigitsError;

  /// No description provided for @kycStepVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'{stepLabel} verified'**
  String kycStepVerifiedTitle(Object stepLabel);

  /// No description provided for @kycStepLockedNote.
  ///
  /// In en, this message translates to:
  /// **'This step is locked. Your reviewer approved it.'**
  String get kycStepLockedNote;

  /// No description provided for @kycStepSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'{stepLabel} submitted'**
  String kycStepSubmittedTitle(Object stepLabel);

  /// No description provided for @kycStepReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Your submission is in review. You can continue once a reviewer approves it.'**
  String get kycStepReviewNote;

  /// No description provided for @demoReviewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo reviewer'**
  String get demoReviewerTitle;

  /// No description provided for @rejectionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason (optional)'**
  String get rejectionReasonLabel;

  /// No description provided for @rejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Photo is blurry'**
  String get rejectionReasonHint;

  /// No description provided for @approveStepButton.
  ///
  /// In en, this message translates to:
  /// **'Approve step'**
  String get approveStepButton;

  /// No description provided for @rejectStepButton.
  ///
  /// In en, this message translates to:
  /// **'Reject step'**
  String get rejectStepButton;

  /// No description provided for @borrowerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get borrowerFallbackName;

  /// No description provided for @borrowerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrower home'**
  String get borrowerHomeTitle;

  /// No description provided for @namasteGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String namasteGreeting(Object name);

  /// No description provided for @borrowerHomeIntro.
  ///
  /// In en, this message translates to:
  /// **'Request a verified loan and see exactly what you will repay.'**
  String get borrowerHomeIntro;

  /// No description provided for @requestLoanButton.
  ///
  /// In en, this message translates to:
  /// **'Request a loan'**
  String get requestLoanButton;

  /// No description provided for @makeRepaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Make a repayment'**
  String get makeRepaymentButton;

  /// No description provided for @yourApplicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your applications'**
  String get yourApplicationsTitle;

  /// No description provided for @noLoanRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No loan requests yet'**
  String get noLoanRequestsYet;

  /// No description provided for @noLoanRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your applications and agreements will appear here.'**
  String get noLoanRequestsMessage;

  /// No description provided for @tenorMonthsText.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String tenorMonthsText(Object count);

  /// No description provided for @loanStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get loanStatusDraft;

  /// No description provided for @loanStatusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get loanStatusPendingReview;

  /// No description provided for @loanStatusOpenForFunding.
  ///
  /// In en, this message translates to:
  /// **'Open for funding'**
  String get loanStatusOpenForFunding;

  /// No description provided for @loanStatusFunded.
  ///
  /// In en, this message translates to:
  /// **'Funded'**
  String get loanStatusFunded;

  /// No description provided for @loanStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loanStatusActive;

  /// No description provided for @loanStatusRepaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get loanStatusRepaid;

  /// No description provided for @loanStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get loanStatusRejected;

  /// No description provided for @loanStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get loanStatusExpired;

  /// No description provided for @loanStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get loanStatusCancelled;

  /// No description provided for @loanStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get loanStatusOverdue;

  /// No description provided for @loanStatusDefaulted.
  ///
  /// In en, this message translates to:
  /// **'Defaulted'**
  String get loanStatusDefaulted;

  /// No description provided for @riskMarkerPositive.
  ///
  /// In en, this message translates to:
  /// **'+'**
  String get riskMarkerPositive;

  /// No description provided for @riskMarkerNeutral.
  ///
  /// In en, this message translates to:
  /// **'•'**
  String get riskMarkerNeutral;

  /// No description provided for @riskMarkerNegative.
  ///
  /// In en, this message translates to:
  /// **'−'**
  String get riskMarkerNegative;

  /// No description provided for @riskDirectionPositiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Positive factor'**
  String get riskDirectionPositiveLabel;

  /// No description provided for @riskDirectionNeutralLabel.
  ///
  /// In en, this message translates to:
  /// **'Neutral factor'**
  String get riskDirectionNeutralLabel;

  /// No description provided for @riskDirectionNegativeLabel.
  ///
  /// In en, this message translates to:
  /// **'Negative factor'**
  String get riskDirectionNegativeLabel;

  /// No description provided for @loanAmountOutOfRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between {minAmount} and {maxAmount}.'**
  String loanAmountOutOfRangeError(Object maxAmount, Object minAmount);

  /// No description provided for @invalidTenorRangeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a tenor between 3 and 60 months.'**
  String get invalidTenorRangeError;

  /// No description provided for @enterMonthlyIncomeError.
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly income.'**
  String get enterMonthlyIncomeError;

  /// No description provided for @requestLoanTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a loan'**
  String get requestLoanTitle;

  /// No description provided for @requestLoanIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell lenders what you need. We will show the rate, exact instalment and the reasons behind your grade.'**
  String get requestLoanIntro;

  /// No description provided for @purposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purposeLabel;

  /// No description provided for @purposeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Business inventory'**
  String get purposeHint;

  /// No description provided for @describePurposeError.
  ///
  /// In en, this message translates to:
  /// **'Describe the purpose.'**
  String get describePurposeError;

  /// No description provided for @loanAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan amount'**
  String get loanAmountLabel;

  /// No description provided for @loanAmountHint.
  ///
  /// In en, this message translates to:
  /// **'2,00,000'**
  String get loanAmountHint;

  /// No description provided for @nprPrefix.
  ///
  /// In en, this message translates to:
  /// **'NPR '**
  String get nprPrefix;

  /// No description provided for @enterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount.'**
  String get enterAmountError;

  /// No description provided for @tenorLabel.
  ///
  /// In en, this message translates to:
  /// **'Tenor (months)'**
  String get tenorLabel;

  /// No description provided for @tenorHint.
  ///
  /// In en, this message translates to:
  /// **'12'**
  String get tenorHint;

  /// No description provided for @enterWholeMonthsError.
  ///
  /// In en, this message translates to:
  /// **'Enter whole months.'**
  String get enterWholeMonthsError;

  /// No description provided for @monthlyIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get monthlyIncomeLabel;

  /// No description provided for @monthlyIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'50,000'**
  String get monthlyIncomeHint;

  /// No description provided for @seeMyRiskGradeButton.
  ///
  /// In en, this message translates to:
  /// **'See my risk grade'**
  String get seeMyRiskGradeButton;

  /// No description provided for @requestLoanDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: no credit bureau call and no real money moves.'**
  String get requestLoanDemoNote;

  /// No description provided for @riskReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your risk review'**
  String get riskReviewTitle;

  /// No description provided for @loanTermsSummary.
  ///
  /// In en, this message translates to:
  /// **'{months} months · {rate} p.a.'**
  String loanTermsSummary(Object months, Object rate);

  /// No description provided for @riskScoreText.
  ///
  /// In en, this message translates to:
  /// **'Score {score}/100'**
  String riskScoreText(Object score);

  /// No description provided for @whyThisGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this grade'**
  String get whyThisGradeTitle;

  /// No description provided for @riskModelExplanation.
  ///
  /// In en, this message translates to:
  /// **'Model {modelVersion} · affordability, amount, tenor, verification and history.'**
  String riskModelExplanation(Object modelVersion);

  /// No description provided for @manualReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'This request is flagged for manual review. Use the demo control to approve it.'**
  String get manualReviewNotice;

  /// No description provided for @demoApproveRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Demo approve request'**
  String get demoApproveRequestButton;

  /// No description provided for @continueToAgreementButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to agreement'**
  String get continueToAgreementButton;

  /// No description provided for @repaymentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Repayment preview'**
  String get repaymentPreviewTitle;

  /// No description provided for @monthlyInstalmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly instalment'**
  String get monthlyInstalmentLabel;

  /// No description provided for @totalRepayableLabel.
  ///
  /// In en, this message translates to:
  /// **'Total repayable'**
  String get totalRepayableLabel;

  /// No description provided for @interestLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interestLabel;

  /// No description provided for @platformFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform fee (10% of interest)'**
  String get platformFeeLabel;

  /// No description provided for @typeFullNameToSignError.
  ///
  /// In en, this message translates to:
  /// **'Type your full name to sign.'**
  String get typeFullNameToSignError;

  /// No description provided for @acceptTermsBeforeSigningError.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms before signing.'**
  String get acceptTermsBeforeSigningError;

  /// No description provided for @loanAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan agreement'**
  String get loanAgreementTitle;

  /// No description provided for @termsVersionText.
  ///
  /// In en, this message translates to:
  /// **'Terms version {version}'**
  String termsVersionText(Object version);

  /// No description provided for @termsHashText.
  ///
  /// In en, this message translates to:
  /// **'Terms hash: {hash}'**
  String termsHashText(Object hash);

  /// No description provided for @signedFundsDisbursedChip.
  ///
  /// In en, this message translates to:
  /// **'Signed · funds disbursed'**
  String get signedFundsDisbursedChip;

  /// No description provided for @signedByOnText.
  ///
  /// In en, this message translates to:
  /// **'Signed by {signedBy} on {signedAt}'**
  String signedByOnText(Object signedAt, Object signedBy);

  /// No description provided for @viewDisbursementReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'View disbursement receipt'**
  String get viewDisbursementReceiptButton;

  /// No description provided for @typeFullNameToSignLabel.
  ///
  /// In en, this message translates to:
  /// **'Type your full name to sign'**
  String get typeFullNameToSignLabel;

  /// No description provided for @legalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your legal name'**
  String get legalNameHint;

  /// No description provided for @acceptTermsCheckboxLabel.
  ///
  /// In en, this message translates to:
  /// **'I accept these terms and the repayment schedule.'**
  String get acceptTermsCheckboxLabel;

  /// No description provided for @signAndReceiveFundsButton.
  ///
  /// In en, this message translates to:
  /// **'Sign and receive funds'**
  String get signAndReceiveFundsButton;

  /// No description provided for @approveBeforeSigningNotice.
  ///
  /// In en, this message translates to:
  /// **'Approve the request on the risk review screen before signing.'**
  String get approveBeforeSigningNotice;

  /// No description provided for @demoEscrowNote.
  ///
  /// In en, this message translates to:
  /// **'Demo escrow is simulated: signing records the escrow → wallet journal after lenders fund the loan.'**
  String get demoEscrowNote;

  /// No description provided for @repaymentScheduleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Repayment schedule ({count} instalments)'**
  String repaymentScheduleWithCount(Object count);

  /// No description provided for @instalmentNumberText.
  ///
  /// In en, this message translates to:
  /// **'{number}.'**
  String instalmentNumberText(Object number);

  /// No description provided for @displayDate.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year}'**
  String displayDate(Object day, Object month, Object year);

  /// No description provided for @stakeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get stakeStatusActive;

  /// No description provided for @stakeStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned after expiry'**
  String get stakeStatusReturned;

  /// No description provided for @verifiedBorrowerFallback.
  ///
  /// In en, this message translates to:
  /// **'Verified borrower'**
  String get verifiedBorrowerFallback;

  /// No description provided for @lenderHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lender home'**
  String get lenderHomeTitle;

  /// No description provided for @lenderHomeIntro.
  ///
  /// In en, this message translates to:
  /// **'Your lending at a glance'**
  String get lenderHomeIntro;

  /// No description provided for @walletBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalanceLabel;

  /// No description provided for @activeStakesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active stakes'**
  String get activeStakesLabel;

  /// No description provided for @activeStakesCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String activeStakesCount(Object count);

  /// No description provided for @amountCommittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount committed'**
  String get amountCommittedLabel;

  /// No description provided for @browseVerifiedLoansButton.
  ///
  /// In en, this message translates to:
  /// **'Browse verified loans'**
  String get browseVerifiedLoansButton;

  /// No description provided for @viewMyPortfolioButton.
  ///
  /// In en, this message translates to:
  /// **'View my portfolio'**
  String get viewMyPortfolioButton;

  /// No description provided for @addMoneyToWalletButton.
  ///
  /// In en, this message translates to:
  /// **'Add money to wallet'**
  String get addMoneyToWalletButton;

  /// No description provided for @openLoansSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} loans currently open for funding.'**
  String openLoansSummary(Object count);

  /// No description provided for @openLoansSummarySingular.
  ///
  /// In en, this message translates to:
  /// **'{count} loan currently open for funding.'**
  String openLoansSummarySingular(Object count);

  /// No description provided for @browseLoansTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse loans'**
  String get browseLoansTitle;

  /// No description provided for @fundVerifiedBorrower.
  ///
  /// In en, this message translates to:
  /// **'Fund a verified borrower'**
  String get fundVerifiedBorrower;

  /// No description provided for @riskBandLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk band'**
  String get riskBandLabel;

  /// No description provided for @riskBandAll.
  ///
  /// In en, this message translates to:
  /// **'All bands'**
  String get riskBandAll;

  /// No description provided for @riskBandLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get riskBandLow;

  /// No description provided for @riskBandMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get riskBandMedium;

  /// No description provided for @riskBandHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get riskBandHigh;

  /// No description provided for @minAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Min amount'**
  String get minAmountLabel;

  /// No description provided for @minAmountHint.
  ///
  /// In en, this message translates to:
  /// **'10000'**
  String get minAmountHint;

  /// No description provided for @maxAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Max amount'**
  String get maxAmountLabel;

  /// No description provided for @maxAmountHint.
  ///
  /// In en, this message translates to:
  /// **'200000'**
  String get maxAmountHint;

  /// No description provided for @maxTenorLabel.
  ///
  /// In en, this message translates to:
  /// **'Max tenor (months)'**
  String get maxTenorLabel;

  /// No description provided for @maxTenorHint.
  ///
  /// In en, this message translates to:
  /// **'12'**
  String get maxTenorHint;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortAmountAscending.
  ///
  /// In en, this message translates to:
  /// **'Amount ↑'**
  String get sortAmountAscending;

  /// No description provided for @sortAmountDescending.
  ///
  /// In en, this message translates to:
  /// **'Amount ↓'**
  String get sortAmountDescending;

  /// No description provided for @sortLowestRisk.
  ///
  /// In en, this message translates to:
  /// **'Lowest risk'**
  String get sortLowestRisk;

  /// No description provided for @applyFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFiltersButton;

  /// No description provided for @openLoansTitle.
  ///
  /// In en, this message translates to:
  /// **'Open loans'**
  String get openLoansTitle;

  /// No description provided for @openLoansCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String openLoansCount(Object count);

  /// No description provided for @noLoansMatch.
  ///
  /// In en, this message translates to:
  /// **'No loans match'**
  String get noLoansMatch;

  /// No description provided for @noLoansMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try widening the amount or tenor filters.'**
  String get noLoansMatchMessage;

  /// No description provided for @tenorMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} mo'**
  String tenorMonthsShort(Object count);

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @yourStakesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your stakes'**
  String get yourStakesTitle;

  /// No description provided for @activePrincipalText.
  ///
  /// In en, this message translates to:
  /// **'Active principal: {amount}'**
  String activePrincipalText(Object amount);

  /// No description provided for @noStakesYet.
  ///
  /// In en, this message translates to:
  /// **'No stakes yet'**
  String get noStakesYet;

  /// No description provided for @noStakesMessage.
  ///
  /// In en, this message translates to:
  /// **'Browse verified loans and fund one to get started.'**
  String get noStakesMessage;

  /// No description provided for @stakeInLoanText.
  ///
  /// In en, this message translates to:
  /// **'Stake in {loanId}'**
  String stakeInLoanText(Object loanId);

  /// No description provided for @loanDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan details'**
  String get loanDetailsTitle;

  /// No description provided for @needsMoreByDate.
  ///
  /// In en, this message translates to:
  /// **'Needs {amount} more by {date}.'**
  String needsMoreByDate(Object amount, Object date);

  /// No description provided for @identityVerifiedNote.
  ///
  /// In en, this message translates to:
  /// **'Identity verified · KYC complete'**
  String get identityVerifiedNote;

  /// No description provided for @riskFactorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk factors'**
  String get riskFactorsTitle;

  /// No description provided for @riskFactorLine.
  ///
  /// In en, this message translates to:
  /// **'{name}: {note}'**
  String riskFactorLine(Object name, Object note);

  /// No description provided for @modelScoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Model {modelVersion} · score {score}/100.'**
  String modelScoreSummary(Object modelVersion, Object score);

  /// No description provided for @fundThisLoanButton.
  ///
  /// In en, this message translates to:
  /// **'Fund this loan'**
  String get fundThisLoanButton;

  /// No description provided for @loanNotOpenForFunding.
  ///
  /// In en, this message translates to:
  /// **'This loan is no longer open for funding.'**
  String get loanNotOpenForFunding;

  /// No description provided for @dateToBeConfirmed.
  ///
  /// In en, this message translates to:
  /// **'a date to be confirmed'**
  String get dateToBeConfirmed;

  /// No description provided for @fundLoanTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund loan'**
  String get fundLoanTitle;

  /// No description provided for @stillNeededOfTotalText.
  ///
  /// In en, this message translates to:
  /// **'{remaining} still needed of {total}.'**
  String stillNeededOfTotalText(Object remaining, Object total);

  /// No description provided for @amountToStakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to stake'**
  String get amountToStakeLabel;

  /// No description provided for @amountToStakeHint.
  ///
  /// In en, this message translates to:
  /// **'1000'**
  String get amountToStakeHint;

  /// No description provided for @walletBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet before'**
  String get walletBeforeLabel;

  /// No description provided for @interestShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Your interest share'**
  String get interestShareLabel;

  /// No description provided for @walletAfterLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet after'**
  String get walletAfterLabel;

  /// No description provided for @confirmFundingButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm funding'**
  String get confirmFundingButton;

  /// No description provided for @demoFundingNote.
  ///
  /// In en, this message translates to:
  /// **'Demo funding debits your simulated wallet and credits the loan escrow. No real money moves.'**
  String get demoFundingNote;

  /// No description provided for @minimumStakeError.
  ///
  /// In en, this message translates to:
  /// **'The minimum stake is {amount}.'**
  String minimumStakeError(Object amount);

  /// No description provided for @onlyStillNeededError.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} is still needed.'**
  String onlyStillNeededError(Object amount);

  /// No description provided for @topUpWalletFirstError.
  ///
  /// In en, this message translates to:
  /// **'Top up your wallet first.'**
  String get topUpWalletFirstError;

  /// No description provided for @stakeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stake details'**
  String get stakeDetailsTitle;

  /// No description provided for @yourStakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your stake'**
  String get yourStakeTitle;

  /// No description provided for @stakeLoanLine.
  ///
  /// In en, this message translates to:
  /// **'Loan: {purpose}'**
  String stakeLoanLine(Object purpose);

  /// No description provided for @stakeBorrowerLine.
  ///
  /// In en, this message translates to:
  /// **'Borrower: {borrowerName}'**
  String stakeBorrowerLine(Object borrowerName);

  /// No description provided for @fundedOnDateText.
  ///
  /// In en, this message translates to:
  /// **'Funded {date}'**
  String fundedOnDateText(Object date);

  /// No description provided for @ledgerTrailTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger trail'**
  String get ledgerTrailTitle;

  /// No description provided for @viewFundingReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'View funding receipt'**
  String get viewFundingReceiptButton;

  /// No description provided for @viewExpiryReversalButton.
  ///
  /// In en, this message translates to:
  /// **'View expiry reversal'**
  String get viewExpiryReversalButton;

  /// No description provided for @stakeReturnedNote.
  ///
  /// In en, this message translates to:
  /// **'The loan expired before it was fully funded. Escrow was reversed and this stake returned to your wallet.'**
  String get stakeReturnedNote;

  /// No description provided for @unknownDateText.
  ///
  /// In en, this message translates to:
  /// **'on an unknown date'**
  String get unknownDateText;

  /// No description provided for @confirmRepaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm repayment'**
  String get confirmRepaymentTitle;

  /// No description provided for @repaymentSheetDetail.
  ///
  /// In en, this message translates to:
  /// **'A simulated {provider} payment pays instalment {instalmentNumber}. The platform fee is {fee}.'**
  String repaymentSheetDetail(
    Object fee,
    Object instalmentNumber,
    Object provider,
  );

  /// No description provided for @payInstalmentButton.
  ///
  /// In en, this message translates to:
  /// **'Pay instalment'**
  String get payInstalmentButton;

  /// No description provided for @makeRepaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Make a repayment'**
  String get makeRepaymentTitle;

  /// No description provided for @payOneAtATimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay one instalment at a time'**
  String get payOneAtATimeTitle;

  /// No description provided for @repaymentSplitNote.
  ///
  /// In en, this message translates to:
  /// **'Principal and interest are split across every lender stake automatically. A 10% platform fee is taken from interest.'**
  String get repaymentSplitNote;

  /// No description provided for @nothingToRepayYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to repay yet'**
  String get nothingToRepayYet;

  /// No description provided for @nothingToRepayMessage.
  ///
  /// In en, this message translates to:
  /// **'Once a loan is funded and signed, your instalments will appear here.'**
  String get nothingToRepayMessage;

  /// No description provided for @instalmentProgressText.
  ///
  /// In en, this message translates to:
  /// **'Instalment {number} of {total}'**
  String instalmentProgressText(Object number, Object total);

  /// No description provided for @dueDateText.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDateText(Object date);

  /// No description provided for @amountToPayLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPayLabel;

  /// No description provided for @principalLabel.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principalLabel;

  /// No description provided for @lendersReceiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Lenders receive'**
  String get lendersReceiveLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// No description provided for @paymentProviderEsewaLabel.
  ///
  /// In en, this message translates to:
  /// **'eSewa (simulated)'**
  String get paymentProviderEsewaLabel;

  /// No description provided for @paymentProviderKhaltiLabel.
  ///
  /// In en, this message translates to:
  /// **'Khalti (simulated)'**
  String get paymentProviderKhaltiLabel;

  /// No description provided for @payAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmountButton(Object amount);

  /// No description provided for @instalmentPaidChip.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get instalmentPaidChip;

  /// No description provided for @instalmentDueChip.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get instalmentDueChip;

  /// No description provided for @repaymentStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get repaymentStatusProcessing;

  /// No description provided for @repaymentStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get repaymentStatusLate;

  /// No description provided for @repaymentStatusNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get repaymentStatusNextUp;

  /// No description provided for @providerLabelKhalti.
  ///
  /// In en, this message translates to:
  /// **'Khalti'**
  String get providerLabelKhalti;

  /// No description provided for @providerLabelEsewa.
  ///
  /// In en, this message translates to:
  /// **'eSewa'**
  String get providerLabelEsewa;

  /// No description provided for @repaymentScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Repayment schedule'**
  String get repaymentScheduleTitle;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @unreadCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String unreadCountBadge(Object count);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllReadButton.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllReadButton;

  /// No description provided for @allCaughtUpText.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get allCaughtUpText;

  /// No description provided for @unreadCountText.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadCountText(Object count);

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Funding, repayments and payment reminders will appear here.'**
  String get noNotificationsMessage;

  /// No description provided for @notificationNewChip.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationNewChip;

  /// No description provided for @demoClockLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo clock: {date}'**
  String demoClockLabel(Object date);

  /// No description provided for @clockAdvanceOneDay.
  ///
  /// In en, this message translates to:
  /// **'+1 day'**
  String get clockAdvanceOneDay;

  /// No description provided for @clockAdvanceSevenDays.
  ///
  /// In en, this message translates to:
  /// **'+7 days'**
  String get clockAdvanceSevenDays;

  /// No description provided for @clockAdvanceOneMonth.
  ///
  /// In en, this message translates to:
  /// **'+1 month'**
  String get clockAdvanceOneMonth;

  /// No description provided for @clockResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get clockResetButton;

  /// No description provided for @demoRemindersButton.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get demoRemindersButton;

  /// No description provided for @paymentRemindersSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders sent: {count}'**
  String paymentRemindersSentSnackbar(Object count);

  /// No description provided for @demoMarkOverdueButton.
  ///
  /// In en, this message translates to:
  /// **'Mark overdue'**
  String get demoMarkOverdueButton;

  /// No description provided for @loansMarkedOverdueSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Loans marked overdue: {count}'**
  String loansMarkedOverdueSnackbar(Object count);

  /// No description provided for @demoReconcileButton.
  ///
  /// In en, this message translates to:
  /// **'Reconcile'**
  String get demoReconcileButton;

  /// No description provided for @ledgerCleanSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Ledger clean ({count} journals)'**
  String ledgerCleanSnackbar(Object count);

  /// No description provided for @ledgerIssuesSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Ledger issues: {unbalancedCount} unbalanced, {negativeCount} negative'**
  String ledgerIssuesSnackbar(Object negativeCount, Object unbalancedCount);

  /// No description provided for @demoStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen state'**
  String get demoStateTitle;

  /// No description provided for @demoStateNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get demoStateNormal;

  /// No description provided for @demoStateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get demoStateLoading;

  /// No description provided for @demoStateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get demoStateEmpty;

  /// No description provided for @demoStateError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get demoStateError;

  /// No description provided for @demoStateOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get demoStateOffline;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalanceLabel;

  /// No description provided for @topUpButton.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUpButton;

  /// No description provided for @withdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawButton;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivityTitle;

  /// No description provided for @noWalletActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No wallet activity yet'**
  String get noWalletActivityYet;

  /// No description provided for @noWalletActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'Top up your wallet to start lending.'**
  String get noWalletActivityMessage;

  /// No description provided for @minimumAmountError.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is NPR 1,000.'**
  String get minimumAmountError;

  /// No description provided for @amountExceedsBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Amount is more than your wallet balance.'**
  String get amountExceedsBalanceError;

  /// No description provided for @confirmTopUpSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm top-up'**
  String get confirmTopUpSheetTitle;

  /// No description provided for @confirmWithdrawalSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get confirmWithdrawalSheetTitle;

  /// No description provided for @topUpSheetDetail.
  ///
  /// In en, this message translates to:
  /// **'A simulated payment adds this amount to your wallet.'**
  String get topUpSheetDetail;

  /// No description provided for @withdrawalSheetDetail.
  ///
  /// In en, this message translates to:
  /// **'This amount leaves your wallet and is sent to your bank.'**
  String get withdrawalSheetDetail;

  /// No description provided for @confirmTopUpButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm top-up'**
  String get confirmTopUpButton;

  /// No description provided for @confirmWithdrawalButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get confirmWithdrawalButton;

  /// No description provided for @topUpWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up wallet'**
  String get topUpWalletTitle;

  /// No description provided for @withdrawToBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to bank'**
  String get withdrawToBankTitle;

  /// No description provided for @topUpIntro.
  ///
  /// In en, this message translates to:
  /// **'Add money to your wallet to fund loans.'**
  String get topUpIntro;

  /// No description provided for @withdrawalIntro.
  ///
  /// In en, this message translates to:
  /// **'Move money from your wallet to your bank account.'**
  String get withdrawalIntro;

  /// No description provided for @amountToAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get amountToAddLabel;

  /// No description provided for @amountToWithdrawLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to withdraw'**
  String get amountToWithdrawLabel;

  /// No description provided for @walletAmountHint.
  ///
  /// In en, this message translates to:
  /// **'10,000'**
  String get walletAmountHint;

  /// No description provided for @reviewTopUpButton.
  ///
  /// In en, this message translates to:
  /// **'Review top-up'**
  String get reviewTopUpButton;

  /// No description provided for @reviewWithdrawalButton.
  ///
  /// In en, this message translates to:
  /// **'Review withdrawal'**
  String get reviewWithdrawalButton;

  /// No description provided for @demoPaymentGatewayNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode uses a simulated payment gateway. No real money moves.'**
  String get demoPaymentGatewayNote;

  /// No description provided for @transactionReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction receipt'**
  String get transactionReceiptTitle;

  /// No description provided for @moneyMoveRecordedText.
  ///
  /// In en, this message translates to:
  /// **'Money move recorded'**
  String get moneyMoveRecordedText;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceLabel;

  /// No description provided for @journalIdLine.
  ///
  /// In en, this message translates to:
  /// **'Journal: {journalId}'**
  String journalIdLine(Object journalId);

  /// No description provided for @journalTypeLine.
  ///
  /// In en, this message translates to:
  /// **'Type: {journalType}'**
  String journalTypeLine(Object journalType);

  /// No description provided for @journalCreatedLine.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String journalCreatedLine(Object date);

  /// No description provided for @replayedRequestChip.
  ///
  /// In en, this message translates to:
  /// **'Replayed request'**
  String get replayedRequestChip;

  /// No description provided for @ledgerEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger entries'**
  String get ledgerEntriesTitle;

  /// No description provided for @styleGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Style guide'**
  String get styleGuideTitle;

  /// No description provided for @styleGuideColoursSection.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get styleGuideColoursSection;

  /// No description provided for @swatchPrimaryLabel.
  ///
  /// In en, this message translates to:
  /// **'primary'**
  String get swatchPrimaryLabel;

  /// No description provided for @swatchSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get swatchSuccessLabel;

  /// No description provided for @swatchWarningLabel.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get swatchWarningLabel;

  /// No description provided for @swatchErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get swatchErrorLabel;

  /// No description provided for @swatchRiskLowLabel.
  ///
  /// In en, this message translates to:
  /// **'risk low'**
  String get swatchRiskLowLabel;

  /// No description provided for @swatchRiskMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'risk medium'**
  String get swatchRiskMediumLabel;

  /// No description provided for @swatchRiskHighLabel.
  ///
  /// In en, this message translates to:
  /// **'risk high'**
  String get swatchRiskHighLabel;

  /// No description provided for @styleGuideTypographySection.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get styleGuideTypographySection;

  /// No description provided for @typographyDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display title'**
  String get typographyDisplayTitle;

  /// No description provided for @typographyTitleSample.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get typographyTitleSample;

  /// No description provided for @typographyBodySample.
  ///
  /// In en, this message translates to:
  /// **'Body text'**
  String get typographyBodySample;

  /// No description provided for @typographyCaptionSample.
  ///
  /// In en, this message translates to:
  /// **'Caption text'**
  String get typographyCaptionSample;

  /// No description provided for @styleGuideButtonsSection.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get styleGuideButtonsSection;

  /// No description provided for @styleGuidePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Primary action'**
  String get styleGuidePrimaryAction;

  /// No description provided for @styleGuideSecondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Secondary action'**
  String get styleGuideSecondaryAction;

  /// No description provided for @styleGuideDisabledButton.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get styleGuideDisabledButton;

  /// No description provided for @styleGuideInputsSection.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get styleGuideInputsSection;

  /// No description provided for @styleGuideAmountHint.
  ///
  /// In en, this message translates to:
  /// **'1,00,000'**
  String get styleGuideAmountHint;

  /// No description provided for @styleGuideCardsSection.
  ///
  /// In en, this message translates to:
  /// **'Cards and amounts'**
  String get styleGuideCardsSection;

  /// No description provided for @styleGuideDemoGrade.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get styleGuideDemoGrade;

  /// No description provided for @styleGuideProgressSection.
  ///
  /// In en, this message translates to:
  /// **'Progress and statuses'**
  String get styleGuideProgressSection;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get statusInReview;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @styleGuideStatesSection.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get styleGuideStatesSection;

  /// No description provided for @styleGuideNoLoansYet.
  ///
  /// In en, this message translates to:
  /// **'No loans yet'**
  String get styleGuideNoLoansYet;

  /// No description provided for @styleGuideNoLoansMessage.
  ///
  /// In en, this message translates to:
  /// **'New requests will appear here.'**
  String get styleGuideNoLoansMessage;

  /// No description provided for @styleGuideErrorStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load loans.'**
  String get styleGuideErrorStateMessage;

  /// No description provided for @styleGuideBottomSheetSection.
  ///
  /// In en, this message translates to:
  /// **'Bottom sheet'**
  String get styleGuideBottomSheetSection;

  /// No description provided for @openConfirmationSheetButton.
  ///
  /// In en, this message translates to:
  /// **'Open confirmation sheet'**
  String get openConfirmationSheetButton;

  /// No description provided for @confirmFundingSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm funding'**
  String get confirmFundingSheetTitle;

  /// No description provided for @confirmAndFundButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm and fund'**
  String get confirmAndFundButton;

  /// No description provided for @expectedInterestDemoText.
  ///
  /// In en, this message translates to:
  /// **'Expected interest: NPR 410.00'**
  String get expectedInterestDemoText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
