import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';

void main() {
  group('money parsing and formatting', () {
    test('parses a lakh-grouped amount into paisa', () {
      expect(Money.parseNpr('1,25,000.50'), 12500050);
      expect(Money.parseNpr('NPR 5,000'), 500000);
      expect(Money.parseNpr(''), 0);
    });

    test('formats NPR with lakh grouping', () {
      expect(formatNPR(12500050), 'NPR 1,25,000.50');
      expect(formatNPRCompact(20000000), 'NPR 2,00,000');
      expect(formatNPR(-500000), '-NPR 5,000.00');
      expect(formatBps(1400), '14.00%');
    });

    test('rounds rationals half-up', () {
      expect(Money.roundDiv(1, 2), 1);
      expect(Money.roundDiv(3, 2), 2);
      expect(Money.roundDiv(199, 100), 2);
    });
  });

  group('reducing-balance schedule', () {
    test('interest is computed in integer paisa', () {
      expect(Money.interestForPeriod(20000000, 1200), 200000);
      expect(Money.feeForInterest(100000), 10000);
    });

    test('schedule sums exactly to principal plus interest', () {
      const principal = 20000000;
      final schedule = Money.schedule(
        principalPaisa: principal,
        rateBps: 1400,
        tenorMonths: 12,
        startDate: DateTime(2026, 1, 15),
      );

      expect(schedule, hasLength(12));
      final totalPrincipal =
          schedule.fold<int>(0, (sum, item) => sum + item.principalPaisa);
      final totalInterest =
          schedule.fold<int>(0, (sum, item) => sum + item.interestPaisa);
      expect(totalPrincipal, principal);
      expect(totalInterest, greaterThan(0));
      expect(
        schedule.fold<int>(0, (sum, item) => sum + item.totalPaisa),
        principal + totalInterest,
      );
      expect(schedule.last.dueDate, DateTime(2027, 1, 15));
    });

    test('zero-rate schedule is exact', () {
      final schedule = Money.schedule(
        principalPaisa: 100000,
        rateBps: 0,
        tenorMonths: 3,
      );
      expect(
        schedule.fold<int>(0, (sum, item) => sum + item.totalPaisa),
        100000,
      );
    });
  });

  group('pro-rata split', () {
    test('parts always sum to the exact amount', () {
      final parts = Money.splitProRata(amountPaisa: 1000, weights: const [1, 1, 1]);
      expect(parts.fold<int>(0, (sum, part) => sum + part), 1000);
      expect(parts, [334, 333, 333]);
    });

    test('handles awkward stake ratios', () {
      final parts =
          Money.splitProRata(amountPaisa: 230000, weights: const [500000, 300000, 200000]);
      expect(parts.fold<int>(0, (sum, part) => sum + part), 230000);
      expect(parts[0], greaterThan(parts[1]));
      expect(parts[1], greaterThan(parts[2]));
    });
  });
}
