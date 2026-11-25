import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

List<_Slide> _buildSlides(BuildContext context) {
  final l10n = L10n.of(context);
  return [
    _Slide(
      icon: Icons.handshake_outlined,
      title: l10n.onboardingSlide1Title,
      body: l10n.onboardingSlide1Body,
    ),
    _Slide(
      icon: Icons.verified_user_outlined,
      title: l10n.onboardingSlide2Title,
      body: l10n.onboardingSlide2Body,
    ),
    _Slide(
      icon: Icons.receipt_long_outlined,
      title: l10n.onboardingSlide3Title,
      body: l10n.onboardingSlide3Body,
    ),
  ];
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(BuildContext context) {
    final slides = _buildSlides(context);
    if (_page == slides.length - 1) {
      context.go('/login');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final slides = _buildSlides(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48)),
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _page = index),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 80, color: AppColors.primary),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<int>.generate(slides.length, (index) => index)
                  .map(
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _page
                            ? AppColors.primary
                            : AppColors.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppButton(
                label: _page == slides.length - 1
                    ? l10n.getStartedButton
                    : l10n.nextButton,
                onPressed: () => _next(context),
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
