enum UserRole { borrower, lender }

class Session {
  Session._();

  static UserRole role = UserRole.borrower;
}

class Routes {
  Routes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String registration = '/registration';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String kyc = '/kyc';

  static const String lenderHome = '/lender/home';
  static const String browseLoans = '/lender/browse';
  static const String loanDetails = '/lender/loan-details';
  static const String fundLoan = '/lender/fund-loan';
  static const String fundingSuccess = '/lender/funding-success';
  static const String portfolio = '/lender/portfolio';
  static const String loanStake = '/lender/loan-stake';
  static const String wallet = '/lender/wallet';
  static const String transaction = '/lender/transaction';

  static const String borrowerHome = '/borrower/home';
  static const String requestLoan = '/borrower/request-loan';
  static const String riskReview = '/borrower/risk-review';
  static const String loanAgreement = '/borrower/loan-agreement';
  static const String repay = '/borrower/repay';

  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String help = '/help';

  static String get home =>
      Session.role == UserRole.lender ? lenderHome : borrowerHome;
}
