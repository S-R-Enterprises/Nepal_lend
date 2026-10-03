import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go(Routes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: false,
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: Stack(
          children: [
            const Positioned.fill(child: DhakaPattern(opacity: 0.14)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1AA6A6), Color(0xFF0D7A7A)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alpha(const Color(0xFF1AA6A6), 0.4),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text(
                      'NL',
                      style: TextStyle(
                        fontFamily: kPoppins,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Text(
                        'NepalLend',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kPoppins,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: AppColors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'नेपाललेन्ड',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 14,
                            color: Color(0xA6FFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 48,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Column(
                    children: [
                      Text(
                        'Lend and borrow, directly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xD9FFFFFF),
                        ),
                      ),
                      Text(
                        'उधारो र ऋण, सिधै।',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SplashDot(width: 24, active: true),
                  SizedBox(width: 8),
                  _SplashDot(width: 8, active: false),
                  SizedBox(width: 8),
                  _SplashDot(width: 8, active: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashDot extends StatelessWidget {
  const _SplashDot({required this.width, required this.active});

  final double width;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.teal : AppColors.alpha(AppColors.white, 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
