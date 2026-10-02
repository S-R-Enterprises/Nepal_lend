import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class RepayScreen extends StatefulWidget {
  const RepayScreen({super.key, this.success = false});

  final bool success;

  @override
  State<RepayScreen> createState() => _RepayScreenState();
}

class _RepayScreenState extends State<RepayScreen> {
  static const int _emi = 7401;

  static const List<(String, String, String)> _methods = [
    ('eSewa', '🟢', 'NPR 12,500'),
    ('Khalti', '🟣', 'NPR 8,000'),
    ('ConnectIPS', '🔵', 'Bank transfer'),
    ('Bank', '🏦', 'Savings Account'),
  ];

  static const List<(String, int, String, String?)> _schedule = [
    ('Aug 2026', 7401, 'paid', null),
    ('Sep 2026', 7401, 'paid', null),
    ('Oct 2026', 7401, 'due', '15 Oct 2026'),
    ('Nov 2026', 7401, 'upcoming', null),
    ('Dec 2026', 7401, 'upcoming', null),
  ];

  String _method = 'eSewa';
  late bool _paid;

  @override
  void initState() {
    super.initState();
    _paid = widget.success;
  }

  void _done() => Navigator.pushReplacementNamed(context, Routes.borrowerHome);

  Color _dotColor(String status) => switch (status) {
        'paid' => AppColors.riskLow,
        'due' => AppColors.riskMed,
        _ => AppColors.border,
      };

  Color _amountColor(String status) => switch (status) {
        'paid' => AppColors.riskLow,
        'due' => AppColors.riskMed,
        _ => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paid ? AppColors.white : AppColors.surface,
      body: Column(
        children: [
          UAppBar(
            title: _paid ? 'Payment' : 'Repay Loan',
            back: true,
            light: true,
          ),
          Expanded(child: _paid ? _successView() : _repayView()),
        ],
      ),
    );
  }

  Widget _successView() {
    final rows = <(String, String, bool)>[
      ('Transaction ID', 'TXN-20261015-882', true),
      ('Paid via', _method, false),
      ('Date & Time', '15 Oct 2026, 10:22 AM', false),
      ('Next due', '15 Nov 2026 — NPR 7,401', false),
      ('Remaining balance', formatNPR(72599), false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.riskLowBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alpha(AppColors.riskLow, 0.2),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text('✅', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatNPR(_emi),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.riskLow,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'EMI paid for October 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (final row in rows)
                        _successRow(row.$1, row.$2, mono: row.$3),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppBtn(
                        fullWidth: true,
                        variant: AppBtnVariant.secondary,
                        onPressed: () {},
                        child: const Text('Download Receipt'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppBtn(
                        fullWidth: true,
                        onPressed: _done,
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _successRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: kInter,
              fontSize: 12,
              color: AppColors.secondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: mono ? 'monospace' : kInter,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _repayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dueNowCard(),
          _payViaCard(),
          _scheduleCard(),
          AppBtn(
            fullWidth: true,
            size: AppBtnSize.lg,
            onPressed: () => setState(() => _paid = true),
            child: Text('Pay ${formatNPR(_emi)} via $_method'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _dueNowCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -20,
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
                Text(
                  'Due Now · October 2026',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: AppColors.alpha(Colors.white, 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatNPR(_emi),
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _dueStat('Principal', formatNPR(5934), Colors.white),
                    const SizedBox(width: 16),
                    _dueStat('Interest', formatNPR(1333), AppColors.teal),
                    const SizedBox(width: 16),
                    _dueStat('Late fee', formatNPR(134), Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dueStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kInter,
            fontSize: 11,
            color: AppColors.alpha(Colors.white, 0.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: kPoppins,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _payViaCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Pay Via',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          for (final (id, emoji, balance) in _methods)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _method = id),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                              fontFamily: kPoppins,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                              height: 1.35,
                            ),
                          ),
                          Text(
                            balance,
                            style: const TextStyle(
                              fontFamily: kInter,
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _method == id
                            ? AppColors.teal
                            : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _method == id ? AppColors.teal : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: _method == id
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Repayment Schedule',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          for (final (month, amount, status, dueDate) in _schedule)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _dotColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 14,
                            fontWeight: status == 'due'
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppColors.navy,
                          ),
                        ),
                        if (dueDate != null)
                          Text(
                            'Due $dueDate',
                            style: const TextStyle(
                              fontFamily: kInter,
                              fontSize: 11,
                              color: AppColors.riskMed,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatNPR(amount),
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _amountColor(status),
                    ),
                  ),
                  if (status == 'paid')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 14,
                          color: AppColors.riskLow,
                        ),
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
