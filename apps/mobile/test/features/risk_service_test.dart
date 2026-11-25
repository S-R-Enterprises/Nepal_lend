import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/loans/data/risk_service.dart';

RiskFactor? factor(RiskAssessment assessment, String name) {
  for (final item in assessment.factors) {
    if (item.name == name) return item;
  }
  return null;
}

RiskAssessment assessWith({
  required int amount,
  required int tenor,
  required int income,
  bool verified = true,
  int history = 14,
}) =>
    RiskService.assess(
      LoanRiskInput(
        amountPaisa: amount,
        tenorMonths: tenor,
        monthlyIncomePaisa: income,
        kycVerified: verified,
        historyScore: history,
      ),
    );

void main() {
  test('grade boundaries are deterministic', () {
    expect(RiskService.gradeFor(80), 'A');
    expect(RiskService.gradeFor(79), 'B');
    expect(RiskService.gradeFor(65), 'B');
    expect(RiskService.gradeFor(64), 'C');
    expect(RiskService.gradeFor(50), 'C');
    expect(RiskService.gradeFor(49), 'D');
    expect(RiskService.gradeFor(35), 'D');
    expect(RiskService.gradeFor(34), 'reject');
    expect(ProductRules.rateBpsForGrade('A'), 1200);
    expect(ProductRules.rateBpsForGrade('D'), 2000);
  });

  test('affordability uses integer thresholds around 25% and 40%', () {
    const amount = 10000000; // NPR 1,00,000
    const tenor = 12;
    final emi = Money.installmentPaisa(
      principalPaisa: amount,
      rateBps: ProductRules.rateA,
      tenorMonths: tenor,
    );

    final good = assessWith(amount: amount, tenor: tenor, income: emi * 4);
    final neutral = assessWith(amount: amount, tenor: tenor, income: emi * 3);
    final bad = assessWith(amount: amount, tenor: tenor, income: emi * 2);

    expect(factor(good, 'Affordability')?.direction, RiskDirection.positive);
    expect(factor(neutral, 'Affordability')?.direction, RiskDirection.neutral);
    expect(factor(bad, 'Affordability')?.direction, RiskDirection.negative);
    expect(good.score, greaterThan(neutral.score));
    expect(neutral.score, greaterThan(bad.score));
  });

  test('amount-vs-income and tenor boundaries produce plain factors', () {
    const income = 1000000; // NPR 10,000
    final sixTimes = assessWith(
      amount: income * 6,
      tenor: 12,
      income: income,
    );
    final twelveTimes = assessWith(
      amount: income * 12,
      tenor: 24,
      income: income,
    );
    final overTwelve = assessWith(
      amount: income * 12 + 1,
      tenor: 25,
      income: income,
    );

    expect(
      factor(sixTimes, 'Amount vs income')?.direction,
      RiskDirection.positive,
    );
    expect(
      factor(twelveTimes, 'Amount vs income')?.direction,
      RiskDirection.neutral,
    );
    expect(
      factor(overTwelve, 'Amount vs income')?.direction,
      RiskDirection.negative,
    );
    expect(factor(sixTimes, 'Tenor')?.direction, RiskDirection.positive);
    expect(factor(twelveTimes, 'Tenor')?.direction, RiskDirection.neutral);
    expect(factor(overTwelve, 'Tenor')?.direction, RiskDirection.negative);
    expect(sixTimes.factors, hasLength(5));
    expect(
      sixTimes.factors.every((item) => item.note.trim().isNotEmpty),
      isTrue,
    );
  });

  test('grade D, rejected and high-value requests need review', () {
    final poor = assessWith(
      amount: 50000000,
      tenor: 60,
      income: 100000,
      history: 0,
    );
    expect(poor.grade, anyOf('D', 'reject'));
    expect(poor.requiresReview, isTrue);

    final highValue = assessWith(
      amount: 50000000,
      tenor: 12,
      income: 5000000,
      history: 20,
    );
    expect(highValue.requiresReview, isTrue);

    final normal = assessWith(
      amount: 20000000,
      tenor: 12,
      income: 5000000,
    );
    expect(normal.grade, 'A');
    expect(normal.requiresReview, isFalse);
    expect(normal.modelVersion, 'v1');
    expect(normal.rateBps, ProductRules.rateA);
  });

  test('unverified user and missing income get negative factors', () {
    final unverified = assessWith(
      amount: 20000000,
      tenor: 12,
      income: 5000000,
      verified: false,
    );
    expect(
      factor(unverified, 'Verification')?.direction,
      RiskDirection.negative,
    );

    final noIncome = assessWith(amount: 20000000, tenor: 12, income: 0);
    expect(factor(noIncome, 'Income')?.direction, RiskDirection.negative);
    expect(
      factor(noIncome, 'Affordability')?.direction,
      RiskDirection.negative,
    );
  });
}
