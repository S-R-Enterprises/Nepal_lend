import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

const List<String> _keys = [
  '1', '2', '3',
  '4', '5', '6',
  '7', '8', '9',
  '*', '0', '⌫',
];

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String _otp = '4821';
  int _timer = 23;

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_otp.isNotEmpty) _otp = _otp.substring(0, _otp.length - 1);
      } else if (_otp.length < 6) {
        _otp = '$_otp$k';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  children: [
                    const Text.rich(
                      TextSpan(
                        text: 'We sent a 6-digit code to\n',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 15,
                          color: AppColors.secondary,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text: '+977 9812345678',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    OTPInput(value: _otp),
                    const SizedBox(height: 28),
                    _resend(),
                    const SizedBox(height: 28),
                    _keypad(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AppBtn(
                fullWidth: true,
                disabled: _otp.length < 6,
                onPressed: () => Navigator.of(context).pushNamed(Routes.kyc),
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(
        children: [
          const Positioned.fill(child: DhakaPattern(opacity: 0.08)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              28 + MediaQuery.of(context).padding.top,
              20,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify Number',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'नम्बर प्रमाणित गर्नुहोस्',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      color: Color(0x99FFFFFF),
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

  Widget _resend() {
    if (_timer > 0) {
      final t = _timer < 10 ? '0$_timer' : '$_timer';
      return Text.rich(
        TextSpan(
          text: 'Resend code in ',
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 13,
            color: AppColors.secondary,
          ),
          children: [
            TextSpan(
              text: '00:${t}s',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _timer = 30),
      child: const Text(
        'Resend OTP',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kInter,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _keypad() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 4; r++) ...[
            if (r > 0) const SizedBox(height: 2),
            Row(
              children: [
                for (var c = 0; c < 3; c++) ...[
                  if (c > 0) const SizedBox(width: 2),
                  Expanded(child: _key(_keys[r * 3 + c])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _key(String k) {
    final backspace = k == '⌫';
    return Material(
      color: backspace ? AppColors.mint : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onKey(k),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              k,
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: backspace ? 18 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
