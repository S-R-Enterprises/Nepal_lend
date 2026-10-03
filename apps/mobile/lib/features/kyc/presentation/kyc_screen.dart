import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/auth_controller.dart';
import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class _KycStep {
  const _KycStep({
    required this.id,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.status,
  });

  final String id;
  final String icon;
  final String label;
  final String sublabel;
  final String status;
}

const List<_KycStep> _kycSteps = [
  _KycStep(
    id: 'id',
    icon: '🪪',
    label: 'National ID',
    sublabel: 'Citizenship / Passport',
    status: 'Approved',
  ),
  _KycStep(
    id: 'selfie',
    icon: '🤳',
    label: 'Selfie',
    sublabel: 'Live photo verification',
    status: 'In review',
  ),
  _KycStep(
    id: 'address',
    icon: '🏠',
    label: 'Address',
    sublabel: 'Permanent & temp address',
    status: 'Not started',
  ),
  _KycStep(
    id: 'bank',
    icon: '🏦',
    label: 'Bank / Wallet',
    sublabel: 'eSewa, Khalti, Bank',
    status: 'Not started',
  ),
];

class KYCScreen extends ConsumerStatefulWidget {
  const KYCScreen({super.key});

  @override
  ConsumerState<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends ConsumerState<KYCScreen> {
  String _expanded = 'selfie';

  int get _approvedCount =>
      _kycSteps.where((s) => s.status == 'Approved').length;

  void _finish() {
    final role = ref.read(authControllerProvider);
    context.go(
      role == UserRole.lender ? Routes.lenderHome : Routes.borrowerHome,
    );
  }

  Color _dotColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.riskLow;
      case 'In review':
        return AppColors.riskMed;
      case 'Needs changes':
        return AppColors.riskHigh;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoBanner(),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _kycSteps.length; i++)
                      _stepRow(i, _kycSteps[i]),
                    _nrbNotice(),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(
        children: [
          const Positioned.fill(child: DhakaPattern(opacity: 0.08)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20 + MediaQuery.of(context).padding.top,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KYC Verification',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'पहिचान प्रमाणीकरण',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: Color(0x8CFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: Color(0xB3FFFFFF),
                      ),
                    ),
                    Text(
                      '$_approvedCount of ${_kycSteps.length} complete',
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: _approvedCount.toDouble(),
                  max: _kycSteps.length.toDouble(),
                  height: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ℹ️', style: TextStyle(fontSize: 18, height: 1.3)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'KYC is required by Nepal Rastra Bank regulations. Your data is encrypted and never sold.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: Color(0xFF0D7A7A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int index, _KycStep step) {
    final isExpanded = _expanded == step.id;
    final last = index == _kycSteps.length - 1;
    final lineColor =
        step.status == 'Approved' ? AppColors.riskLow : AppColors.border;
    return Stack(
      children: [
        _stepDot(index, step),
        if (!last)
          Positioned(
            left: 11,
            top: 28,
            bottom: 0,
            child: Container(width: 2, color: lineColor),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 12),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isExpanded ? AppColors.teal : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(
                    () => _expanded = isExpanded ? '' : step.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        Text(step.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.label,
                                style: const TextStyle(
                                  fontFamily: kPoppins,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.navy,
                                ),
                              ),
                              Text(
                                step.sublabel,
                                style: const TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusPill(status: step.status),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: _stepDetails(step),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepDot(int index, _KycStep step) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _dotColor(step.status),
        shape: BoxShape.circle,
      ),
      child: step.status == 'Approved'
          ? const Text(
              '✓',
              style: TextStyle(fontSize: 12, color: AppColors.white),
            )
          : Text(
              '${index + 1}',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
    );
  }

  Widget _stepDetails(_KycStep step) {
    switch (step.status) {
      case 'Approved':
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅', style: TextStyle(fontSize: 13)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Verified on 14 Sep 2026. Expires Dec 2028.',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  color: AppColors.riskLow,
                  height: 1.5,
                ),
              ),
            ),
          ],
        );
      case 'In review':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏳ Under review. Usually 1–2 business days.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.riskMed,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Text('🤳', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Selfie uploaded on 28 Sep 2026.\nWe\'ll notify you once reviewed.',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        if (step.id == 'address') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provide your permanent and current addresses with proof.',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  color: AppColors.secondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {},
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Upload Address Proof',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link your eSewa, Khalti, or bank account for withdrawals.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.secondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _bankBtn('eSewa'),
                const SizedBox(width: 8),
                _bankBtn('Khalti'),
                const SizedBox(width: 8),
                _bankBtn('Bank'),
              ],
            ),
          ],
        );
    }
  }

  Widget _bankBtn(String label) {
    return Expanded(
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _nrbNotice() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF9C3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏛️', style: TextStyle(fontSize: 16, height: 1.3)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'NepalLend operates under NRB\'s Digital Financial Service guidelines. KYC data is processed per BAFIA 2073.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: Color(0xFF78350F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: AppBtn(
        fullWidth: true,
        onPressed: _finish,
        child: const Text('Continue'),
      ),
    );
  }
}
