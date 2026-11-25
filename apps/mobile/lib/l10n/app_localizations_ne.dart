// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'नेपाललेंड';

  @override
  String get navHomeLabel => 'गृह';

  @override
  String get navLoansLabel => 'ऋण';

  @override
  String get navProfileLabel => 'प्रोफाइल';

  @override
  String get navBrowseLabel => 'ब्राउज';

  @override
  String get navPortfolioLabel => 'पोर्टफोलियो';

  @override
  String get navWalletLabel => 'वallet';

  @override
  String get stepNotFoundTitle => 'चरण फेला परेन';

  @override
  String get stepNotFoundDescription => 'यो प्रमाणिकरण चरण अवस्थित छैन।';

  @override
  String get helpAndSafetyTitle => 'मद्दत र सुरक्षा';

  @override
  String get helpAndSafetyDescription =>
      'ऋण कसरी काम गर्छ, शुल्क र खाता निलम्बन भए के गर्ने।';

  @override
  String get myLoansTitle => 'मेरो ऋण';

  @override
  String get myLoansDescription => 'आवेदन, सम्झौता र भुक्तानी तालिका।';

  @override
  String get borrowerProfileTitle => 'प्रोफाइल';

  @override
  String get borrowerProfileDescription => 'फोन, भूमिका र प्रमाणिकरण स्थिति।';

  @override
  String get lenderProfileTitle => 'प्रोफाइल';

  @override
  String get lenderProfileDescription => 'फोन, भूमिका र प्रमाणिकरण स्थिति।';

  @override
  String get riskBandLowLabel => 'कम जोखिम';

  @override
  String get riskBandMediumLabel => 'मध्यम जोखिम';

  @override
  String get riskBandHighLabel => 'उच्च जोखिम';

  @override
  String riskBadgeText(Object grade, Object label) {
    return '$grade · $label';
  }

  @override
  String fundingProgressText(Object fundedAmount, Object percent) {
    return '$percent% कोष जम्मा · $fundedAmount';
  }

  @override
  String get tryAgain => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get nothingHereYet => 'अहिले केही छैन';

  @override
  String get demoErrorStateMessage => 'केही गडबड भयो (डेमो त्रुटि)।';

  @override
  String get youAreOffline => 'तपाईं अफलाइन हुनुहुन्छ';

  @override
  String get offlineMessage => 'आफ्नो जडान जाँच गरी फेरि प्रयास गर्नुहोस्।';

  @override
  String get openDetailsAction => 'विवरण खोल्नुहोस्';

  @override
  String get splashAppName => 'नेपाललेंड';

  @override
  String get signInTitle => 'साइन इन';

  @override
  String get loginEnterPhoneTitle => 'आफ्नो फोन नम्बर राख्नुहोस्';

  @override
  String get loginPhoneExplanation =>
      'हामी तपाईंको खाता सुरक्षित राख्न नम्बर प्रयोग गर्छौं। सामान्य SMS दर लाग्न सक्छ।';

  @override
  String get mobileNumberLabel => 'मोबाइल नम्बर';

  @override
  String get mobileNumberHint => '९८००००००००';

  @override
  String get nepalPhonePrefix => '+977 ';

  @override
  String get invalidMobileNumberError =>
      'मान्य १० अंकको नेपाली मोबाइल नम्बर राख्नुहोस्।';

  @override
  String get sendCodeButton => 'कोड पठाउनुहोस्';

  @override
  String get useDemoAccountButton => 'डेमो खाता प्रयोग गर्नुहोस्';

  @override
  String get loginDemoCodeHint =>
      'डेमो मात्र: कोड १२३४५६ · गलत ११११११ · व्यस्त ०००००० · अफलाइन ९९९९९९';

  @override
  String get verifyNumberTitle => 'आफ्नो नम्बर प्रमाणित गर्नुहोस्';

  @override
  String get requestCodeBeforeEnteringError => 'कोड राख्नुअघि कोड माग्नुहोस्।';

  @override
  String get enterSixDigitCodeTitle => '६ अंकको कोड राख्नुहोस्';

  @override
  String sentToPhoneText(Object phone) {
    return '$phone मा पठाइयो';
  }

  @override
  String get otpCodeLabel => 'कोड';

  @override
  String get otpCodeHint => '००००००';

  @override
  String get enterAllSixDigitsError => '६ वटै अंक राख्नुहोस्।';

  @override
  String get resendCodeButton => 'कोड फेरि पठाउनुहोस्';

  @override
  String resendCountdown(Object seconds) {
    return '$seconds सेकेन्डमा फेरि पठाउनुहोस्';
  }

  @override
  String get verifyAndContinueButton => 'प्रमाणित गरी अगाडि बढ्नुहोस्';

  @override
  String otpDemoCodeNotice(Object demoCode) {
    return 'डेमो कोड: $demoCode। यो निश्चित कोड डेमो मोडमा मात्र देखाइन्छ।';
  }

  @override
  String get onboardingSlide1Title => 'सीधै ऋण दिनुहोस् र लिनुहोस्';

  @override
  String get onboardingSlide1Body =>
      'नेपाललेंडले प्रमाणित ऋणीहरूलाई नेपालभरिका लगानीकर्तासँग जोड्छ।';

  @override
  String get onboardingSlide2Title =>
      'तपाईं कोसँग व्यवहार गर्दै हुनुहुन्छ जान्नुहोस्';

  @override
  String get onboardingSlide2Body =>
      'हर ऋणमा पहिचान जाँच र बुझ्न सकिने जोखिम ग्रेड।';

  @override
  String get onboardingSlide3Title => 'हर पैसाको हिसाब';

  @override
  String get onboardingSlide3Body =>
      'स्पष्ट सर्त, ठ्याक्कै किस्ता र हर पैसा कारोबारको रसिद।';

  @override
  String get onboardingSkip => 'छोड्नुहोस्';

  @override
  String get getStartedButton => 'सुरु गर्नुहोस्';

  @override
  String get nextButton => 'अर्को';

  @override
  String get chooseRoleTitle => 'आफ्नो भूमिका छान्नुहोस्';

  @override
  String get roleUsageQuestion => 'तपाईं नेपाललेंड कसरी प्रयोग गर्नुहुन्छ?';

  @override
  String get roleSelectionExplanation =>
      'तपाईंको भूमिकाले कुन उपकरण देखिने निर्धारण गर्छ। यो एक पटक मात्र छान्न सकिन्छ।';

  @override
  String get borrowerRoleTitle => 'ऋणी';

  @override
  String get borrowerRoleDescription =>
      'ऋण माग्नुहोस्, जोखिम ग्रेड हेर्नुहोस् र किस्तामा भुक्तानी गर्नुहोस्।';

  @override
  String get continueAsBorrower => 'ऋणीको रूपमा जारी राख्नुहोस्';

  @override
  String get lenderRoleTitle => 'लगानीकर्ता';

  @override
  String get lenderRoleDescription =>
      'प्रमाणित ऋण हेर्नुहोस्, केही रकम लगानी गर्नुहोस् र प्रतिफल ट्र्याक गर्नुहोस्।';

  @override
  String get continueAsLender => 'लगानीकर्ताको रूपमा जारी राख्नुहोस्';

  @override
  String signedInAsPhone(Object phone) {
    return '$phone को रूपमा साइन इन';
  }

  @override
  String get verifyIdentityTitle => 'आफ्नो पहिचान प्रमाणित गर्नुहोस्';

  @override
  String get kycChecklistIntro => 'ऋण र लगानी खोल्न चार चरण पूरा गर्नुहोस्';

  @override
  String get kycDocumentUsageNote =>
      'तपाईंका कागजातहरू पहिचान प्रमाणित गर्न मात्र प्रयोग गरिन्छ।';

  @override
  String kycVerifiedCount(Object count) {
    return '४ मध्ये $count प्रमाणित';
  }

  @override
  String get demoAdminTitle => 'डेमो प्रशासक';

  @override
  String get demoAdminDescription =>
      'डेमो मोडमा कुनै समीक्षक अनलाइन छैन। जारी राख्न चारवटै पेश गरिएका चरण स्वीकृत गर्नुहोस्।';

  @override
  String get approveAllStepsButton => 'सबै चरण स्वीकृत गर्नुहोस्';

  @override
  String get kycStatusVerified => 'प्रमाणित';

  @override
  String get kycStatusInReview => 'समीक्षाधीन';

  @override
  String get kycStatusRejected => 'अस्वीकृत';

  @override
  String get kycStatusNotStarted => 'सुरु भएको छैन';

  @override
  String kycStepNumberTitle(Object number, Object stepLabel) {
    return '$number. $stepLabel';
  }

  @override
  String kycRejectionReason(Object reason) {
    return 'कारण: $reason';
  }

  @override
  String get captureDocumentFirstError =>
      'पहिले कागजात खिच्नुहोस् वा छान्नुहोस्।';

  @override
  String kycStepProgress(Object stepNumber) {
    return 'चरण $stepNumber / ४';
  }

  @override
  String kycRejectedNotice(Object reason) {
    return 'अस्वीकृत: $reason। विवरण जाँच गरी फेरि पेश गर्नुहोस्।';
  }

  @override
  String get kycRejectedNoticeNoReason =>
      'अस्वीकृत। विवरण जाँच गरी फेरि पेश गर्नुहोस्।';

  @override
  String get resubmitForReviewButton => 'समीक्षाका लागि फेरि पेश गर्नुहोस्';

  @override
  String get submitForReviewButton => 'समीक्षाका लागि पेश गर्नुहोस्';

  @override
  String get backToChecklistButton => 'चेकलिस्टमा फर्कनुहोस्';

  @override
  String get takePhotoButton => 'फोटो खिच्नुहोस्';

  @override
  String get chooseFromGalleryButton => 'ग्यालरीबाट छान्नुहोस्';

  @override
  String selectedDocumentText(Object fileName) {
    return 'चयन गरिएको: $fileName';
  }

  @override
  String get chooseDifferentPhotoButton => 'अर्को फोटो छान्नुहोस्';

  @override
  String get fullNameLabel => 'पूरा नाम (नागरिकतामा जस्तो)';

  @override
  String get fullNameHint => 'सीता शर्मा';

  @override
  String get enterFullNameError => 'आफ्नो पूरा नाम राख्नुहोस्।';

  @override
  String get citizenshipNumberLabel => 'नागरिकता नम्बर';

  @override
  String get citizenshipNumberHint => '०००-००-००००००';

  @override
  String get enterCitizenshipNumberError => 'आफ्नो नागरिकता नम्बर राख्नुहोस्।';

  @override
  String get dateOfBirthLabel => 'जन्म मिति';

  @override
  String get dateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get invalidDateFormatError => 'YYYY-MM-DD ढाँचा प्रयोग गर्नुहोस्।';

  @override
  String get bankNameLabel => 'बैंकको नाम';

  @override
  String get bankNameHint => 'जस्तै: नेपाल बैंक लिमिटेड';

  @override
  String get enterBankNameError => 'आफ्नो बैंकको नाम राख्नुहोस्।';

  @override
  String get bankAccountNumberLabel => 'बैंक खाता नम्बर';

  @override
  String get bankAccountNumberHint => '००००००००००';

  @override
  String get enterFiveToTwentyDigitsError => '५–२० अंक राख्नुहोस्।';

  @override
  String kycStepVerifiedTitle(Object stepLabel) {
    return '$stepLabel प्रमाणित';
  }

  @override
  String get kycStepLockedNote =>
      'यो चरण लक गरिएको छ। समीक्षकले स्वीकृत गरेका छन्।';

  @override
  String kycStepSubmittedTitle(Object stepLabel) {
    return '$stepLabel पेश गरियो';
  }

  @override
  String get kycStepReviewNote =>
      'तपाईंको पेशकश समीक्षाधीन छ। समीक्षकले स्वीकृत गरेपछि अगाडि बढ्न सक्नुहुन्छ।';

  @override
  String get demoReviewerTitle => 'डेमो समीक्षक';

  @override
  String get rejectionReasonLabel => 'अस्वीकृतिको कारण (वैकल्पिक)';

  @override
  String get rejectionReasonHint => 'फोटो धमिलो छ';

  @override
  String get approveStepButton => 'चरण स्वीकृत गर्नुहोस्';

  @override
  String get rejectStepButton => 'चरण अस्वीकृत गर्नुहोस्';

  @override
  String get borrowerFallbackName => 'तपाईं';

  @override
  String get borrowerHomeTitle => 'ऋणी गृह';

  @override
  String namasteGreeting(Object name) {
    return 'नमस्ते, $name';
  }

  @override
  String get borrowerHomeIntro =>
      'ऋण माग्नुहोस् र कति तिर्नुपर्छ ठ्याक्कै हेर्नुहोस्।';

  @override
  String get requestLoanButton => 'ऋण माग्नुहोस्';

  @override
  String get makeRepaymentButton => 'भुक्तानी गर्नुहोस्';

  @override
  String get yourApplicationsTitle => 'तपाईंका आवेदन';

  @override
  String get noLoanRequestsYet => 'अहिलेसम्म ऋण आवेदन छैन';

  @override
  String get noLoanRequestsMessage =>
      'तपाईंका आवेदन र सम्झौताहरू यहाँ देखिनेछन्।';

  @override
  String tenorMonthsText(Object count) {
    return '$count महिना';
  }

  @override
  String get loanStatusDraft => 'मस्यौदा';

  @override
  String get loanStatusPendingReview => 'समीक्षाधीन';

  @override
  String get loanStatusOpenForFunding => 'कोषका लागि खुला';

  @override
  String get loanStatusFunded => 'कोष जम्मा';

  @override
  String get loanStatusActive => 'सक्रिय';

  @override
  String get loanStatusRepaid => 'चुक्ता';

  @override
  String get loanStatusRejected => 'अस्वीकृत';

  @override
  String get loanStatusExpired => 'म्याद सकियो';

  @override
  String get loanStatusCancelled => 'रद्द';

  @override
  String get loanStatusOverdue => 'म्याद नाघ्यो';

  @override
  String get loanStatusDefaulted => 'डिफल्ट';

  @override
  String get riskMarkerPositive => '+';

  @override
  String get riskMarkerNeutral => '•';

  @override
  String get riskMarkerNegative => '−';

  @override
  String get riskDirectionPositiveLabel => 'सकारात्मक कारक';

  @override
  String get riskDirectionNeutralLabel => 'तटस्थ कारक';

  @override
  String get riskDirectionNegativeLabel => 'नकारात्मक कारक';

  @override
  String loanAmountOutOfRangeError(Object maxAmount, Object minAmount) {
    return '$minAmount र $maxAmount बीचको रकम राख्नुहोस्।';
  }

  @override
  String get invalidTenorRangeError => '३ देखि ६० महिनासम्म अवधि छान्नुहोस्।';

  @override
  String get enterMonthlyIncomeError => 'आफ्नो मासिक आय राख्नुहोस्।';

  @override
  String get requestLoanTitle => 'ऋण माग्नुहोस्';

  @override
  String get requestLoanIntro =>
      'लगानीकर्तालाई के चाहिन्छ भन्नुहोस्। हामी दर, ठ्याक्कै किस्ता र ग्रेडका कारण देखाउँछौं।';

  @override
  String get purposeLabel => 'उद्देश्य';

  @override
  String get purposeHint => 'जस्तै: व्यापारिक स्टक';

  @override
  String get describePurposeError => 'उद्देश्य लेख्नुहोस्।';

  @override
  String get loanAmountLabel => 'ऋण रकम';

  @override
  String get loanAmountHint => '२,००,०००';

  @override
  String get nprPrefix => 'रू ';

  @override
  String get enterAmountError => 'रकम राख्नुहोस्।';

  @override
  String get tenorLabel => 'अवधि (महिना)';

  @override
  String get tenorHint => '१२';

  @override
  String get enterWholeMonthsError => 'पूरा महिना राख्नुहोस्।';

  @override
  String get monthlyIncomeLabel => 'मासिक आय';

  @override
  String get monthlyIncomeHint => '५०,०००';

  @override
  String get seeMyRiskGradeButton => 'मेरो जोखिम ग्रेड हेर्नुहोस्';

  @override
  String get requestLoanDemoNote =>
      'डेमो मोड: कुनै क्रेडिट ब्युरो कल हुँदैन र वास्तविक पैसा सर्दैन।';

  @override
  String get riskReviewTitle => 'तपाईंको जोखिम समीक्षा';

  @override
  String loanTermsSummary(Object months, Object rate) {
    return '$months महिना · वार्षिक $rate';
  }

  @override
  String riskScoreText(Object score) {
    return 'अंक $score/१००';
  }

  @override
  String get whyThisGradeTitle => 'यो ग्रेड किन';

  @override
  String riskModelExplanation(Object modelVersion) {
    return 'मोडेल $modelVersion · किफायतीपन, रकम, अवधि, प्रमाणिकरण र इतिहास।';
  }

  @override
  String get manualReviewNotice =>
      'यो आवेदन म्यानुअल समीक्षाका लागि चिन्ह लगाइएको छ। स्वीकृत गर्न डेमो नियन्त्रण प्रयोग गर्नुहोस्।';

  @override
  String get demoApproveRequestButton => 'डेमो आवेदन स्वीकृत';

  @override
  String get continueToAgreementButton => 'सम्झौतामा जारी राख्नुहोस्';

  @override
  String get repaymentPreviewTitle => 'भुक्तानी पूर्वावलोकन';

  @override
  String get monthlyInstalmentLabel => 'मासिक किस्ता';

  @override
  String get totalRepayableLabel => 'कुल तिर्ने रकम';

  @override
  String get interestLabel => 'ब्याज';

  @override
  String get platformFeeLabel => 'प्लेटफर्म शुल्क (ब्याजको १०%)';

  @override
  String get typeFullNameToSignError => 'हस्ताक्षर गर्न पूरा नाम लेख्नुहोस्।';

  @override
  String get acceptTermsBeforeSigningError =>
      'हस्ताक्षर गर्नुअघि सर्त स्वीकार गर्नुहोस्।';

  @override
  String get loanAgreementTitle => 'ऋण सम्झौता';

  @override
  String termsVersionText(Object version) {
    return 'सर्त संस्करण $version';
  }

  @override
  String termsHashText(Object hash) {
    return 'सर्त ह्यास: $hash';
  }

  @override
  String get signedFundsDisbursedChip => 'हस्ताक्षर भयो · रकम जारी';

  @override
  String signedByOnText(Object signedAt, Object signedBy) {
    return '$signedBy ले $signedAt मा हस्ताक्षर गरे';
  }

  @override
  String get viewDisbursementReceiptButton => 'भुक्तानी रसिद हेर्नुहोस्';

  @override
  String get typeFullNameToSignLabel => 'हस्ताक्षर गर्न पूरा नाम लेख्नुहोस्';

  @override
  String get legalNameHint => 'तपाईंको कानुनी नाम';

  @override
  String get acceptTermsCheckboxLabel =>
      'म यी सर्त र भुक्तानी तालिका स्वीकार गर्छु।';

  @override
  String get signAndReceiveFundsButton => 'हस्ताक्षर गरी रकम प्राप्त गर्नुहोस्';

  @override
  String get approveBeforeSigningNotice =>
      'हस्ताक्षर गर्नुअघि जोखिम समीक्षा स्क्रिनमा आवेदन स्वीकृत गर्नुहोस्।';

  @override
  String get demoEscrowNote =>
      'डेमो एस्क्रो नक्कली हो: लगानीकर्ताको कोष जम्मा भएपछि हस्ताक्षरले एस्क्रो → वallet जर्नल रेकर्ड गर्छ।';

  @override
  String repaymentScheduleWithCount(Object count) {
    return 'भुक्तानी तालिका ($count किस्ता)';
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
  String get stakeStatusActive => 'सक्रिय';

  @override
  String get stakeStatusReturned => 'म्याद सकिएपछि फिर्ता';

  @override
  String get verifiedBorrowerFallback => 'प्रमाणित ऋणी';

  @override
  String get lenderHomeTitle => 'लगानीकर्ता गृह';

  @override
  String get lenderHomeIntro => 'तपाईंको लगानी एक नजरमा';

  @override
  String get walletBalanceLabel => 'वallet ब्यालेन्स';

  @override
  String get activeStakesLabel => 'सक्रिय लगानी';

  @override
  String activeStakesCount(Object count) {
    return '$count';
  }

  @override
  String get amountCommittedLabel => 'प्रतिबद्ध रकम';

  @override
  String get browseVerifiedLoansButton => 'प्रमाणित ऋण हेर्नुहोस्';

  @override
  String get viewMyPortfolioButton => 'मेरो पोर्टफोलियो हेर्नुहोस्';

  @override
  String get addMoneyToWalletButton => 'वallet मा पैसा राख्नुहोस्';

  @override
  String openLoansSummary(Object count) {
    return 'कोषका लागि $count ऋण खुला छन्।';
  }

  @override
  String openLoansSummarySingular(Object count) {
    return 'कोषका लागि $count ऋण खुला छ।';
  }

  @override
  String get browseLoansTitle => 'ऋण हेर्नुहोस्';

  @override
  String get fundVerifiedBorrower => 'प्रमाणित ऋणीमा लगानी गर्नुहोस्';

  @override
  String get riskBandLabel => 'जोखिम समूह';

  @override
  String get riskBandAll => 'सबै समूह';

  @override
  String get riskBandLow => 'कम';

  @override
  String get riskBandMedium => 'मध्यम';

  @override
  String get riskBandHigh => 'उच्च';

  @override
  String get minAmountLabel => 'न्यूनतम रकम';

  @override
  String get minAmountHint => '१००००';

  @override
  String get maxAmountLabel => 'अधिकतम रकम';

  @override
  String get maxAmountHint => '२०००००';

  @override
  String get maxTenorLabel => 'अधिकतम अवधि (महिना)';

  @override
  String get maxTenorHint => '१२';

  @override
  String get sortLabel => 'क्रमबद्ध';

  @override
  String get sortNewest => 'नयाँ first';

  @override
  String get sortAmountAscending => 'रकम ↑';

  @override
  String get sortAmountDescending => 'रकम ↓';

  @override
  String get sortLowestRisk => 'कम जोखिम first';

  @override
  String get applyFiltersButton => 'फिल्टर लागू गर्नुहोस्';

  @override
  String get openLoansTitle => 'खुला ऋण';

  @override
  String openLoansCount(Object count) {
    return '$count';
  }

  @override
  String get noLoansMatch => 'कुनै ऋण मेल खाँदैन';

  @override
  String get noLoansMatchMessage => 'रकम वा अवधि फिल्टर फराकिलो गर्नुहोस्।';

  @override
  String tenorMonthsShort(Object count) {
    return '$count महिना';
  }

  @override
  String get portfolioTitle => 'पोर्टफोलियो';

  @override
  String get yourStakesTitle => 'तपाईंको लगानी';

  @override
  String activePrincipalText(Object amount) {
    return 'सक्रिय प्रिन्सिपल: $amount';
  }

  @override
  String get noStakesYet => 'अहिलेसम्म लगानी छैन';

  @override
  String get noStakesMessage =>
      'सुरु गर्न प्रमाणित ऋण हेरी कुनैमा लगानी गर्नुहोस्।';

  @override
  String stakeInLoanText(Object loanId) {
    return 'ऋण $loanId मा लगानी';
  }

  @override
  String get loanDetailsTitle => 'ऋण विवरण';

  @override
  String needsMoreByDate(Object amount, Object date) {
    return '$date सम्म $amount आवश्यक छ।';
  }

  @override
  String get identityVerifiedNote => 'पहिचान प्रमाणित · KYC पूरा';

  @override
  String get riskFactorsTitle => 'जोखिम कारक';

  @override
  String riskFactorLine(Object name, Object note) {
    return '$name: $note';
  }

  @override
  String modelScoreSummary(Object modelVersion, Object score) {
    return 'मोडेल $modelVersion · अंक $score/१००।';
  }

  @override
  String get fundThisLoanButton => 'यो ऋणमा लगानी गर्नुहोस्';

  @override
  String get loanNotOpenForFunding => 'यो ऋण अब कोषका लागि खुला छैन।';

  @override
  String get dateToBeConfirmed => 'मिति पछि घोषणा हुनेछ';

  @override
  String get fundLoanTitle => 'ऋणमा लगानी';

  @override
  String stillNeededOfTotalText(Object remaining, Object total) {
    return '$total मध्ये $remaining अझै आवश्यक छ।';
  }

  @override
  String get amountToStakeLabel => 'लगानी रकम';

  @override
  String get amountToStakeHint => '१०००';

  @override
  String get walletBeforeLabel => 'अघिको वallet';

  @override
  String get interestShareLabel => 'तपाईंको ब्याज हिस्सा';

  @override
  String get walletAfterLabel => 'पछिको वallet';

  @override
  String get confirmFundingButton => 'कोष जम्मा पुष्टि गर्नुहोस्';

  @override
  String get demoFundingNote =>
      'डेमो कोषले तपाईंको नक्कली वallet डेबिट गरी ऋण एस्क्रोमा जम्मा गर्छ। वास्तविक पैसा सर्दैन।';

  @override
  String minimumStakeError(Object amount) {
    return 'न्यूनतम लगानी $amount हो।';
  }

  @override
  String onlyStillNeededError(Object amount) {
    return 'अब $amount मात्र आवश्यक छ।';
  }

  @override
  String get topUpWalletFirstError => 'पहिले आफ्नो वallet मा पैसा राख्नुहोस्।';

  @override
  String get stakeDetailsTitle => 'लगानी विवरण';

  @override
  String get yourStakeTitle => 'तपाईंको लगानी';

  @override
  String stakeLoanLine(Object purpose) {
    return 'ऋण: $purpose';
  }

  @override
  String stakeBorrowerLine(Object borrowerName) {
    return 'ऋणी: $borrowerName';
  }

  @override
  String fundedOnDateText(Object date) {
    return '$date मा जम्मा';
  }

  @override
  String get ledgerTrailTitle => 'लेजर ट्रेल';

  @override
  String get viewFundingReceiptButton => 'कोष रसिद हेर्नुहोस्';

  @override
  String get viewExpiryReversalButton => 'म्याद उल्टाउने रसिद हेर्नुहोस्';

  @override
  String get stakeReturnedNote =>
      'पूर्ण कोष जम्मा हुनुअघि ऋणको म्याद सकियो। एस्क्रो फिर्ता भई यो लगानी तपाईंको वallet मा फर्कियो।';

  @override
  String get unknownDateText => 'अज्ञात मितिमा';

  @override
  String get confirmRepaymentTitle => 'भुक्तानी पुष्टि गर्नुहोस्';

  @override
  String repaymentSheetDetail(
    Object fee,
    Object instalmentNumber,
    Object provider,
  ) {
    return 'नक्कली $provider भुक्तानीले किस्ता $instalmentNumber तिर्छ। प्लेटफर्म शुल्क $fee हो।';
  }

  @override
  String get payInstalmentButton => 'किस्ता तिर्नुहोस्';

  @override
  String get makeRepaymentTitle => 'भुक्तानी गर्नुहोस्';

  @override
  String get payOneAtATimeTitle => 'एक पटकमा एक किस्ता तिर्नुहोस्';

  @override
  String get repaymentSplitNote =>
      'प्रिन्सिपल र ब्याज सबै लगानीकर्ताको हिस्सामा स्वतः बाँडिन्छ। ब्याजबाट १०% प्लेटफर्म शुल्क लिइन्छ।';

  @override
  String get nothingToRepayYet => 'अहिले तिर्न केही छैन';

  @override
  String get nothingToRepayMessage =>
      'ऋण कोष जम्मा भई हस्ताक्षर भएपछि किस्ताहरू यहाँ देखिनेछन्।';

  @override
  String instalmentProgressText(Object number, Object total) {
    return 'किस्ता $number / $total';
  }

  @override
  String dueDateText(Object date) {
    return 'म्याद $date';
  }

  @override
  String get amountToPayLabel => 'तिर्ने रकम';

  @override
  String get principalLabel => 'प्रिन्सिपल';

  @override
  String get lendersReceiveLabel => 'लगानीकर्ताले पाउने';

  @override
  String get paymentMethodLabel => 'भुक्तानी विधि';

  @override
  String get paymentProviderEsewaLabel => 'eSewa (नक्कली)';

  @override
  String get paymentProviderKhaltiLabel => 'Khalti (नक्कली)';

  @override
  String payAmountButton(Object amount) {
    return '$amount तिर्नुहोस्';
  }

  @override
  String get instalmentPaidChip => 'भुक्तानी भयो';

  @override
  String get instalmentDueChip => 'म्याद';

  @override
  String get repaymentStatusProcessing => 'प्रक्रियाधीन';

  @override
  String get repaymentStatusLate => 'ढिलो';

  @override
  String get repaymentStatusNextUp => 'अर्को';

  @override
  String get providerLabelKhalti => 'Khalti';

  @override
  String get providerLabelEsewa => 'eSewa';

  @override
  String get repaymentScheduleTitle => 'भुक्तानी तालिका';

  @override
  String get notificationsTooltip => 'सूचनाहरू';

  @override
  String unreadCountBadge(Object count) {
    return '$count';
  }

  @override
  String get notificationsTitle => 'सूचनाहरू';

  @override
  String get markAllReadButton => 'सबै पढिएको गर्नुहोस्';

  @override
  String get allCaughtUpText => 'तपाईं सबै अपडेट हुनुहुन्छ';

  @override
  String unreadCountText(Object count) {
    return '$count नपढिएको';
  }

  @override
  String get noNotificationsYet => 'अहिलेसम्म सूचना छैन';

  @override
  String get noNotificationsMessage =>
      'कोष, भुक्तानी र भुक्तानी रिमाइन्डर यहाँ देखिनेछन्।';

  @override
  String get notificationNewChip => 'नयाँ';

  @override
  String demoClockLabel(Object date) {
    return 'डेमो घडी: $date';
  }

  @override
  String get clockAdvanceOneDay => '+१ दिन';

  @override
  String get clockAdvanceSevenDays => '+७ दिन';

  @override
  String get clockAdvanceOneMonth => '+१ महिना';

  @override
  String get clockResetButton => 'रिसेट';

  @override
  String get demoRemindersButton => 'रिमाइन्डर';

  @override
  String paymentRemindersSentSnackbar(Object count) {
    return 'भुक्तानी रिमाइन्डर पठाइयो: $count';
  }

  @override
  String get demoMarkOverdueButton => 'म्याद नाघ्यो भन्नुहोस्';

  @override
  String loansMarkedOverdueSnackbar(Object count) {
    return 'म्याद नाघेका ऋण: $count';
  }

  @override
  String get demoReconcileButton => 'मिलान गर्नुहोस्';

  @override
  String ledgerCleanSnackbar(Object count) {
    return 'लेजर सफा छ ($count जर्नल)';
  }

  @override
  String ledgerIssuesSnackbar(Object negativeCount, Object unbalancedCount) {
    return 'लेजर समस्या: $unbalancedCount असन्तुलित, $negativeCount नकारात्मक';
  }

  @override
  String get demoStateTitle => 'स्क्रिन अवस्था';

  @override
  String get demoStateNormal => 'सामान्य';

  @override
  String get demoStateLoading => 'लोड हुँदै';

  @override
  String get demoStateEmpty => 'खाली';

  @override
  String get demoStateError => 'त्रुटि';

  @override
  String get demoStateOffline => 'अफलाइन';

  @override
  String get walletTitle => 'वallet';

  @override
  String get availableBalanceLabel => 'उपलब्ध ब्यालेन्स';

  @override
  String get topUpButton => 'पैसा राख्नुहोस्';

  @override
  String get withdrawButton => 'निकाल्नुहोस्';

  @override
  String get recentActivityTitle => 'हालको गतिविधि';

  @override
  String get noWalletActivityYet => 'अहिलेसम्म वallet गतिविधि छैन';

  @override
  String get noWalletActivityMessage =>
      'लगानी सुरु गर्न वallet मा पैसा राख्नुहोस्।';

  @override
  String get minimumAmountError => 'न्यूनतम रकम रू १,००० हो।';

  @override
  String get amountExceedsBalanceError =>
      'रकम तपाईंको वallet ब्यालेन्सभन्दा बढी छ।';

  @override
  String get confirmTopUpSheetTitle => 'पैसा राख्ने पुष्टि';

  @override
  String get confirmWithdrawalSheetTitle => 'निकासी पुष्टि';

  @override
  String get topUpSheetDetail =>
      'नक्कली भुक्तानीले यो रकम तपाईंको वallet मा राख्छ।';

  @override
  String get withdrawalSheetDetail =>
      'यो रकम तपाईंको वallet बाट बैंकमा पठाइन्छ।';

  @override
  String get confirmTopUpButton => 'पैसा राख्ने पुष्टि';

  @override
  String get confirmWithdrawalButton => 'निकासी पुष्टि';

  @override
  String get topUpWalletTitle => 'वallet मा पैसा राख्नुहोस्';

  @override
  String get withdrawToBankTitle => 'बैंकमा निकाल्नुहोस्';

  @override
  String get topUpIntro => 'ऋणमा लगानी गर्न वallet मा पैसा राख्नुहोस्।';

  @override
  String get withdrawalIntro => 'वallet बाट बैंक खातामा पैसा सार्नुहोस्।';

  @override
  String get amountToAddLabel => 'राख्ने रकम';

  @override
  String get amountToWithdrawLabel => 'निकाल्ने रकम';

  @override
  String get walletAmountHint => '१०,०००';

  @override
  String get reviewTopUpButton => 'पैसा राख्ने समीक्षा';

  @override
  String get reviewWithdrawalButton => 'निकासी समीक्षा';

  @override
  String get demoPaymentGatewayNote =>
      'डेमो मोडमा नक्कली भुक्तानी गेटवे प्रयोग हुन्छ। वास्तविक पैसा सर्दैन।';

  @override
  String get transactionReceiptTitle => 'कारोबार रसिद';

  @override
  String get moneyMoveRecordedText => 'पैसा कारोबार रेकर्ड भयो';

  @override
  String get referenceLabel => 'सन्दर्भ';

  @override
  String journalIdLine(Object journalId) {
    return 'जर्नल: $journalId';
  }

  @override
  String journalTypeLine(Object journalType) {
    return 'प्रकार: $journalType';
  }

  @override
  String journalCreatedLine(Object date) {
    return 'मिति: $date';
  }

  @override
  String get replayedRequestChip => 'पुनः पठाइएको अनुरोध';

  @override
  String get ledgerEntriesTitle => 'लेजर प्रविष्टिहरू';

  @override
  String get styleGuideTitle => 'स्टाइल गाइड';

  @override
  String get styleGuideColoursSection => 'रङहरू';

  @override
  String get swatchPrimaryLabel => 'प्राथमिक';

  @override
  String get swatchSuccessLabel => 'सफलता';

  @override
  String get swatchWarningLabel => 'चेतावनी';

  @override
  String get swatchErrorLabel => 'त्रुटि';

  @override
  String get swatchRiskLowLabel => 'कम जोखिम';

  @override
  String get swatchRiskMediumLabel => 'मध्यम जोखिम';

  @override
  String get swatchRiskHighLabel => 'उच्च जोखिम';

  @override
  String get styleGuideTypographySection => 'टाइपोग्राफी';

  @override
  String get typographyDisplayTitle => 'डिस्प्ले शीर्षक';

  @override
  String get typographyTitleSample => 'शीर्षक';

  @override
  String get typographyBodySample => 'मुख्य पाठ';

  @override
  String get typographyCaptionSample => 'क्याप्शन पाठ';

  @override
  String get styleGuideButtonsSection => 'बटनहरू';

  @override
  String get styleGuidePrimaryAction => 'प्राथमिक कार्य';

  @override
  String get styleGuideSecondaryAction => 'द्वितीय कार्य';

  @override
  String get styleGuideDisabledButton => 'असक्रिय';

  @override
  String get styleGuideInputsSection => 'इनपुटहरू';

  @override
  String get styleGuideAmountHint => '१,००,०००';

  @override
  String get styleGuideCardsSection => 'कार्ड र रकम';

  @override
  String get styleGuideDemoGrade => 'B';

  @override
  String get styleGuideProgressSection => 'प्रगति र स्थिति';

  @override
  String get statusVerified => 'प्रमाणित';

  @override
  String get statusInReview => 'समीक्षाधीन';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusOpen => 'खुला';

  @override
  String get styleGuideStatesSection => 'अवस्थाहरू';

  @override
  String get styleGuideNoLoansYet => 'अहिले ऋण छैन';

  @override
  String get styleGuideNoLoansMessage => 'नयाँ आवेदन यहाँ देखिनेछन्।';

  @override
  String get styleGuideErrorStateMessage => 'ऋण लोड गर्न सकिएन।';

  @override
  String get styleGuideBottomSheetSection => 'तलको पाना';

  @override
  String get openConfirmationSheetButton => 'पुष्टि पाना खोल्नुहोस्';

  @override
  String get confirmFundingSheetTitle => 'कोष पुष्टि';

  @override
  String get confirmAndFundButton => 'पुष्टि गरी कोष जम्मा';

  @override
  String get expectedInterestDemoText => 'अपेक्षित ब्याज: रू ४१०.००';
}
