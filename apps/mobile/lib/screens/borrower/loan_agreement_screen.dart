import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class LoanAgreementScreen extends StatefulWidget {
  const LoanAgreementScreen({super.key, this.signed = false});

  final bool signed;

  @override
  State<LoanAgreementScreen> createState() => _LoanAgreementScreenState();
}

class _LoanAgreementScreenState extends State<LoanAgreementScreen> {
  bool _signed = false;
  bool _checked = false;
  bool _fullAgreement = false;

  @override
  void initState() {
    super.initState();
    _signed = widget.signed;
    _checked = widget.signed;
  }

  void _downloadPdf() {}

  void _viewStatus() => Navigator.pushNamed(context, Routes.repay);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(title: 'Loan Agreement', back: true, light: true),
          Expanded(child: _signed ? _signedView() : _agreementView()),
        ],
      ),
    );
  }

  Widget _signedView() {
    const rows = [
      ('Agreement ID', 'AGR-2026-08412', true),
      ('Signed on', '29 Sep 2026, 11:23 AM', false),
      ('Valid until', '28 Sep 2027', false),
      ('Digital signature', 'OTP verified ✓', false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.riskLowBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('📝', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Agreement Signed!',
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
                  'Your loan agreement was digitally signed on 29 Sep 2026 '
                  'at 11:23 AM. Lenders will now fund your request.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 14,
                    color: AppColors.secondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++)
                        _detailRow(
                          rows[i].$1,
                          rows[i].$2,
                          mono: rows[i].$3,
                          isLast: i == rows.length - 1,
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppBtn(
                        fullWidth: true,
                        variant: AppBtnVariant.secondary,
                        onPressed: _downloadPdf,
                        child: const Text('Download PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppBtn(
                        fullWidth: true,
                        onPressed: _viewStatus,
                        child: const Text('View Status'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool mono = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: kInter,
              fontSize: 13,
              color: AppColors.secondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: mono ? 'monospace' : kPoppins,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreementClause(String heading, String body) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: heading,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: body),
        ],
      ),
      style: const TextStyle(
        fontFamily: kInter,
        fontSize: 12,
        color: AppColors.secondary,
        height: 1.7,
      ),
    );
  }

  Widget _agreementView() {
    const terms = [
      ('Loan Amount', 'NPR 80,000'),
      ('Interest Rate', '20% per annum'),
      ('Tenor', '12 months'),
      ('Monthly EMI', 'NPR 7,401'),
      ('Processing fee', 'NPR 800'),
      ('Early repayment', 'No penalty'),
      ('Late fee', '2% per month on overdue'),
      ('Governed by', 'Nepal Contract Act 2023'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Key Terms Summary',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                for (var i = 0; i < terms.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: i < terms.length - 1
                          ? const Border(
                              bottom:
                                  BorderSide(color: AppColors.border, width: 1),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          terms[i].$1,
                          style: const TextStyle(
                            fontFamily: kInter,
                            fontSize: 13,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          terms[i].$2,
                          style: const TextStyle(
                            fontFamily: kPoppins,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
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
                InkWell(
                  onTap: () => setState(() => _fullAgreement = !_fullAgreement),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Full Agreement',
                        style: TextStyle(
                          fontFamily: kPoppins,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        _fullAgreement ? 'Collapse ↑' : 'Read full ↓',
                        style: const TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_fullAgreement)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(
                      padding: const EdgeInsets.only(top: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PEER-TO-PEER LOAN AGREEMENT',
                              style: TextStyle(
                                fontFamily: kInter,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                height: 1.7,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This Loan Agreement ("Agreement") is entered into '
                              'as of the date of signing between NepalLend Pvt. '
                              'Ltd. ("Platform"), the Borrower, and the Lender(s) '
                              'participating in this loan.',
                              style: TextStyle(
                                fontFamily: kInter,
                                fontSize: 12,
                                color: AppColors.secondary,
                                height: 1.7,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _agreementClause(
                              '1. Loan Terms. ',
                              'The Platform facilitates this loan under NRB '
                              'Digital Financial Services framework. The borrower '
                              'agrees to repay the principal amount of NPR 80,000 '
                              '(Eighty Thousand Rupees) plus accrued interest at '
                              '20% per annum...',
                            ),
                            const SizedBox(height: 8),
                            _agreementClause(
                              '2. Repayment. ',
                              'Monthly installments of NPR 7,401 are due on the '
                              '15th of each calendar month...',
                            ),
                            const SizedBox(height: 8),
                            _agreementClause(
                              '3. Default. ',
                              'Failure to pay within 7 days of due date '
                              'constitutes default. A late fee of 2% per month '
                              'shall apply to the overdue amount...',
                            ),
                            const SizedBox(height: 8),
                            _agreementClause(
                              '4. Privacy. ',
                              "Borrower data is processed under Nepal's PDPA "
                              'framework...',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _checked ? AppColors.teal : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _checked ? AppColors.teal : AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _checked ? AppColors.teal : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: _checked
                          ? const Text(
                              '✓',
                              style: TextStyle(
                                fontFamily: kInter,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I have read and understood the Loan Agreement. I agree '
                      'to all terms and authorize NepalLend to proceed with '
                      'this loan.',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 13,
                        color: AppColors.navy,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBtn(
            fullWidth: true,
            size: AppBtnSize.lg,
            disabled: !_checked,
            onPressed: () => setState(() => _signed = true),
            child: const Text('Sign with OTP'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
