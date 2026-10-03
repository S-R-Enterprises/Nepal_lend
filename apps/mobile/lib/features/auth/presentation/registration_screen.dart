import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../data/auth_repository.dart' show AuthException, authRepositoryProvider;
import '../../../shared/widgets/ui.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your mobile number to get started. We\'ll send a one-time code to verify.',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 14,
                        color: AppColors.secondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppInput(
                      label: 'Mobile Number',
                      placeholder: '98XXXXXXXX',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => setState(() => _phone = v),
                      prefix: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇳🇵', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            '+977',
                            style: TextStyle(
                              fontFamily: kInter,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(width: 6),
                          SizedBox(
                            width: 1,
                            height: 20,
                            child: ColoredBox(color: AppColors.border),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _terms(),
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        context.push(Routes.login),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already registered? ',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
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
                  'Create Account',
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
                    'खाता सिर्जना गर्नुहोस्',
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

  Widget _terms() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: kInter,
            fontSize: 12,
            color: AppColors.secondary,
            height: 1.6,
          ),
          children: [
            TextSpan(text: '📱 By continuing, you agree to NepalLend\'s '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                height: 1.6,
                color: AppColors.teal,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                height: 1.6,
                color: AppColors.teal,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
