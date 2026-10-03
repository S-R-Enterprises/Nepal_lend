import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  static const List<String> _chips = [
    'All',
    'Low Risk',
    'Medium Risk',
    'High Risk',
  ];

  static const List<String> _levels = ['Low', 'Medium', 'High'];

  static const List<String> _statuses = [
    'On track',
    'Late',
    'Repaid',
    'Active',
    'Pending',
    'Not started',
    'In review',
    'Approved',
    'Needs changes',
  ];

  static const List<String> _grades = ['A+', 'A', 'B+', 'B', 'C', 'D'];

  static const List<({String name, String hex, String usage, bool dark, Color color})>
      _palette = [
    (name: 'Navy', hex: '#12284C', usage: 'Headings, Nav', dark: true, color: AppColors.navy),
    (name: 'Teal', hex: '#1AA6A6', usage: 'Actions, CTA', dark: true, color: AppColors.teal),
    (name: 'Mint', hex: '#E3F6F1', usage: 'Highlights, BG', dark: false, color: AppColors.mint),
    (name: 'Surface', hex: '#F5F8FA', usage: 'Screen BG', dark: false, color: AppColors.surface),
    (name: 'Secondary', hex: '#5B6472', usage: 'Subtext, Icons', dark: true, color: AppColors.secondary),
    (name: 'Border', hex: '#C9D1DA', usage: 'Dividers, Input', dark: false, color: AppColors.border),
    (name: 'Risk Low', hex: '#16A34A', usage: 'Low risk', dark: true, color: AppColors.riskLow),
    (name: 'Risk High', hex: '#DC2626', usage: 'High risk', dark: true, color: AppColors.riskHigh),
  ];

  static const List<({String label, double value, Color color})> _progress = [
    (label: 'Funded 78%', value: 78, color: AppColors.teal),
    (label: 'Funded 40%', value: 40, color: AppColors.riskMed),
    (label: 'KYC Progress', value: 60, color: Color(0xFF6366F1)),
  ];

  String _activeChip = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const UAppBar(title: 'Style Guide', light: true, back: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Section(title: 'Color Palette', child: _buildPalette()),
                        const SizedBox(height: 24),
                        _Section(title: 'Typography', child: _buildTypography()),
                        const SizedBox(height: 24),
                        _Section(title: 'Buttons', child: _buildButtons()),
                        const SizedBox(height: 24),
                        _Section(title: 'Chips & Filters', child: _buildChips()),
                        const SizedBox(height: 24),
                        _Section(title: 'Input Fields', child: _buildInputs()),
                        const SizedBox(height: 24),
                        const _Section(
                          title: 'OTP Input',
                          child: AppCard(child: OTPInput(value: '4821')),
                        ),
                        const SizedBox(height: 24),
                        _Section(title: 'Progress Bar', child: _buildProgress()),
                        const SizedBox(height: 24),
                        _Section(title: 'Status Pills', child: _buildStatusPills()),
                        const SizedBox(height: 24),
                        _Section(title: 'Grade Badges', child: _buildGrades()),
                        const SizedBox(height: 24),
                        const _Section(title: 'Loading State', child: LoadingState()),
                        const SizedBox(height: 24),
                        _Section(title: 'Empty State', child: _buildEmptyState()),
                        const SizedBox(height: 24),
                        _Section(
                          title: 'Error State',
                          child: ErrorState(onRetry: () {}),
                        ),
                        const SizedBox(height: 24),
                        _Section(title: 'Bottom Navigation', child: _buildBottomNav()),
                        const SizedBox(height: 24),
                        _Section(title: 'Dhaka Pattern Accent', child: _buildDhakaAccent()),
                        const SizedBox(height: 24),
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

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      color: AppColors.navy,
      child: Stack(
        children: [
          const Positioned.fill(child: DhakaPattern(opacity: 0.08)),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NepalLend',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Component Library & Style Guide',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Material 3 · 8pt Grid · 360 × 800',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: Color(0x99FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _palette.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Swatch(entry: _palette[i])),
              const SizedBox(width: 10),
              Expanded(child: _Swatch(entry: _palette[i + 1])),
            ],
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              for (var i = 0; i < _levels.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _RiskBox(level: _levels[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypography() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Display / 28 Bold', style: AppText.display),
          const SizedBox(height: 12),
          const Text('Heading 1 / 24', style: AppText.h1),
          const SizedBox(height: 12),
          const Text('Heading 2 / 20', style: AppText.h2),
          const SizedBox(height: 12),
          const Text('Heading 3 / 17', style: AppText.h3),
          const SizedBox(height: 12),
          const Text(
            'Body / 15 — Loan funds help real borrowers grow their businesses and improve lives across Nepal.',
            style: AppText.body,
          ),
          const SizedBox(height: 12),
          const Text(
            'Caption / 13 — Secondary information and metadata',
            style: AppText.caption,
          ),
          const SizedBox(height: 12),
          Text(formatNPR(125000), style: AppText.amountLg),
          const SizedBox(height: 12),
          const Text(
            'Tabular amount / Poppins Bold',
            style: AppText.caption,
          ),
          const AppDivider(margin: 4),
          const Text('Devanagari Ready', style: TextStyle(fontFamily: kPoppins, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.navy, height: 1.35)),
          const SizedBox(height: 12),
          const Text(
            'सीधा उधारो र ऋण — नेपाललेन्ड',
            style: TextStyle(fontFamily: kInter, fontSize: 15, color: AppColors.navy, height: 1.7),
          ),
          const SizedBox(height: 12),
          const Text('NPR १,२५,०००', style: AppText.caption),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBtn(fullWidth: true, child: Text('Fund this Loan')),
          const SizedBox(height: 10),
          const AppBtn(fullWidth: true, variant: AppBtnVariant.secondary, child: Text('Browse Loans')),
          const SizedBox(height: 10),
          const AppBtn(fullWidth: true, variant: AppBtnVariant.ghost, child: Text('Cancel')),
          const SizedBox(height: 10),
          const AppBtn(fullWidth: true, variant: AppBtnVariant.danger, child: Text('Withdraw')),
          const SizedBox(height: 10),
          Row(
            children: [
              const AppBtn(size: AppBtnSize.sm, child: Text('Small')),
              const SizedBox(width: 8),
              const AppBtn(size: AppBtnSize.sm, variant: AppBtnVariant.secondary, child: Text('Small')),
            ],
          ),
          const SizedBox(height: 10),
          const AppBtn(fullWidth: true, loading: true, child: Text('Processing…')),
          const SizedBox(height: 10),
          const AppBtn(fullWidth: true, disabled: true, child: Text('Disabled State')),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return AppCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final chip in _chips)
            AppChip(
              label: chip,
              active: _activeChip == chip,
              onPressed: () => setState(() => _activeChip = chip),
            ),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'Phone Number',
            placeholder: '98XXXXXXXX',
            prefix: const Text(
              '+977',
              style: TextStyle(fontFamily: kInter, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'Amount',
            placeholder: '0.00',
            prefix: const Text(
              'NPR',
              style: TextStyle(fontFamily: kInter, fontSize: 14, color: AppColors.secondary),
            ),
            value: '5,000',
            hint: 'Min NPR 1,000 · Max NPR 5,000',
          ),
          const SizedBox(height: 14),
          const AppInput(
            label: 'OTP Code',
            placeholder: 'Enter 6-digit code',
            error: 'Incorrect code. 2 attempts left.',
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _progress.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _progress[i].label,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                ProgressBar(
                  value: _progress[i].value,
                  color: _progress[i].color,
                  height: 8,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: '💼',
      title: 'No Active Loans',
      desc:
          "You haven't funded any loans yet. Browse available loans to get started.",
      action: AppBtn(size: AppBtnSize.sm, child: Text('Browse Loans')),
    );
  }

  Widget _buildStatusPills() {
    return AppCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final status in _statuses) StatusPill(status: status)],
      ),
    );
  }

  Widget _buildGrades() {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final grade in _grades) ...[
            Column(
              children: [
                GradeBadge(grade: grade),
                const SizedBox(height: 4),
                Text(
                  grade,
                  style: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 10,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            if (grade != _grades.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const BottomNav(
          items: [
            BottomNavItem(icon: Icon(Icons.home), label: 'Home', active: true),
            BottomNavItem(icon: Icon(Icons.search), label: 'Browse'),
            BottomNavItem(icon: Icon(Icons.bar_chart), label: 'Portfolio'),
            BottomNavItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            BottomNavItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDhakaAccent() {
    return Container(
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: DhakaPattern(opacity: 0.18)),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'NepalLend — सिधै उधारो',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: kPoppins,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              letterSpacing: 1.12,
              height: 1.3,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.entry});

  final ({String name, String hex, String usage, bool dark, Color color}) entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            alignment: Alignment.bottomLeft,
            color: entry.color,
            child: Text(
              entry.hex,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: entry.dark
                    ? AppColors.alpha(Colors.white, 0.9)
                    : AppColors.alpha(Colors.black, 0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                    height: 1.3,
                  ),
                ),
                Text(
                  entry.usage,
                  style: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 11,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBox extends StatelessWidget {
  const _RiskBox({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: RiskBadge(level: level),
    );
  }
}
