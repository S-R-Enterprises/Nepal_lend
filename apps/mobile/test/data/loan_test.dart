import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';

Loan _loan(LoanStatus status) => Loan(
      id: 'loan-1',
      borrowerId: 'u1',
      purpose: 'Business inventory',
      amountPaisa: 20000000,
      tenorMonths: 12,
      rateBps: 1200,
      status: status,
      monthlyIncomePaisa: 5000000,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test('loan transitions allow the happy path and reject illegal jumps', () {
    expect(LoanTransitions.canTransition(LoanStatus.draft, LoanStatus.open), isTrue);
    expect(
      LoanTransitions.canTransition(LoanStatus.pendingReview, LoanStatus.open),
      isTrue,
    );
    expect(LoanTransitions.canTransition(LoanStatus.open, LoanStatus.funded), isTrue);
    expect(
      LoanTransitions.canTransition(LoanStatus.funded, LoanStatus.active),
      isTrue,
    );
    expect(
      LoanTransitions.canTransition(LoanStatus.active, LoanStatus.repaid),
      isTrue,
    );

    for (final illegal in [
      (LoanStatus.draft, LoanStatus.active),
      (LoanStatus.rejected, LoanStatus.open),
      (LoanStatus.active, LoanStatus.funded),
      (LoanStatus.repaid, LoanStatus.active),
    ]) {
      expect(
        () => LoanTransitions.check(illegal.$1, illegal.$2),
        throwsA(isA<AppFailure>()),
      );
    }
  });

  test('loan json round-trips assessment, agreement and instalments', () {
    final instalment = Instalment(
      id: 'loan-1-inst-1',
      loanId: 'loan-1',
      number: 1,
      dueDate: DateTime(2026, 2, 1),
      principalPaisa: 1569231,
      interestPaisa: 200000,
    );
    final loan = _loan(LoanStatus.active).copyWith(
      riskGrade: 'A',
      riskBand: RiskBand.low,
      assessment: RiskAssessment(
        score: 82,
        grade: 'A',
        band: RiskBand.low,
        rateBps: 1200,
        factors: const [
          RiskFactor(
            name: 'Affordability',
            direction: RiskDirection.neutral,
            note: 'EMI NPR 17,769 is 36% of income.',
          ),
        ],
      ),
      agreement: Agreement(
        id: 'agr-loan-1',
        loanId: 'loan-1',
        termsVersion: 'v1',
        termsHash: 'abcd1234',
        signedBy: 'Demo Borrower',
        signedAt: DateTime(2026, 1, 2),
        disbursementJournalId: 'txn-disburse-loan-1',
      ),
      instalments: [instalment],
    );

    final decoded = Loan.fromJson(loan.toJson());

    expect(decoded.id, 'loan-1');
    expect(decoded.status, LoanStatus.active);
    expect(decoded.assessment?.score, 82);
    expect(decoded.assessment?.factors.single.name, 'Affordability');
    expect(decoded.agreement?.termsHash, 'abcd1234');
    expect(decoded.instalments.single.totalPaisa, 1769231);
    expect(decoded.instalments.single.number, 1);
  });

  test('derived loan flags reflect state', () {
    expect(_loan(LoanStatus.open).canFund, isTrue);
    expect(
      _loan(LoanStatus.open).copyWith(fundingDeadline: DateTime(2020)).canFund,
      isFalse,
    );
    expect(
      _loan(LoanStatus.funded).copyWith(fundedPaisa: 20000000).canSign,
      isTrue,
    );
    expect(_loan(LoanStatus.funded).canSign, isFalse);
    expect(_loan(LoanStatus.active).canSign, isFalse);
  });
}
