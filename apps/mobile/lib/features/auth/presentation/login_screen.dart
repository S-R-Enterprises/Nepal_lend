import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../data/auth_repository.dart'
    show AuthException, authRepositoryProvider;
import '../../../shared/widgets/ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _phone = '';
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    final phone = _phone.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^9\d{9}$').hasMatch(phone)) {
      setState(() => _error = 'Enter a valid 10-digit number starting with 9');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final challenge =
          await ref.read(authRepositoryProvider).requestOtp(phone);
      if (!mounted) return;
      final dev = challenge.devCode;
      context.push(
        '${Routes.otp}?requestId=${Uri.encodeQueryComponent(challenge.requestId)}'
        '&phone=${Uri.encodeQueryComponent(challenge.maskedPhone)}'
        '${dev == null ? '' : '&devCode=${Uri.encodeQueryComponent(dev)}'}',
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppInput(
                      label: 'Mobile Number',
                      placeholder: '98XXXXXXXX',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => setState(() => _phone = v),
                      prefix: const Text(
                        '🇳🇵 +977',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _OtpHint(),
                    _orDivider(),
                    const SizedBox(height: 20),
                    _biometric(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  AppBtn(
                    fullWidth: true,
                    disabled: _phone.length < 10 || _loading,
                    onPressed: _sendOtp,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () =>
                        context.push(Routes.registration),
                    child: const Text.rich(
                      TextSpan(
                        text: 'New to NepalLend? ',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Create Account',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
          const Positioned.fill(child: DhakaPattern(opacity: 0.1)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              40 + MediaQuery.of(context).padding.top,
              20,
              48,
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1AA6A6), Color(0xFF0D7A7A)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'NL',
                    style: TextStyle(
                      fontFamily: kPoppins,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'स्वागत छ!',
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    color: Color(0x8CFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: AppColors.border),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'or use',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _biometric() {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null, // Device biometrics arrive after the OTP session exists.
        child: const SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('👆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 10),
              Text(
                'Fingerprint / Face ID',
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpHint extends StatelessWidget {
  const _OtpHint();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'We\'ll text you a one-time code — no password or PIN needed.',
      style: TextStyle(
        fontFamily: kInter,
        fontSize: 13,
        color: AppColors.secondary,
        height: 1.5,
      ),
    );
  }
}
