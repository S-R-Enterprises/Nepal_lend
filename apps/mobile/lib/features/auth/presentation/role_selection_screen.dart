import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/auth_controller.dart';
import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class _RoleOption {
  const _RoleOption({
    required this.id,
    required this.emoji,
    required this.title,
    required this.titleNp,
    required this.desc,
    required this.features,
  });

  final String id;
  final String emoji;
  final String title;
  final String titleNp;
  final String desc;
  final List<String> features;
}

const List<_RoleOption> _roles = [
  _RoleOption(
    id: 'lender',
    emoji: '💰',
    title: 'I want to Lend',
    titleNp: 'म लगानी गर्न चाहन्छु',
    desc: 'Earn up to 22% annual returns by funding verified borrowers.',
    features: ['₹ Earn high returns', '📊 Risk-graded loans', '🔒 Secure platform'],
  ),
  _RoleOption(
    id: 'borrower',
    emoji: '📋',
    title: 'I need a Loan',
    titleNp: 'मलाई ऋण चाहिन्छ',
    desc: 'Get quick funding from real people at fair rates.',
    features: ['⚡ Fast approval', '💸 Fair interest rates', '📱 Digital process'],
  ),
];

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selected;

  void _continue() {
    final id = _selected;
    if (id == null) return;
    ref.read(authControllerProvider.notifier).setRole(
          id == 'lender' ? UserRole.lender : UserRole.borrower,
        );
    context.push(Routes.registration);
  }

  @override
  Widget build(BuildContext context) {
    return SystemChromeStyle(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  children: [
                    _roleCard(_roles[0]),
                    const SizedBox(height: 16),
                    _roleCard(_roles[1]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  AppBtn(
                    fullWidth: true,
                    disabled: _selected == null,
                    onPressed: _continue,
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        context.push(Routes.login),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log in',
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
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEPALEND',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.teal,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'How will you\nuse NepalLend?',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.white,
                    height: 1.25,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'तपाईं कसरी प्रयोग गर्नुहुन्छ?',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      color: Color(0x8CFFFFFF),
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

  Widget _roleCard(_RoleOption role) {
    final active = _selected == role.id;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = role.id);
        ref.read(authControllerProvider.notifier).setRole(
              role.id == 'lender' ? UserRole.lender : UserRole.borrower,
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? AppColors.mint : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.teal : AppColors.border,
            width: 2,
          ),
          boxShadow: [
            active
                ? BoxShadow(
                    color: AppColors.alpha(AppColors.teal, 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                : BoxShadow(
                    color: AppColors.alpha(AppColors.navy, 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.teal : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(role.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: const TextStyle(
                      fontFamily: kPoppins,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    role.titleNp,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role.desc,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      color: AppColors.secondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < role.features.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    Text(
                      role.features[i],
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w500 : FontWeight.w400,
                        color:
                            active ? const Color(0xFF0D7A7A) : AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.teal : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppColors.teal : AppColors.border,
                  width: 2,
                ),
              ),
              child: active
                  ? const SizedBox(
                      width: 8,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
