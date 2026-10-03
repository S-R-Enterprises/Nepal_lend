import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

typedef _LoanRec = ({
  String purpose,
  String borrower,
  num amount,
  num rate,
  num tenor,
  String risk,
  num funded,
  num total,
});

const List<_LoanRec> _loans = [
  (
    purpose: 'Agriculture',
    borrower: 'Borrower #A-2041',
    amount: 80000,
    rate: 18,
    tenor: 12,
    risk: 'Low',
    funded: 56000,
    total: 80000,
  ),
  (
    purpose: 'Business',
    borrower: 'Borrower #B-3217',
    amount: 200000,
    rate: 22,
    tenor: 18,
    risk: 'Medium',
    funded: 80000,
    total: 200000,
  ),
  (
    purpose: 'Education',
    borrower: 'Borrower #E-1892',
    amount: 50000,
    rate: 16,
    tenor: 24,
    risk: 'Low',
    funded: 22000,
    total: 50000,
  ),
  (
    purpose: 'Medical',
    borrower: 'Borrower #M-0987',
    amount: 120000,
    rate: 20,
    tenor: 6,
    risk: 'Medium',
    funded: 60000,
    total: 120000,
  ),
  (
    purpose: 'Home',
    borrower: 'Borrower #H-4501',
    amount: 300000,
    rate: 24,
    tenor: 36,
    risk: 'High',
    funded: 100000,
    total: 300000,
  ),
];

class BrowseLoansScreen extends StatefulWidget {
  const BrowseLoansScreen({
    super.key,
    this.isLoading = false,
    this.isError = false,
  });

  final bool isLoading;
  final bool isError;

  @override
  State<BrowseLoansScreen> createState() => _BrowseLoansScreenState();
}

class _BrowseLoansScreenState extends State<BrowseLoansScreen> {
  String _risk = 'All';
  String _sort = 'Rate ↓';
  late bool _error = widget.isError;

  static const _riskFilters = ['All', 'Low', 'Medium', 'High'];
  static const _sorts = ['Rate ↓', 'Amount', 'Tenor'];

  void _onNavTap(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.lenderHome,
        (route) => false,
      );
      return;
    }
    const targets = <String?>[null, null, Routes.portfolio, Routes.wallet, Routes.profile];
    final target = targets[index];
    if (target != null) Navigator.pushNamed(context, target);
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _risk == 'All' ? _loans : _loans.where((l) => l.risk == _risk).toList();

    return SystemChromeStyle(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: const UAppBar(title: 'Browse Loans'),
              ),
            ),
            _buildFilters(filtered.length),
            Expanded(child: _buildBody(filtered)),
            BottomNav(items: _lenderNav(1), onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(int count) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                for (var i = 0; i < _riskFilters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  AppChip(
                    label: _riskFilters[i] == 'All'
                        ? 'All Loans'
                        : '${_riskFilters[i]} Risk',
                    active: _risk == _riskFilters[i],
                    onPressed: () => setState(() => _risk = _riskFilters[i]),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                const Text(
                  'Sort:',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                for (var i = 0; i < _sorts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _sortButton(_sorts[i]),
                ],
                const Spacer(),
                Text(
                  '$count loans',
                  style: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortButton(String label) {
    final active = _sort == label;
    return GestureDetector(
      onTap: () => setState(() => _sort = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kInter,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.white : AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<_LoanRec> filtered) {
    if (widget.isLoading) return const LoadingState();
    if (_error) {
      return ErrorState(
        onRetry: () => setState(() => _error = false),
      );
    }
    if (filtered.isEmpty) {
      return const EmptyState(
        icon: '🔍',
        title: 'No loans found',
        desc: 'Try changing your filters to see more opportunities.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (final l in filtered)
            LoanCard(
              purpose: l.purpose,
              borrower: l.borrower,
              amount: l.amount,
              rate: l.rate,
              tenor: l.tenor,
              risk: l.risk,
              funded: l.funded,
              total: l.total,
              onTap: () => Navigator.pushNamed(context, Routes.loanDetails),
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
