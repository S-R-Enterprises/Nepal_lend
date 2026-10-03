import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class _Slide {
  const _Slide({
    required this.emoji,
    required this.title,
    required this.titleNp,
    required this.desc,
    required this.bg,
  });

  final String emoji;
  final String title;
  final String titleNp;
  final String desc;
  final Color bg;
}

const List<_Slide> _slides = [
  _Slide(
    emoji: '🤝',
    title: 'Fund Real People',
    titleNp: 'वास्तविक मान्छेलाई लगानी',
    desc:
        'Directly fund verified borrowers across Nepal. Every rupee you lend goes straight to someone’s goal — no middlemen.',
    bg: AppColors.mint,
  ),
  _Slide(
    emoji: '📊',
    title: 'Transparent Risk',
    titleNp: 'पारदर्शी जोखिम',
    desc:
        'Every loan is rated A to D. See exactly why, read the borrower\'s profile, and choose what matches your risk comfort.',
    bg: Color(0xFFEEF2FF),
  ),
  _Slide(
    emoji: '📈',
    title: 'Track Every Rupee',
    titleNp: 'हरेक रुपैयाँ ट्र्याक गर्नुस्',
    desc:
        'Watch your interest compound in real-time. Detailed repayment timelines and instant wallet payouts.',
    bg: AppColors.riskMedBg,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _current = 0;
  String _lang = 'en';

  bool get _isEn => _lang == 'en';

  void _goToRoleSelection() {
    Navigator.of(context).pushNamed(Routes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    return SystemChromeStyle(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _topBar(),
            _illustration(slide),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _content(slide),
              ),
            ),
            _dots(),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16 + MediaQuery.of(context).padding.top,
        20,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _langBtn('en', 'EN'),
                const SizedBox(width: 2),
                _langBtn('np', 'नेपाली'),
              ],
            ),
          ),
          GestureDetector(
            onTap: _goToRoleSelection,
            child: Text(
              _isEn ? 'Skip' : 'छोड्नुहोस्',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    final active = _lang == code;
    return GestureDetector(
      onTap: () => setState(() => _lang = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kInter,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.navy : AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _illustration(_Slide slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 240,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: slide.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(slide.emoji, style: const TextStyle(fontSize: 80, height: 1.1)),
          if (_current == 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stat(formatNPR(1250000), 'Disbursed'),
                const SizedBox(width: 8),
                _stat('2,840', 'Borrowers'),
                const SizedBox(width: 8),
                _stat('18.4%', 'Avg. Return'),
              ],
            ),
          ],
          if (_current == 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _grade('A', AppColors.riskLow, AppColors.riskLowBg),
                const SizedBox(width: 8),
                _grade('B', AppColors.blueFg, AppColors.blueBg),
                const SizedBox(width: 8),
                _grade('C', AppColors.riskMed, AppColors.riskMedBg),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.alpha(AppColors.white, 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: kPoppins,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.navy,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: kInter,
              fontSize: 10,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grade(String grade, Color color, Color bg) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontFamily: kPoppins,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: color,
        ),
      ),
    );
  }

  Widget _content(_Slide slide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isEn ? slide.title : slide.titleNp, style: AppText.h1),
        const SizedBox(height: 6),
        Text(
          slide.desc,
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 15,
            color: AppColors.secondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _dots() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _slides.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _current = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _current ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _current ? AppColors.teal : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions() {
    final last = _current == _slides.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: AppBtn(
        fullWidth: true,
        onPressed: last
            ? _goToRoleSelection
            : () => setState(() => _current = _current + 1),
        child: Text(
          last
              ? (_isEn ? 'Get Started' : 'सुरु गर्नुहोस्')
              : (_isEn ? 'Next' : 'अर्को'),
        ),
      ),
    );
  }
}
