import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class LenderHomeScreen extends StatefulWidget {
  const LenderHomeScreen({super.key});

  @override
  State<LenderHomeScreen> createState() => _LenderHomeScreenState();
}

class _LenderHomeScreenState extends State<LenderHomeScreen> {
  int _tab = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _tab = 0);
      return;
    }
    const targets = <String?>[
      null,
      Routes.browseLoans,
      Routes.portfolio,
      Routes.wallet,
      Routes.profile,
    ];
    final target = targets[index];
    if (target != null) context.push(target);
  }

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [_HomeContent()],
              ),
            ),
            BottomNav(items: _lenderNav(_tab), onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeaderWavePainter()),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: AppColors.alpha(Colors.white, 0.55),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: const Text(
                          'Priya Shrestha 👋',
                          style: TextStyle(
                            fontFamily: kPoppins,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildBell(context),
                ],
              ),
              const SizedBox(height: 20),
              _buildWalletCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBell(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.notifications),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.alpha(Colors.white, 0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.navy, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alpha(Colors.white, 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alpha(Colors.white, 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Balance',
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 12,
              color: AppColors.alpha(Colors.white, 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatNPR(48500),
            style: const TextStyle(
              fontFamily: kPoppins,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _walletStat('Total Lent', formatNPR(125000)),
              const SizedBox(width: 16),
              _walletStat('Interest Earned', formatNPR(18640)),
              const SizedBox(width: 16),
              _walletStat('Active Loans', '7'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 10,
              color: AppColors.alpha(Colors.white, 0.5),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: kPoppins,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  static const _repayments = [
    (borrower: 'Ramesh K.', date: 'Tomorrow', amount: 2840, status: 'On track'),
    (borrower: 'Sita P.', date: '3 Oct 2026', amount: 5200, status: 'On track'),
    (borrower: 'Bijay M.', date: '8 Oct 2026', amount: 1800, status: 'Late'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _quickAction(
                context,
                '➕',
                'Add Money',
                AppColors.teal,
                AppColors.mint,
                () => context.push(Routes.wallet),
              ),
              const SizedBox(width: 10),
              _quickAction(
                context,
                '🔍',
                'Browse Loans',
                AppColors.navy,
                AppColors.surface,
                () => context.push(Routes.browseLoans),
              ),
              const SizedBox(width: 10),
              _quickAction(
                context,
                '↑',
                'Withdraw',
                const Color(0xFF6366F1),
                const Color(0xFFEEF2FF),
                () => context.push(Routes.wallet),
              ),
              const SizedBox(width: 10),
              _quickAction(
                context,
                '📊',
                'Portfolio',
                AppColors.riskMed,
                AppColors.riskMedBg,
                () => context.push(Routes.portfolio),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Upcoming Repayments',
            action: GestureDetector(
              onTap: () => context.push(Routes.portfolio),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
          Column(
            children: [
              for (final r in _repayments) _repaymentRow(r),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Recommended for You',
            action: GestureDetector(
              onTap: () => context.push(Routes.browseLoans),
              child: const Text(
                'Browse all',
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
          LoanCard(
            purpose: 'Agriculture',
            borrower: 'Borrower #A-2041',
            amount: 80000,
            rate: 18,
            tenor: 12,
            risk: 'Low',
            funded: 56000,
            total: 80000,
            onTap: () => context.push(Routes.loanDetails),
          ),
          LoanCard(
            purpose: 'Education',
            borrower: 'Borrower #E-1892',
            amount: 50000,
            rate: 16,
            tenor: 24,
            risk: 'Low',
            funded: 22000,
            total: 50000,
            onTap: () => context.push(Routes.loanDetails),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    String icon,
    String label,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _repaymentRow(
    ({String borrower, String date, int amount, String status}) r,
  ) {
    final late = r.status == 'Late';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: late ? AppColors.riskHighBg : AppColors.mint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              late ? '⚠️' : '💰',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.borrower,
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  r.date,
                  style: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatNPR(r.amount),
                style: const TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              StatusPill(status: r.status),
            ],
          ),
        ],
      ),
    );
  }
}

List<BottomNavItem> _lenderNav(int active) {
  return [
    BottomNavItem(
      icon: Icon(
        active == 0 ? Icons.home : Icons.home_outlined,
        size: 24,
      ),
      label: 'Home',
      active: active == 0,
    ),
    BottomNavItem(
      icon: const Icon(Icons.search, size: 24),
      label: 'Browse',
      active: active == 1,
    ),
    BottomNavItem(
      icon: const Icon(Icons.area_chart, size: 24),
      label: 'Portfolio',
      active: active == 2,
    ),
    BottomNavItem(
      icon: const Icon(Icons.account_balance_wallet_outlined, size: 24),
      label: 'Wallet',
      active: active == 3,
    ),
    BottomNavItem(
      icon: const Icon(Icons.person_outline, size: 24),
      label: 'Profile',
      active: active == 4,
    ),
  ];
}

class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 360;
    final sy = size.height / 160;
    final path = Path()
      ..moveTo(0, 80 * sy)
      ..quadraticBezierTo(90 * sx, 40 * sy, 180 * sx, 80 * sy)
      ..quadraticBezierTo(270 * sx, 120 * sy, 360 * sx, 60 * sy)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.alpha(AppColors.teal, 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
