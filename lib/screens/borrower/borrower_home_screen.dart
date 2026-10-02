import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class BorrowerHomeScreen extends StatefulWidget {
  const BorrowerHomeScreen({super.key});

  @override
  State<BorrowerHomeScreen> createState() => _BorrowerHomeScreenState();
}

class _BorrowerHomeScreenState extends State<BorrowerHomeScreen> {
  int _tab = 0;

  static const List<(String, int, String)> _history = [
    ('Personal Loan', 50000, 'Jun 2026'),
    ('Medical Loan', 30000, 'Jan 2026'),
  ];

  void _onNavTap(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, Routes.profile);
      return;
    }
    if (index != _tab) {
      setState(() => _tab = index);
    }
  }

  void _openRepay() => Navigator.pushNamed(context, Routes.repay);

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _homeTab(),
                  Container(
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const EmptyState(
                      icon: '📄',
                      title: 'My Loans',
                      desc: 'Your active and past loan applications will appear here.',
                    ),
                  ),
                  Container(
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const EmptyState(
                      icon: '👛',
                      title: 'Wallet',
                      desc: 'Your wallet balance and transactions will appear here.',
                    ),
                  ),
                ],
              ),
            ),
            BottomNav(
              onTap: _onNavTap,
              items: [
                BottomNavItem(
                  icon: Icon(_tab == 0 ? Icons.home : Icons.home_outlined, size: 24),
                  label: 'Home',
                  active: _tab == 0,
                ),
                BottomNavItem(
                  icon: Icon(
                    _tab == 1 ? Icons.description : Icons.description_outlined,
                    size: 24,
                  ),
                  label: 'My Loans',
                  active: _tab == 1,
                ),
                BottomNavItem(
                  icon: Icon(
                    _tab == 2
                        ? Icons.account_balance_wallet
                        : Icons.account_balance_wallet_outlined,
                    size: 24,
                  ),
                  label: 'Wallet',
                  active: _tab == 2,
                ),
                const BottomNavItem(
                  icon: Icon(Icons.person_outlined, size: 24),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeTab() {
    return Column(
      children: [
        _header(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Active Loan'),
                _activeLoanCard(),
                _requestBanner(),
                const SectionHeader(title: 'Loan History'),
                for (final (desc, amount, date) in _history)
                  _historyRow(desc, amount, date),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(color: AppColors.navy),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.alpha(AppColors.teal, 0.1),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 13,
                            color: AppColors.alpha(Colors.white, 0.55),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Bikash Tamang',
                            style: TextStyle(
                              fontFamily: kPoppins,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.riskLowBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'KYC',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.riskLow,
                            ),
                          ),
                          Text(
                            'Approved ✓',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.riskLow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alpha(Colors.white, 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.alpha(Colors.white, 0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Credit Limit',
                                style: TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 12,
                                  color: AppColors.alpha(Colors.white, 0.55),
                                ),
                              ),
                              Text(
                                formatNPR(200000),
                                style: const TextStyle(
                                  fontFamily: kPoppins,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const GradeBadge(grade: 'B+'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Used',
                                style: TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 12,
                                  color: AppColors.alpha(Colors.white, 0.55),
                                ),
                              ),
                              Text(
                                '${formatNPR(120000)} available',
                                style: const TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const ProgressBar(
                            value: 80000,
                            max: 200000,
                            height: 8,
                          ),
                        ],
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

  Widget _activeLoanCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 20),
      borderColor: AppColors.teal,
      onTap: _openRepay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Business Loan',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    'Loan #NL-BL-20260918',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const StatusPill(status: 'Active'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _kv('Principal', formatNPR(80000), AppColors.navy),
              const SizedBox(width: 16),
              _kv('Rate', '20% p.a.', AppColors.teal),
              const SizedBox(width: 16),
              _kv('Tenor', '12 mo.', AppColors.navy),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Next Payment Due',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '15 Oct 2026',
                      style: TextStyle(
                        fontFamily: kPoppins,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.riskHigh,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      'In 16 days',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      formatNPR(7667),
                      style: const TextStyle(
                        fontFamily: kPoppins,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppBtn(
            fullWidth: true,
            onPressed: _openRepay,
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 11,
            color: AppColors.secondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: kPoppins,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _requestBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12284C), Color(0xFF1A3D70)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.alpha(AppColors.teal, 0.15),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need more funds?',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Apply for another loan up to ${formatNPR(120000)}.  '
                  'Fast approval, fair rates.',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: AppColors.alpha(Colors.white, 0.65),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                AppBtn(
                  size: AppBtnSize.sm,
                  backgroundColor: AppColors.teal,
                  textColor: Colors.white,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.requestLoan),
                  child: const Text('Request a Loan →'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(String desc, int amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.riskLowBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('✅', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                    height: 1.35,
                  ),
                ),
                Text(
                  date,
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
                formatNPR(amount),
                style: const TextStyle(
                  fontFamily: kPoppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  height: 1.35,
                ),
              ),
              const StatusPill(status: 'Repaid'),
            ],
          ),
        ],
      ),
    );
  }
}
