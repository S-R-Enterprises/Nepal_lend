import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _Notif {
  const _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final String time;
}

const List<_Notif> _notifs = <_Notif>[
  _Notif(
    id: 1,
    type: 'overdue',
    title: '⚠️ Payment Overdue',
    body:
        'Your October installment of NPR 7,401 is now 3 days overdue. Late fees are accumulating. Please pay immediately.',
    time: '2h ago',
  ),
  _Notif(
    id: 2,
    type: 'due_soon',
    title: '⏰ Payment Due Soon',
    body:
        'Your November installment of NPR 7,401 is due in 5 days on 15 Nov 2026. Make sure your eSewa wallet has sufficient balance.',
    time: '5h ago',
  ),
  _Notif(
    id: 3,
    type: 'funded',
    title: '🎉 Your Loan is Funded!',
    body:
        'Congratulations! Your Agriculture loan of NPR 80,000 has been fully funded by 26 lenders. Disbursement in 1–2 business days.',
    time: 'Yesterday',
  ),
  _Notif(
    id: 4,
    type: 'payment_received',
    title: '💰 Repayment Received',
    body:
        "You received NPR 2,840 from Borrower #A-2041 (Sep 2026 installment). It's been added to your wallet.",
    time: '2 days ago',
  ),
  _Notif(
    id: 5,
    type: 'paid_out',
    title: '✅ Loan Fully Repaid',
    body:
        "Borrower #M-0987's Medical loan has been fully repaid. Your NPR 3,000 principal + NPR 1,200 interest is in your wallet.",
    time: '1 week ago',
  ),
];

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _read = <int>{3, 4, 5};
  String _activeTab = 'All';

  void _markAllRead() {
    setState(() {
      _read
        ..clear()
        ..addAll(_notifs.map((n) => n.id));
    });
  }

  void _markRead(int id) {
    setState(() => _read.add(id));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  ({Color bg, Color border}) _colorsFor(String type) => switch (type) {
        'overdue' => (bg: const Color(0xFFFFF5F5), border: AppColors.riskHighBg),
        'due_soon' => (bg: const Color(0xFFFFFBEB), border: AppColors.riskMedBg),
        'funded' => (bg: const Color(0xFFF0FDF4), border: AppColors.riskLowBg),
        'payment_received' =>
          (bg: const Color(0xFFF0FDF4), border: AppColors.riskLowBg),
        'paid_out' => (bg: const Color(0xFFEFF6FF), border: const Color(0xFFBFDBFE)),
        _ => (bg: AppColors.white, border: AppColors.border),
      };

  @override
  Widget build(BuildContext context) {
    final int unreadCount = _notifs.where((n) => !_read.contains(n.id)).length;
    final List<_Notif> filtered = _activeTab == 'Unread'
        ? _notifs.where((n) => !_read.contains(n.id)).toList()
        : _notifs;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          UAppBar(
            title: 'Notifications',
            back: true,
            light: true,
            actions: [
              TextButton(
                onPressed: _markAllRead,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 48),
                  textStyle: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Mark all read'),
              ),
            ],
          ),
          _buildTabs(unreadCount),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final _Notif n in filtered) _buildItem(n)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          _TabBtn(
            label: 'All',
            active: _activeTab == 'All',
            onPressed: () => setState(() => _activeTab = 'All'),
          ),
          const SizedBox(width: 4),
          _TabBtn(
            label: 'Unread ($unreadCount)',
            active: _activeTab == 'Unread',
            onPressed: () => setState(() => _activeTab = 'Unread'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_Notif n) {
    final bool isRead = _read.contains(n.id);
    final ({Color bg, Color border}) colors = _colorsFor(n.type);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _markRead(n.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : colors.bg,
          border: Border(
            left: BorderSide(
              color: isRead ? AppColors.border : colors.border,
              width: 3,
            ),
            bottom: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    n.title,
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      color: AppColors.navy,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isRead) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      n.time,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 11,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              n.body,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.secondary,
                height: 1.6,
              ),
            ),
            if (n.type == 'overdue') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: AppBtn(
                  size: AppBtnSize.sm,
                  backgroundColor: AppColors.riskHigh,
                  onPressed: () => _showSnack('Opening repayment…'),
                  child: const Text('Pay Now →'),
                ),
              ),
            ],
            if (n.type == 'due_soon') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: AppBtn(
                  size: AppBtnSize.sm,
                  backgroundColor: AppColors.riskMed,
                  onPressed: () => _showSnack('Opening payment scheduler…'),
                  child: const Text('Schedule Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.navy : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.white : AppColors.secondary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
