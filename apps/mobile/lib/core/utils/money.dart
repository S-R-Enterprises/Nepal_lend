import 'dart:math' as math;

import 'package:nepal_lend/core/config/product_rules.dart';

/// One instalment of a reducing-balance schedule. All values are integer paisa.
class InstalmentAmount {
  const InstalmentAmount({
    required this.number,
    required this.dueDate,
    required this.principalPaisa,
    required this.interestPaisa,
  });

  final int number;
  final DateTime dueDate;
  final int principalPaisa;
  final int interestPaisa;

  int get totalPaisa => principalPaisa + interestPaisa;
}

/// Exact integer money maths. No `double` is used for amounts or ledgers.
class Money {
  const Money._();

  static const int _monthlyRateDenominator = 120000; // 12 * 10,000 bps

  /// Parse a user-entered NPR amount such as "1,25,000.50" into paisa.
  static int parseNpr(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    final parts = cleaned.split('.');
    final rupees = int.tryParse(parts.first) ?? 0;
    final fraction = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    return rupees * ProductRules.paisaPerNpr + int.parse(fraction);
  }

  /// Round a positive rational number half-up, without floating point.
  static int roundDiv(int numerator, int denominator) {
    if (denominator == 0) return 0;
    final negative = (numerator < 0) != (denominator < 0);
    final a = numerator.abs();
    final b = denominator.abs();
    final result = (a * 2 + b) ~/ (b * 2);
    return negative ? -result : result;
  }

  static BigInt roundDivBig(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) return BigInt.zero;
    final negative = numerator.isNegative != denominator.isNegative;
    final result = (numerator.abs() * BigInt.from(2) + denominator.abs()) ~/
        (denominator.abs() * BigInt.from(2));
    return negative ? -result : result;
  }

  /// Interest for one reducing-balance period, rounded to whole paisa.
  static int interestForPeriod(int balancePaisa, int annualRateBps) =>
      roundDiv(balancePaisa * annualRateBps, _monthlyRateDenominator);

  /// Equal instalment (EMI) computed exactly with BigInt rational arithmetic.
  ///
  /// EMI = P * r * (1+r)^n / ((1+r)^n - 1), r = annualRateBps / 120000.
  static int installmentPaisa({
    required int principalPaisa,
    required int rateBps,
    required int tenorMonths,
  }) {
    if (principalPaisa <= 0 || tenorMonths <= 0) return 0;
    if (rateBps == 0) return roundDiv(principalPaisa, tenorMonths);

    final base = BigInt.from(_monthlyRateDenominator + rateBps);
    final denominator = BigInt.from(_monthlyRateDenominator);
    var powerNumerator = BigInt.one;
    var powerDenominator = BigInt.one;
    for (var i = 0; i < tenorMonths; i++) {
      powerNumerator *= base;
      powerDenominator *= denominator;
    }

    final numerator = BigInt.from(principalPaisa) *
        BigInt.from(rateBps) *
        powerNumerator;
    final divisor =
        denominator * (powerNumerator - powerDenominator);
    final emi = roundDivBig(numerator, divisor).toInt();
    return emi < 1 ? 1 : emi;
  }

  /// Reducing-balance schedule. The final instalment absorbs all rounding so
  /// the schedule sums exactly to principal + interest.
  static List<InstalmentAmount> schedule({
    required int principalPaisa,
    required int rateBps,
    required int tenorMonths,
    DateTime? startDate,
  }) {
    if (principalPaisa <= 0 || tenorMonths <= 0) return const [];
    final emi = installmentPaisa(
      principalPaisa: principalPaisa,
      rateBps: rateBps,
      tenorMonths: tenorMonths,
    );
    final start = startDate ?? DateTime.now();
    var balance = principalPaisa;
    final result = <InstalmentAmount>[];

    for (var number = 1; number <= tenorMonths; number++) {
      final interest = interestForPeriod(balance, rateBps);
      final remainingPeriods = tenorMonths - number + 1;
      var principal = emi - interest;
      if (principal <= 0) principal = roundDiv(balance, remainingPeriods);
      if (principal > balance || remainingPeriods == 1) principal = balance;

      balance -= principal;
      if (balance < 0) balance = 0;
      result.add(
        InstalmentAmount(
          number: number,
          dueDate: DateTime(start.year, start.month + number, start.day),
          principalPaisa: principal,
          interestPaisa: interest,
        ),
      );
    }
    return result;
  }

  /// Split [amountPaisa] across [weights] using the largest-remainder method.
  /// The returned parts always sum exactly to [amountPaisa].
  static List<int> splitProRata({
    required int amountPaisa,
    required List<int> weights,
  }) {
    if (weights.isEmpty) return const [];
    final totalWeight = weights.fold<int>(0, (sum, weight) => sum + weight);
    if (totalWeight <= 0) return List<int>.filled(weights.length, 0);

    final parts = <int>[];
    final remainders = <int>[];
    for (final weight in weights) {
      final scaled = amountPaisa * weight;
      parts.add(scaled ~/ totalWeight);
      remainders.add(scaled % totalWeight);
    }

    var left = amountPaisa - parts.fold<int>(0, (sum, part) => sum + part);
    final order = List<int>.generate(weights.length, (index) => index)
      ..sort((a, b) => remainders[b].compareTo(remainders[a]));
    for (var i = 0; i < left && i < order.length; i++) {
      parts[order[i]] += 1;
    }
    return parts;
  }

  /// Platform fee for an interest amount, in paisa.
  static int feeForInterest(int interestPaisa) =>
      roundDiv(interestPaisa * ProductRules.feeBpsOfInterest, 10000);

  static double monthlyRateAsDouble(int rateBps) =>
      rateBps / _monthlyRateDenominator;

  static int clamp(int value, int min, int max) =>
      math.min(math.max(value, min), max);
}
