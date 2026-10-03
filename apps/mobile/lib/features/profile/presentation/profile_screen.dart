import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

const Map<String, String> _en = <String, String>{
  'title': 'Profile',
  'kycStatus': 'KYC Status',
  'language': 'Language',
  'security': 'Security',
  'pin': 'Change PIN',
  'bio': 'Biometric Login',
  'notifs': 'Push Notifications',
  'help': 'Help & Support',
  'logout': 'Log Out',
  'deleteAccount': 'Delete Account',
};

const Map<String, String> _np = <String, String>{
  'title': 'प्रोफाइल',
  'kycStatus': 'KYC स्थिति',
  'language': 'भाषा',
  'security': 'सुरक्षा',
  'pin': 'PIN परिवर्तन',
  'bio': 'बायोमेट्रिक लगइन',
  'notifs': 'सूचनाहरू',
  'help': 'सहायता',
  'logout': 'लगआउट',
  'deleteAccount': 'खाता मेट्नुहोस्',
};

const List<({String icon, String label, String status})> _kycItems =
    <({String icon, String label, String status})>[
  (icon: '🪪', label: 'National ID', status: 'Approved'),
  (icon: '🤳', label: 'Selfie', status: 'Approved'),
  (icon: '🏠', label: 'Address', status: 'In review'),
  (icon: '🏦', label: 'Bank / Wallet', status: 'Not started'),
];

const List<({String icon, String label})> _otherItems =
    <({String icon, String label})>[
  (icon: '❓', label: 'help'),
  (icon: '📄', label: 'Terms & Privacy'),
  (icon: '⭐', label: 'Rate NepalLend'),
  (icon: '📢', label: 'Share with Friends'),
];

class _ProfileScreenState extends State<ProfileScreen> {
  String _lang = 'en';
  bool _biometric = true;
  bool _notifications = true;

  Map<String, String> get _t => _lang == 'en' ? _en : _np;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          UAppBar(title: _t['title']!, back: true, light: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      color: AppColors.navy,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'PS',
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priya Shrestha',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+977 9812345678',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: AppColors.alpha(Colors.white, 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                const StatusPill(status: 'Approved'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKycCard(),
          const SizedBox(height: 16),
          _buildLanguageCard(),
          const SizedBox(height: 16),
          _buildSecurityCard(),
          const SizedBox(height: 16),
          _buildOtherCard(),
          const SizedBox(height: 16),
          const Text(
            'NepalLend v2.4.1 · Regulated by NRB',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 12,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          AppBtn(
            variant: AppBtnVariant.secondary,
            fullWidth: true,
            borderColor: AppColors.riskHigh,
            textColor: AppColors.riskHigh,
            onPressed: () => context.go(Routes.login),
            child: Text(_t['logout']!),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => _showSnack('Account deletion flow coming soon'),
              child: Text(
                _t['deleteAccount']!,
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  color: AppColors.riskHigh,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard() {
    return SettingsCard(
      title: _t['kycStatus']!,
      child: Column(
        children: [
          for (int i = 0; i < _kycItems.length; i++)
            _row(
              icon: _kycItems[i].icon,
              label: _kycItems[i].label,
              iconSize: 20,
              gap: 12,
              paddingV: 10,
              divider: i < _kycItems.length - 1,
              trailing: StatusPill(status: _kycItems[i].status),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return SettingsCard(
      title: _t['language']!,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'App Language',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 14,
                color: AppColors.navy,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LangBtn(
                    label: 'EN',
                    active: _lang == 'en',
                    onPressed: () => setState(() => _lang = 'en'),
                  ),
                  const SizedBox(width: 2),
                  _LangBtn(
                    label: 'नेपाली',
                    active: _lang == 'np',
                    onPressed: () => setState(() => _lang = 'np'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return SettingsCard(
      title: _t['security']!,
      child: Column(
        children: [
          _row(
            icon: '🔑',
            iconSize: 16,
            gap: 10,
            label: _t['pin']!,
            divider: true,
            onTap: () => _showSnack('PIN change flow coming soon'),
          ),
          _row(
            icon: '👆',
            iconSize: 16,
            gap: 10,
            label: _t['bio']!,
            divider: true,
            trailing: AppToggle(
              value: _biometric,
              onChanged: (v) => setState(() => _biometric = v),
            ),
          ),
          _row(
            icon: '🔔',
            iconSize: 16,
            gap: 10,
            label: _t['notifs']!,
            trailing: AppToggle(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherCard() {
    return SettingsCard(
      title: '',
      child: Column(
        children: [
          for (int i = 0; i < _otherItems.length; i++)
            _row(
              icon: _otherItems[i].icon,
              label: _otherItems[i].label == 'help'
                  ? _t['help']!
                  : _otherItems[i].label,
              iconSize: 20,
              divider: i < _otherItems.length - 1,
              onTap: _otherItems[i].label == 'help'
                  ? () => context.push(Routes.help)
                  : () => _showSnack('${_otherItems[i].label} coming soon'),
            ),
        ],
      ),
    );
  }

  Widget _row({
    required String icon,
    required String label,
    double iconSize = 20,
    double gap = 12,
    double paddingV = 14,
    bool divider = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final Widget content = Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingV),
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: iconSize, height: 1.2)),
          SizedBox(width: gap),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 14,
                color: AppColors.navy,
                height: 1.4,
              ),
            ),
          ),
          trailing ??
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.secondary,
              ),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}

class _LangBtn extends StatelessWidget {
  const _LangBtn({
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
      color: active ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.secondary,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
