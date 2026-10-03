import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.filter = 'All'});

  final String filter;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _Txn {
  const _Txn({
    required this.type,
    required this.desc,
    required this.amount,
    required this.date,
    required this.method,
  });

  final String type;
  final String desc;
  final num amount;
  final String date;
  final String method;
}

const List<_Txn> _txns = [
  _Txn(
    type: 'credit',
    desc: 'Repayment from #A-2041',
    amount: 2840,
    date: '28 Sep',
    method: 'Portfolio',
  ),
  _Txn(
    type: 'debit',
    desc: 'Funded Loan #B-3217',
    amount: 10000,
    date: '27 Sep',
    method: 'Wallet',
  ),
  _Txn(
    type: 'credit',
    desc: 'eSewa Top-up',
    amount: 25000,
    date: '25 Sep',
    method: 'eSewa',
  ),
  _Txn(
    type: 'credit',
    desc: 'Repayment from #E-1892',
    amount: 1500,
    date: '22 Sep',
    method: 'Portfolio',
  ),
  _Txn(
    type: 'debit',
    desc: 'Withdrawal to Khalti',
    amount: 15000,
    date: '20 Sep',
    method: 'Khalti',
  ),
  _Txn(
    type: 'credit',
    desc: 'Repayment from #H-4501',
    amount: 4200,
    date: '18 Sep',
    method: 'Portfolio',
  ),
];

const List<String> _filters = ['All', 'Money In', 'Money Out'];

const List<({String name, String emoji, Color color, Color bg})> _methods = [
  (
    name: 'eSewa',
    emoji: '🟢',
    color: Color(0xFF059669),
    bg: Color(0xFFECFDF5),
  ),
  (
    name: 'Khalti',
    emoji: '🟣',
    color: Color(0xFF7C3AED),
    bg: Color(0xFFEDE9FE),
  ),
  (
    name: 'ConnectIPS',
    emoji: '🔵',
    color: Color(0xFF1D4ED8),
    bg: Color(0xFFEFF6FF),
  ),
  (name: 'Bank', emoji: '🏦', color: AppColors.navy, bg: AppColors.mint),
];

const List<String> _actions = ['Add Money', 'Withdraw', 'Transfer'];

List<BottomNavItem> _lenderNav(int active) {
  return [
    BottomNavItem(icon: const Icon(Icons.home), label: 'Home', active: active == 0),
    BottomNavItem(icon: const Icon(Icons.search), label: 'Browse', active: active == 1),
    BottomNavItem(icon: const Icon(Icons.show_chart), label: 'Portfolio', active: active == 2),
    BottomNavItem(icon: const Icon(Icons.account_balance_wallet), label: 'Wallet', active: active == 3),
    BottomNavItem(icon: const Icon(Icons.person_outline), label: 'Profile', active: active == 4),
  ];
}

class _WalletScreenState extends State<WalletScreen> {
  late String _activeFilter = widget.filter;

  @override
  Widget build(BuildContext context) {
    final filtered = _txns.where((t) {
      if (_activeFilter == 'Money In') return t.type == 'credit';
      if (_activeFilter == 'Money Out') return t.type == 'debit';
      return true;
    }).toList();

    return SystemChromeStyle(
      light: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _balanceHeader(context),
            _paymentMethods(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text('Transactions', style: AppText.h4),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          for (var i = 0; i < _filters.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            AppChip(
                              label: _filters[i],
                              active: _activeFilter == _filters[i],
                              onPressed: () =>
                                  setState(() => _activeFilter = _filters[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++)
                            _txnRow(filtered[i]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNav(
              items: _lenderNav(3),
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.navy,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.alpha(AppColors.teal, 0.08),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20 + top, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: Color(0x8CFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatNPR(48500),
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'NPR ४८,५०० · Updated just now',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: Color(0x8CFFFFFF),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (var i = 0; i < _actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? AppColors.teal
                                  : const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: i == 0
                                  ? null
                                  : Border.all(
                                      color: const Color(0x33FFFFFF),
                                    ),
                            ),
                            child: Text(
                              _actions[i],
                              style: const TextStyle(
                                fontFamily: kPoppins,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYMENT METHODS',
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _methods.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _methods[i].bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _methods[i].emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _methods[i].name,
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _methods[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _txnRow(_Txn t) {
    final credit = t.type == 'credit';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.transaction),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: credit ? AppColors.riskLowBg : AppColors.riskHighBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                credit ? '↓' : '↑',
                style: const TextStyle(fontSize: 18, color: AppColors.navy),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.desc,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    '${t.date} · ${t.method}',
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${credit ? '+' : '-'}${formatNPR(t.amount)}',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: credit ? AppColors.riskLow : AppColors.riskHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, Routes.lenderHome);
      case 1:
        Navigator.pushNamed(context, Routes.browseLoans);
      case 2:
        Navigator.pushNamed(context, Routes.portfolio);
      case 4:
        Navigator.pushNamed(context, Routes.profile);
    }
  }
}
