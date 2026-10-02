import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class LoanStakeDetailScreen extends StatelessWidget {
  const LoanStakeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(
            title: 'Loan Stake Detail',
            back: true,
            light: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.navy,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Agriculture Loan',
                                    style: TextStyle(
                                      fontFamily: kPoppins,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Borrower #A-2041 · 18% p.a.',
                                    style: TextStyle(
                                      fontFamily: kInter,
                                      fontSize: 12,
                                      color: Color(0x8CFFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const StatusPill(status: 'On track'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _heroStat(
                                'Your Stake',
                                formatNPR(5000),
                                Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _heroStat(
                                'Received',
                                formatNPR(1000),
                                AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _heroStat(
                                'Remaining',
                                formatNPR(4000),
                                const Color(0xB3FFFFFF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const ProgressBar(
                          value: 2,
                          max: 12,
                          color: AppColors.teal,
                          height: 8,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '2 of 12 payments received',
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 11,
                            color: Color(0x80FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Repayment Timeline', style: AppText.h4),
                        const SizedBox(height: 14),
                        for (var i = 0; i < _payments.length; i++) ...[
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Column(
                                    children: [
                                      _timelineDot(_payments[i], i),
                                      if (i < _payments.length - 1)
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              width: 2,
                                              decoration: BoxDecoration(
                                                color: _payments[i].status ==
                                                        'received'
                                                    ? AppColors.riskLow
                                                    : AppColors.border,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _paymentCard(_payments[i]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _payments.length - 1)
                            const SizedBox(height: 2),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 11,
            color: Color(0x80FFFFFF),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: kPoppins,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timelineDot(_Payment p, int index) {
    final received = p.status == 'received';
    final highlighted = p.month == 'Oct 2026';
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: received
            ? AppColors.riskLow
            : p.status == 'late'
                ? AppColors.riskHigh
                : AppColors.border,
        shape: BoxShape.circle,
        border: highlighted
            ? Border.all(color: AppColors.teal, width: 2)
            : null,
      ),
      child: received
          ? const Text(
              '✓',
              style: TextStyle(fontSize: 12, color: Colors.white),
            )
          : Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
    );
  }

  Widget _paymentCard(_Payment p) {
    final received = p.status == 'received';
    final highlighted = p.month == 'Oct 2026';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? AppColors.teal : AppColors.border,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.month,
                style: const TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              if (highlighted)
                const Text(
                  '← Due in 4 days',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatNPR(p.total),
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: received ? AppColors.riskLow : AppColors.navy,
                ),
              ),
              Text(
                'P: ${formatNPR(p.principal)} · I: ${formatNPR(p.interest)}',
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Payment {
  const _Payment(
    this.month,
    this.principal,
    this.interest,
    this.total,
    this.status,
  );

  final String month;
  final int principal;
  final int interest;
  final int total;
  final String status;
}

const List<_Payment> _payments = [
  _Payment('Aug 2026', 390, 110, 500, 'received'),
  _Payment('Sep 2026', 397, 103, 500, 'received'),
  _Payment('Oct 2026', 404, 96, 500, 'upcoming'),
  _Payment('Nov 2026', 410, 90, 500, 'upcoming'),
  _Payment('Dec 2026', 417, 83, 500, 'upcoming'),
  _Payment('Jan 2027', 424, 76, 500, 'upcoming'),
];
