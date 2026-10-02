import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';
import 'fund_loan_sheet.dart';

class LoanDetailsScreen extends StatefulWidget {
  const LoanDetailsScreen({super.key});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  bool _ratingOpen = false;

  static const _factors = [
    ('✅', 'Income verification', 'Verified salary slip'),
    ('✅', 'Credit history', '2 loans, no defaults'),
    ('✅', 'Debt-to-income ratio', '28% (healthy)'),
    ('⚠️', 'Collateral', 'None provided'),
    ('✅', 'Loan purpose', 'Productive use'),
  ];

  static const _verifications = [
    'National ID',
    'Selfie verified',
    'Address confirmed',
    'Bank account linked',
    'Income proof',
  ];

  static const _schedule = [
    ('Nov 2026', 5667, 1200, 74333),
    ('Dec 2026', 5752, 1115, 68581),
    ('Jan 2027', 5839, 1028, 62742),
  ];

  void _openFundSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (_) => const FundLoanSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(title: 'Loan Details', back: true, light: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCard(),
                        const SizedBox(height: 14),
                        _buildFundingCard(),
                        const SizedBox(height: 14),
                        _buildRiskCard(),
                        const SizedBox(height: 14),
                        _buildVerificationCard(),
                        const SizedBox(height: 14),
                        _buildScheduleCard(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: AppBtn(
              fullWidth: true,
              size: AppBtnSize.lg,
              onPressed: _openFundSheet,
              child: const Text('Fund this Loan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🌾', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agriculture',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Paddy farming, Chitwan district',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: AppColors.alpha(Colors.white, 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                const RiskBadge(level: 'Low'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _statCell('Loan Amount', formatNPR(80000), divider: true),
          _statCell('Interest p.a.', '18%', divider: true),
          _statCell('Tenor', '12 months', divider: false),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, {required bool divider}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: divider
              ? const Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                )
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 11,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kPoppins,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingCard() {
    const funded = 56000.0;
    const total = 80000.0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Funding Progress',
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              Text(
                '${(funded / total * 100).round()}%',
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const ProgressBar(value: funded, max: total, height: 10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatNPR(funded)} funded',
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '${formatNPR(24000)} still available',
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metaPill('⏰ 4 days left'),
              const SizedBox(width: 8),
              _metaPill('👥 23 lenders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: kInter,
          fontSize: 12,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildRiskCard() {
    return AppCard(
      onTap: () => setState(() => _ratingOpen = !_ratingOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Rating',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  const Text(
                    'Why this rating?',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const RiskBadge(level: 'Low'),
                  const SizedBox(width: 10),
                  Transform.rotate(
                    angle: _ratingOpen ? math.pi / 2 : 0,
                    child: const Text(
                      '›',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_ratingOpen)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                children: [
                  for (final f in _factors)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(f.$1, style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(
                                f.$2,
                                style: const TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 13,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            f.$3,
                            style: const TextStyle(
                              fontFamily: kInter,
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Borrower Verification',
            style: TextStyle(
              fontFamily: kPoppins,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          for (final v in _verifications)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.riskLowBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.riskLow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    v,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 14,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repayment Schedule',
            style: TextStyle(
              fontFamily: kPoppins,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly installment',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: Color(0xFF0D7A7A),
                  ),
                ),
                Text(
                  formatNPR(7333),
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
          for (final r in _schedule)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      formatNPR(r.$2),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      formatNPR(r.$3),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      formatNPR(r.$4),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 70,
                  child: Text(
                    'Month',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Principal',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Interest',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 11,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Balance',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: const Text(
                'View full schedule →',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
