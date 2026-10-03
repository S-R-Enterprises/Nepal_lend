import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class FundLoanSheet extends StatefulWidget {
  const FundLoanSheet({super.key});

  @override
  State<FundLoanSheet> createState() => _FundLoanSheetState();
}

class _FundLoanSheetState extends State<FundLoanSheet> {
  static const _quickAmounts = [1000, 2500, 5000, 10000];

  final TextEditingController _controller = TextEditingController(text: '5000');
  String _amount = '5000';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _numAmount => int.tryParse(_amount.replaceAll(',', '')) ?? 0;

  int get _interest => (_numAmount * 0.18 * (12 / 12)).round();

  int get _total => _numAmount + _interest;

  void _setAmount(String value) {
    _controller.text = value;
    setState(() => _amount = value);
  }

  void _confirm() {
    final nav = Navigator.of(context);
    nav.pop();
    nav.pushNamed(
      Routes.fundingSuccess,
      arguments: const {'partial': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return SystemChromeStyle(
      light: true,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fund this Loan',
                      style: TextStyle(
                        fontFamily: kPoppins,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Agriculture · 18% p.a. · 12 months',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick amounts',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final a in _quickAmounts) ...[
                          if (a != _quickAmounts.first)
                            const SizedBox(width: 8),
                          _quickChip(a),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Custom Amount',
                      controller: _controller,
                      onChanged: (v) => setState(() => _amount = v),
                      prefix: const Text(
                        'NPR',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 14,
                          color: AppColors.secondary,
                        ),
                      ),
                      hint: 'Available: ${formatNPR(24000)}',
                      keyboardType: TextInputType.number,
                    ),
                    if (_numAmount > 0) _buildReturns(),
                    const SizedBox(height: 12),
                    _noticeBox(
                      bg: const Color(0xFFFEF9C3),
                      icon: '⚠️',
                      color: const Color(0xFF78350F),
                      text:
                          'P2P lending carries risk. Your principal may not be fully returned. Only invest what you can afford to lose.',
                    ),
                    const SizedBox(height: 8),
                    _noticeBox(
                      bg: AppColors.tealLight,
                      icon: '💡',
                      color: const Color(0xFF0D7A7A),
                      text:
                          'Tip: Diversify across 5–10 loans to reduce risk. You have 6 active loans.',
                    ),
                    const SizedBox(height: 16),
                    AppBtn(
                      fullWidth: true,
                      size: AppBtnSize.lg,
                      onPressed: _confirm,
                      child: const Text('Confirm with PIN'),
                    ),
                    SizedBox(height: 32 + bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickChip(int amount) {
    final active = _amount == '$amount';
    return Expanded(
      child: GestureDetector(
        onTap: () => _setAmount('$amount'),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.tealLight : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.teal : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            formatNPR(amount).replaceFirst('NPR ', ''),
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.teal : AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturns() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expected Returns',
            style: TextStyle(
              fontFamily: kPoppins,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          _returnRow(
            'Principal',
            formatNPR(_numAmount),
            AppColors.navy,
            false,
          ),
          const SizedBox(height: 10),
          _returnRow(
            'Interest (12 mo.)',
            '+${formatNPR(_interest)}',
            AppColors.teal,
            false,
          ),
          const SizedBox(height: 10),
          _returnRow(
            'Total return',
            formatNPR(_total),
            AppColors.navy,
            true,
          ),
        ],
      ),
    );
  }

  Widget _returnRow(String label, String value, Color color, bool bold) {
    return Row(
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
            fontFamily: kPoppins,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _noticeBox({
    required Color bg,
    required String icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                height: 1.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
