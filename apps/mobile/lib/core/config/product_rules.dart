/// Product rules agreed in `docs/decisions.md` (blueprint §8.2, §13).
///
/// Money is always integer paisa. Rates are basis points (14% = 1400 bps).
/// Change these values in one place only.
class ProductRules {
  const ProductRules._();

  static const int paisaPerNpr = 100;
  static const int minLoanPaisa = 1000000; // NPR 10,000
  static const int maxLoanPaisa = 50000000; // NPR 5,00,000
  static const int minStakePaisa = 100000; // NPR 1,000
  static const int fundingWindowDays = 14;
  static const int graceDaysBeforeOverdue = 0;

  static const int rateA = 1200; // 12% p.a.
  static const int rateB = 1400; // 14% p.a.
  static const int rateC = 1700; // 17% p.a.
  static const int rateD = 2000; // 20% p.a.

  static const int scoreA = 80;
  static const int scoreB = 65;
  static const int scoreC = 50;
  static const int scoreD = 35;

  /// Platform fee is 10% of the interest portion of an instalment.
  static const int feeBpsOfInterest = 1000;

  static int rateBpsForGrade(String grade) => switch (grade) {
        'A' => rateA,
        'B' => rateB,
        'C' => rateC,
        'D' => rateD,
        _ => rateD,
      };

  static String bandForGrade(String grade) => switch (grade) {
        'A' => 'low',
        'B' => 'medium',
        'C' => 'medium',
        'D' => 'high',
        _ => 'high',
      };
}
