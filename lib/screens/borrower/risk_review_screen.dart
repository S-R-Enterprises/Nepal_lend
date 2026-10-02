import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class RiskReviewScreen extends StatelessWidget {
  const RiskReviewScreen({super.key, this.underReview = false});

  final bool underReview;

  void _accept(BuildContext context) =>
      Navigator.pushNamed(context, Routes.loanAgreement);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(title: 'Risk Assessment', back: true, light: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: underReview ? _underReview() : _result(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _underReview() {
    const steps = [
      ('Application submitted', true, '29 Sep 2026'),
      ('Documents verified', true, '29 Sep 2026'),
      ('Admin review', false, 'In progress'),
      ('Decision', false, 'Expected 1 Oct 2026'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.riskMedBg,
                shape: BoxShape.circle,
              ),
              child: const Text('🔍', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Under Admin Review',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPoppins,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your application has been flagged for manual review. '
            'Our team will assess it within 1–2 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.riskMedBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Why was it flagged?',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.riskMed,
                    ),
                  ),
                ),
                Text(
                  'Your requested amount exceeds the auto-approval threshold. '
                  'A human reviewer will verify your income documents.',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: Color(0xFF78350F),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Review Progress',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                for (var i = 0; i < steps.length; i++)
                  _progressRow(
                    i,
                    steps[i],
                    isLast: i == steps.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppBtn(
            fullWidth: true,
            variant: AppBtnVariant.secondary,
            onPressed: () {},
            child: const Text('Withdraw Application'),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    int index,
    (String, bool, String) step, {
    required bool isLast,
  }) {
    final (label, done, date) = step;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.riskLow : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: done
                ? const Text(
                    '✓',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 14,
                fontWeight: done ? FontWeight.w500 : FontWeight.w400,
                color: done ? AppColors.navy : AppColors.secondary,
              ),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontFamily: kInter,
              fontSize: 11,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) {
    const factors = [
      (
        'Payment history',
        'Excellent',
        AppColors.riskLow,
        '✅',
        '2 loans, 0 late payments',
      ),
      (
        'Income verification',
        'Verified',
        AppColors.riskLow,
        '✅',
        'Salary slip + bank statement',
      ),
      (
        'Debt-to-income',
        'Good (35%)',
        AppColors.blueFg,
        '🔵',
        'Below 40% threshold',
      ),
      (
        'Employment',
        'Stable',
        AppColors.riskLow,
        '✅',
        '3+ years same employer',
      ),
      (
        'No collateral',
        'Penalty -1',
        AppColors.riskMed,
        '⚠️',
        'Provide collateral for grade A',
      ),
    ];
    const tips = [
      'Add collateral documents',
      'Link ConnectIPS bank account',
      'Upload additional income proof',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: const [
              GradeBadge(grade: 'B+'),
              SizedBox(height: 12),
              Text(
                'Your Risk Grade',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 12),
              RiskBadge(level: 'Medium'),
              SizedBox(height: 12),
              Text(
                'Grade B+ means moderate risk. Lenders will offer rates '
                'between 18–22% p.a.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  color: Color(0x99FFFFFF),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        AppCard(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Rating Factors',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
              for (var i = 0; i < factors.length; i++)
                _factorRow(factors[i], isLast: i == factors.length - 1),
            ],
          ),
        ),
        AppCard(
          color: AppColors.mint,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  '💡 Improve to Grade A',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
              for (final tip in tips)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            fontFamily: kInter,
                            fontSize: 13,
                            color: Color(0xFF0D7A7A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppBtn(
          fullWidth: true,
          onPressed: () => _accept(context),
          child: const Text('Accept & List for Funding'),
        ),
        const SizedBox(height: 10),
        AppBtn(
          fullWidth: true,
          variant: AppBtnVariant.secondary,
          onPressed: () {},
          child: const Text('Improve Grade First'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _factorRow(
    (String, String, Color, String, String) factor, {
    required bool isLast,
  }) {
    final (name, score, color, icon, detail) = factor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              Text(
                score,
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 24),
            child: Text(
              detail,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
