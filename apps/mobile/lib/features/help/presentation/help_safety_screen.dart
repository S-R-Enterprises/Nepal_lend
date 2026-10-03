import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class HelpSafetyScreen extends StatefulWidget {
  const HelpSafetyScreen({super.key});

  @override
  State<HelpSafetyScreen> createState() => _HelpSafetyScreenState();
}

const List<({String icon, String label, String value, String sub})>
    _contacts = <({String icon, String label, String value, String sub})>[
  (
    icon: '📞',
    label: 'Phone Support',
    value: '+977 01-4XXXXXX',
    sub: 'Mon–Fri, 9am–6pm',
  ),
  (
    icon: '✉️',
    label: 'Email',
    value: 'support@nepallend.com.np',
    sub: 'Reply within 24h',
  ),
  (
    icon: '🌐',
    label: 'Web Portal',
    value: 'help.nepallend.com.np',
    sub: 'Self-service',
  ),
];

const List<String> _tips = <String>[
  '📊 Diversify across 5–10 loans to spread risk',
  '🔒 Never share your PIN or OTP with anyone',
  '✅ Only lend what you can afford to lose',
  '📞 NepalLend will never call asking for your password',
  '⚠️ Verify loan details before funding',
];

const List<({String q, String a})> _faqs = <({String q, String a})>[
  (
    q: 'How is my money protected?',
    a: 'Your funds are held in a regulated escrow account. NepalLend complies with NRB guidelines. In case of borrower default, our recovery team initiates legal proceedings.',
  ),
  (
    q: 'What happens if a borrower defaults?',
    a: 'Our collections team contacts the borrower. Legal action may be initiated. You may recover a portion or all of your funds depending on the case.',
  ),
  (
    q: 'How do I withdraw my money?',
    a: 'Go to Wallet → Withdraw. Funds from repayments land in your wallet instantly. Withdrawals to eSewa/Khalti take minutes; bank transfers 1–2 business days.',
  ),
  (
    q: 'How are interest rates set?',
    a: 'Rates are set by our risk algorithm based on borrower grade. Low risk loans earn 14–18% p.a., Medium 18–22%, High 22–26%.',
  ),
  (
    q: 'Is NepalLend NRB regulated?',
    a: "Yes. NepalLend operates under Nepal Rastra Bank's Digital Financial Services licensing framework. Company Reg. No.: 204567/077/78.",
  ),
];

class _HelpSafetyScreenState extends State<HelpSafetyScreen> {
  int? _openFaq = 0;

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
          const UAppBar(title: 'Help & Safety', back: true, light: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChatCard(),
                  _buildContactCard(),
                  _buildSafetyTipsCard(),
                  _buildFaqCard(),
                  _buildEmergency(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard() {
    return SettingsCard(
      title: '',
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('💬', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat Support',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                      height: 1.35,
                    ),
                  ),
                  Text(
                    'Available 7am–9pm, 7 days',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppBtn(
              size: AppBtnSize.sm,
              backgroundColor: AppColors.teal,
              onPressed: () => _showSnack('Chat support is on the way'),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return SettingsCard(
      title: 'Contact Us',
      child: Column(
        children: [
          for (int i = 0; i < _contacts.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i < _contacts.length - 1
                    ? const Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contacts[i].icon,
                    style: const TextStyle(fontSize: 22, height: 1.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _contacts[i].label,
                          style: const TextStyle(
                            fontFamily: kInter,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.navy,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          _contacts[i].value,
                          style: const TextStyle(
                            fontFamily: kInter,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          _contacts[i].sub,
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
            ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsCard() {
    return SettingsCard(
      title: 'Safety Tips for P2P Lending',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final String tip in _tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  tip,
                  style: const TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: AppColors.navy,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard() {
    return SettingsCard(
      title: 'Frequently Asked Questions',
      child: Column(
        children: [
          for (int i = 0; i < _faqs.length; i++)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _openFaq = _openFaq == i ? null : i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _faqs[i].q,
                              style: const TextStyle(
                                fontFamily: kInter,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.navy,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedRotation(
                            turns: _openFaq == i ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_openFaq == i)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        _faqs[i].a,
                        style: const TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: AppColors.secondary,
                          height: 1.7,
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

  Widget _buildEmergency() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riskHighBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚨', style: TextStyle(fontSize: 24, height: 1.2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Report Fraud',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.riskHigh,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'If you suspect fraudulent activity on your account, contact us immediately or call NRB complaint line.',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: Color(0xFF7F1D1D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppBtn(
                    size: AppBtnSize.sm,
                    backgroundColor: AppColors.riskHigh,
                    onPressed: () => _showSnack('Fraud report form coming soon'),
                    child: const Text('Report Now'),
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
