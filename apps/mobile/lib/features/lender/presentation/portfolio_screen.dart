import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _Stake {
  const _Stake({
    required this.purpose,
    required this.borrower,
    required this.amount,
    required this.outstanding,
    required this.rate,
    required this.status,
    required this.risk,
  });

  final String purpose;
  final String borrower;
  final num amount;
  final num outstanding;
  final num rate;
  final String status;
  final String risk;
}

const List<_Stake> _stakes = [
  _Stake(
    purpose: 'Agriculture',
    borrower: 'Borrower #A-2041',
    amount: 5000,
    outstanding: 3200,
    rate: 18,
    status: 'On track',
    risk: 'Low',
  ),
  _Stake(
    purpose: 'Education',
    borrower: 'Borrower #E-1892',
    amount: 8000,
    outstanding: 6400,
    rate: 16,
    status: 'On track',
    risk: 'Low',
  ),
  _Stake(
    purpose: 'Business',
    borrower: 'Borrower #B-3217',
    amount: 10000,
    outstanding: 10000,
    rate: 22,
    status: 'Late',
    risk: 'Medium',
  ),
  _Stake(
    purpose: 'Medical',
    borrower: 'Borrower #M-0987',
    amount: 3000,
    outstanding: 0,
    rate: 20,
    status: 'Repaid',
    risk: 'Medium',
  ),
  _Stake(
    purpose: 'Home',
    borrower: 'Borrower #H-4501',
    amount: 15000,
    outstanding: 12000,
    rate: 24,
    status: 'On track',
    risk: 'High',
  ),
];

List<BottomNavItem> _lenderNav(int active) {
  return [
    BottomNavItem(icon: const Icon(Icons.home), label: 'Home', active: active == 0),
    BottomNavItem(icon: const Icon(Icons.search), label: 'Browse', active: active == 1),
    BottomNavItem(icon: const Icon(Icons.show_chart), label: 'Portfolio', active: active == 2),
    BottomNavItem(icon: const Icon(Icons.account_balance_wallet), label: 'Wallet', active: active == 3),
    BottomNavItem(icon: const Icon(Icons.person_outline), label: 'Profile', active: active == 4),
  ];
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _activeTab = 'Active';

  @override
  Widget build(BuildContext context) {
    final activeStakes = _stakes.where((s) => s.status != 'Repaid').toList();
    final closedStakes = _stakes.where((s) => s.status == 'Repaid').toList();
    final shown = _activeTab == 'Active' ? activeStakes : closedStakes;
    final totalLent = _stakes.fold<num>(0, (a, s) => a + s.amount);
    final totalOutstanding = _stakes.fold<num>(0, (a, s) => a + s.outstanding);
    const interestReceived = 18640;

    final summary = <({String label, String value})>[
      (label: 'Total Lent', value: formatNPR(totalLent)),
      (label: 'Interest Rec.', value: formatNPR(interestReceived)),
      (label: 'Outstanding', value: formatNPR(totalOutstanding)),
    ];

    final riskDist = <({String label, int pct, Color color})>[
      (label: 'Low', pct: 41, color: AppColors.riskLow),
      (label: 'Medium', pct: 37, color: AppColors.riskMed),
      (label: 'High', pct: 22, color: AppColors.riskHigh),
    ];

    final tabLabels = [
      'Active (${activeStakes.length})',
      'Closed (${closedStakes.length})',
    ];

    return SystemChromeStyle(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: AppColors.white,
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: const UAppBar(title: 'My Portfolio'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: AppColors.navy,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Row(
                        children: [
                          for (var i = 0; i < summary.length; i++)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                decoration: i < 2
                                    ? const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0x1FFFFFFF),
                                          ),
                                        ),
                                      )
                                    : null,
                                child: Column(
                                  children: [
                                    Text(
                                      summary[i].label,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: kInter,
                                        fontSize: 11,
                                        color: Color(0x80FFFFFF),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      summary[i].value,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: kPoppins,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Risk Distribution', style: AppText.h4),
                                const SizedBox(height: 14),
                                for (var i = 0; i < riskDist.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${riskDist[i].label} Risk',
                                            style: AppText.caption,
                                          ),
                                          Text(
                                            '${riskDist[i].pct}%',
                                            style: AppText.caption.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: riskDist[i].color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ProgressBar(
                                        value: riskDist[i].pct.toDouble(),
                                        color: riskDist[i].color,
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < tabLabels.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 4),
                                  Expanded(
                                    child: _tabButton(
                                      tabLabels[i],
                                      _activeTab ==
                                          (i == 0 ? 'Active' : 'Closed'),
                                      () => setState(() {
                                        _activeTab = i == 0 ? 'Active' : 'Closed';
                                      }),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (shown.isEmpty)
                            const EmptyState(
                              icon: '📋',
                              title: 'No closed loans',
                              desc: 'Repaid loans will appear here.',
                            )
                          else
                            for (var i = 0; i < shown.length; i++) ...[
                              if (i > 0) const SizedBox(height: 16),
                              _stakeCard(shown[i]),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNav(
              items: _lenderNav(2),
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kPoppins,
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.navy : AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _stakeCard(_Stake s) {
    return AppCard(
      onTap: () => Navigator.pushNamed(context, Routes.loanStake),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              purposeIcons[s.purpose] ?? '🏠',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        s.purpose,
                        style: AppText.h4.copyWith(fontSize: 14),
                      ),
                    ),
                    StatusPill(status: s.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${s.borrower} · ${s.rate}% p.a.',
                  style: AppText.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your stake',
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 11,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          formatNPR(s.amount),
                          style: const TextStyle(
                            fontFamily: kPoppins,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                    if (s.outstanding > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Outstanding',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            formatNPR(s.outstanding),
                            style: TextStyle(
                              fontFamily: kPoppins,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: s.status == 'Late'
                                  ? AppColors.riskHigh
                                  : AppColors.navy,
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.riskLowBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Fully Repaid ✓',
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.riskLow,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, Routes.lenderHome);
      case 1:
        Navigator.pushNamed(context, Routes.browseLoans);
      case 3:
        Navigator.pushNamed(context, Routes.wallet);
      case 4:
        Navigator.pushNamed(context, Routes.profile);
    }
  }
}
