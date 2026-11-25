import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';

/// Application data used by the rule-based risk engine. All amounts are
/// integer paisa so scoring never depends on floating point rounding.
class LoanRiskInput {
  const LoanRiskInput({
    required this.amountPaisa,
    required this.tenorMonths,
    required this.monthlyIncomePaisa,
    this.kycVerified = true,
    this.historyScore = 14,
  });

  final int amountPaisa;
  final int tenorMonths;
  final int monthlyIncomePaisa;
  final bool kycVerified;
  final int historyScore;

  LoanRiskInput copyWith({
    int? amountPaisa,
    int? tenorMonths,
    int? monthlyIncomePaisa,
    bool? kycVerified,
    int? historyScore,
  }) =>
      LoanRiskInput(
        amountPaisa: amountPaisa ?? this.amountPaisa,
        tenorMonths: tenorMonths ?? this.tenorMonths,
        monthlyIncomePaisa:
            monthlyIncomePaisa ?? this.monthlyIncomePaisa,
        kycVerified: kycVerified ?? this.kycVerified,
        historyScore: historyScore ?? this.historyScore,
      );
}

/// Version 1 of the explainable risk model. The score is out of 100:
/// affordability 30, amount vs income 20, tenor 10, KYC 20, history 20.
class RiskService {
  const RiskService._();

  static const String modelVersion = 'v1';

  static String gradeFor(int score) => score >= ProductRules.scoreA
      ? 'A'
      : score >= ProductRules.scoreB
          ? 'B'
          : score >= ProductRules.scoreC
              ? 'C'
              : score >= ProductRules.scoreD
                  ? 'D'
                  : 'reject';

  static RiskBand bandFor(String grade) => switch (ProductRules.bandForGrade(grade)) {
        'low' => RiskBand.low,
        'medium' => RiskBand.medium,
        _ => RiskBand.high,
      };

