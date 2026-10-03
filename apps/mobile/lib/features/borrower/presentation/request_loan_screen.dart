import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  static const int _maxAmount = 200000;
  static const List<int> _tenors = [3, 6, 12, 18, 24, 36];
  static const List<String> _purposes = [
    'Agriculture 🌾',
    'Education 📚',
    'Business 🏪',
    'Medical 🏥',
    'Home 🏠',
    'Vehicle 🚗',
    'Electronics 💻',
    'Other',
  ];

  int _amount = 80000;
  int _tenor = 12;
  String _purpose = 'Business 🏪';

  int get _emi {
    const rate = 0.20;
    final monthlyRate = rate / 12;
    final factor = math.pow(1 + monthlyRate, _tenor);
    return ((_amount * monthlyRate * factor) / (factor - 1)).round();
  }

  int get _totalInterest => _emi * _tenor - _amount;

  void _continue() => context.push(Routes.riskReview);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const UAppBar(title: 'Request a Loan', back: true, light: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _amountCard(),
                  _tenorCard(),
                  _purposeCard(),
                  _estimateCard(),
                  AppBtn(
                    fullWidth: true,
                    size: AppBtnSize.lg,
                    onPressed: _continue,
                    child: const Text('Continue to Apply'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'Loan Amount',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              formatNPR(_amount),
              style: const TextStyle(
                fontFamily: kPoppins,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                height: 1.2,
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.teal,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.teal,
              overlayColor: AppColors.alpha(AppColors.teal, 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _amount.toDouble(),
              min: 10000,
              max: _maxAmount.toDouble(),
              divisions: 38,
              onChanged: (v) => setState(() => _amount = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'NPR 10,000',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Max NPR 200,000',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Your limit is ${formatNPR(_maxAmount)} because:',
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  _limitRow('✅', 'Verified income: NPR 45,000/mo.'),
                  _limitRow('✅', 'Good repayment history'),
                  _limitRow(
                    '⬆️',
                    'Add income proof to increase limit',
                    action: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _limitRow(String icon, String text, {bool action = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                fontWeight: action ? FontWeight.w600 : FontWeight.w400,
                color: action ? AppColors.teal : AppColors.secondary,
              ),
            ),
          ),
          if (action)
            const Text(
              '→',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: AppColors.teal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tenorCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Repayment Period',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tenors)
                _SelectPill(
                  label: '$t mo',
                  selected: _tenor == t,
                  onTap: () => setState(() => _tenor = t),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _purposeCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Loan Purpose',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _purposes)
                AppChip(
                  label: p,
                  active: _purpose == p,
                  onPressed: () => setState(() => _purpose = p),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estimateCard() {
    return AppCard(
      color: AppColors.navy,
      borderColor: null,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Live Estimate',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.alpha(Colors.white, 0.7),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _estimateStat(
                  'Monthly EMI',
                  formatNPR(_emi),
                  highlight: true,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: _EstimateStat(label: 'Interest Rate', value: '20% p.a.')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _estimateStat('Total Interest', formatNPR(_totalInterest)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _estimateStat(
                  'Total Payable',
                  formatNPR(_amount + _totalInterest),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.alpha(Colors.white, 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Rate based on your B+ grade. Improve grade by adding '
                'income proof for a lower rate.',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 11,
                  color: AppColors.alpha(Colors.white, 0.5),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimateStat(String label, String value, {bool highlight = false}) {
    return _EstimateStat(label: label, value: value, highlight: highlight);
  }
}

class _EstimateStat extends StatelessWidget {
  const _EstimateStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 11,
              color: AppColors.alpha(Colors.white, 0.5),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: kPoppins,
            fontSize: highlight ? 22 : 16,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.teal : Colors.white,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.tealLight : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.teal : AppColors.border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.teal : AppColors.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
