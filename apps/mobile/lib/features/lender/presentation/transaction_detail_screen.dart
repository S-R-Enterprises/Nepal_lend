import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  static final List<({String label, String value, bool mono})> _rows = [
    (
      label: 'Reference ID',
      value: 'NL-2026-092801847',
      mono: true,
    ),
    (
      label: 'Date & Time',
      value: '28 Sep 2026, 09:41 AM',
      mono: false,
    ),
    (
      label: 'Description',
      value: 'Loan repayment from Borrower #A-2041',
      mono: false,
    ),
    (
      label: 'Payment method',
      value: 'NepalLend Wallet',
      mono: false,
    ),
    (
      label: 'Principal',
      value: formatNPR(1960),
      mono: false,
    ),
    (
      label: 'Interest',
      value: formatNPR(880),
      mono: false,
    ),
    (
      label: 'Platform fee',
      value: formatNPR(0),
      mono: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(
            title: 'Transaction',
            back: true,
            light: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1412284C),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.riskLowBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '↓',
                            style: TextStyle(
                              fontSize: 28,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Money received',
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 13,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${formatNPR(2840)}',
                          style: const TextStyle(
                            fontFamily: kPoppins,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.riskLow,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const StatusPill(status: 'Approved'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _rows.length; i++)
                          _detailRow(_rows[i], i < _rows.length - 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppBtn(
                          variant: AppBtnVariant.secondary,
                          size: AppBtnSize.sm,
                          fullWidth: true,
                          onPressed: () {},
                          child: const Text('Download PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppBtn(
                          variant: AppBtnVariant.ghost,
                          size: AppBtnSize.sm,
                          fullWidth: true,
                          onPressed: () {},
                          child: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(({String label, String value, bool mono}) row, bool divider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: row.mono ? 'monospace' : kInter,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