  static RiskAssessment assess(LoanRiskInput input) {
    final factors = <RiskFactor>[];
    var score = 0;

    // Amount vs 12x monthly income (20 points).
    if (input.monthlyIncomePaisa <= 0) {
      factors.add(
        const RiskFactor(
          name: 'Income',
          direction: RiskDirection.negative,
          note: 'Monthly income is needed to assess this request.',
        ),
      );
    } else {
      if (input.amountPaisa <= input.monthlyIncomePaisa * 6) {
        score += 20;
        factors.add(
          RiskFactor(
            name: 'Amount vs income',
            direction: RiskDirection.positive,
            note: 'The request is under 6× your monthly income.',
          ),
        );
      } else if (input.amountPaisa <= input.monthlyIncomePaisa * 12) {
        score += 12;
        factors.add(
          RiskFactor(
            name: 'Amount vs income',
            direction: RiskDirection.neutral,
            note: 'The request is between 6× and 12× your monthly income.',
          ),
        );
      } else {
        score += 4;
        factors.add(
          RiskFactor(
            name: 'Amount vs income',
            direction: RiskDirection.negative,
            note: 'The request is more than 12× your monthly income.',
          ),
        );
      }
    }

    // Tenor (10 points).
    if (input.tenorMonths <= 12) {
      score += 10;
      factors.add(
        const RiskFactor(
          name: 'Tenor',
          direction: RiskDirection.positive,
          note: 'A tenor of 12 months or less keeps exposure short.',
        ),
      );
    } else if (input.tenorMonths <= 24) {
      score += 6;
      factors.add(
        const RiskFactor(
          name: 'Tenor',
          direction: RiskDirection.neutral,
          note: 'A tenor of 13–24 months is allowed with a higher rate.',
        ),
      );
    } else {
      score += 2;
      factors.add(
        const RiskFactor(
          name: 'Tenor',
          direction: RiskDirection.negative,
          note: 'Tenors over 24 months need manual review.',
        ),
      );
    }

    // KYC strength (20 points). The router and provider gates already block
    // unverified users; this factor keeps the reason visible in the grade.
    if (input.kycVerified) {
      score += 20;
      factors.add(
        const RiskFactor(
          name: 'Verification',
          direction: RiskDirection.positive,
          note: 'All four verification steps are approved.',
        ),
      );
    } else {
      factors.add(
        const RiskFactor(
          name: 'Verification',
          direction: RiskDirection.negative,
          note: 'Verification is incomplete.',
        ),
      );
    }

    // Repayment history (20 points). No history is neutral, not a penalty.
    final history = Money.clamp(input.historyScore, 0, 20);
    score += history;
    factors.add(
      RiskFactor(
        name: 'History',
        direction: history >= 20
            ? RiskDirection.positive
            : history >= 10
                ? RiskDirection.neutral
                : RiskDirection.negative,
        note: history >= 20
            ? 'Previous loans were repaid on time.'
            : history >= 10
                ? 'No adverse repayment history on record.'
                : 'A previous repayment problem lowers this score.',
      ),
    );

    // Affordability needs an EMI, which depends on the grade's rate. Use the
    // neutral provisional grade to break the circle, then score affordability
    // and recompute the final rate from the completed score.
    final provisionalGrade = gradeFor(score + 18);
    final provisionalRate =
        ProductRules.rateBpsForGrade(provisionalGrade);
    final provisionalEmi = Money.installmentPaisa(
      principalPaisa: input.amountPaisa,
      rateBps: provisionalRate,
      tenorMonths: input.tenorMonths,
    );
    final affordability = _affordability(
      input: input,
      emiPaisa: provisionalEmi,
    );
    score += affordability.points;
    factors.insert(0, affordability.factor);

    final grade = gradeFor(score);
    final rateBps = ProductRules.rateBpsForGrade(grade);
    final emiPaisa = Money.installmentPaisa(
      principalPaisa: input.amountPaisa,
      rateBps: rateBps,
      tenorMonths: input.tenorMonths,
    );
    // Keep the displayed EMI consistent with the final grade, without adding
    // a second factor that would double-count affordability.
    factors[0] = affordability.factor.copyWith(
      note: affordability.note(emiPaisa),
    );

    final highAmount = input.monthlyIncomePaisa > 0 &&
        (input.amountPaisa >= ProductRules.maxLoanPaisa ||
            input.amountPaisa > input.monthlyIncomePaisa * 12);

    return RiskAssessment(
      score: Money.clamp(score, 0, 100),
      grade: grade,
      band: bandFor(grade),
      rateBps: rateBps,
      factors: List<RiskFactor>.unmodifiable(factors),
      modelVersion: modelVersion,
      requiresReview: grade == 'D' || grade == 'reject' || highAmount,
    );
  }

  static _Affordability _affordability({
    required LoanRiskInput input,
    required int emiPaisa,
  }) {
    if (input.monthlyIncomePaisa <= 0) {
      return _Affordability(
        points: 0,
        percent: 0,
        factor: const RiskFactor(
          name: 'Affordability',
          direction: RiskDirection.negative,
          note: 'Monthly income is needed to assess affordability.',
        ),
      );
    }

    final percent = Money.roundDiv(
      emiPaisa * 100,
      input.monthlyIncomePaisa,
    );
    if (emiPaisa * 100 <= input.monthlyIncomePaisa * 25) {
      return _Affordability(
        points: 30,
        percent: percent,
        factor: RiskFactor(
          name: 'Affordability',
          direction: RiskDirection.positive,
          note: 'EMI ${formatNPRCompact(emiPaisa)} is $percent% of income.',
        ),
      );
    }
    if (emiPaisa * 100 <= input.monthlyIncomePaisa * 40) {
      return _Affordability(
        points: 18,
        percent: percent,
        factor: RiskFactor(
          name: 'Affordability',
          direction: RiskDirection.neutral,
          note: 'EMI ${formatNPRCompact(emiPaisa)} is $percent% of income.',
        ),
      );
    }
    return _Affordability(
      points: 6,
      percent: percent,
      factor: RiskFactor(
        name: 'Affordability',
        direction: RiskDirection.negative,
        note: 'EMI ${formatNPRCompact(emiPaisa)} is $percent% of income.',
      ),
    );
  }
}

class _Affordability {
  const _Affordability({
    required this.points,
    required this.percent,
    required this.factor,
  });

  final int points;
  final int percent;
  final RiskFactor factor;

  String note(int finalEmiPaisa) =>
      'EMI ${formatNPRCompact(finalEmiPaisa)} is $percent% of income.';
}
