import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  void _signIn() {
    Navigator.of(context).pushReplacementNamed(
      Session.role == UserRole.lender ? Routes.lenderHome : Routes.borrowerHome,
    );
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
                    AppInput(
                      label: 'PIN',
                      placeholder: 'Enter 4-digit PIN',
                      keyboardType: TextInputType.number,
                      obscureText: _obscure,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                  AppBtn(
                    fullWidth: true,
                    onPressed: _signIn,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.registration),
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
        onTap: _signIn,
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
