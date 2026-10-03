import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/ui.dart';

class FundingSuccessScreen extends StatelessWidget {
  const FundingSuccessScreen({super.key, this.partial = false});

  final bool partial;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final title = partial ? 'Partially Funded' : 'Successfully Funded!';
    final desc = partial
        ? 'You funded NPR 3,000 of this loan. The loan is still collecting from other lenders.'
        : 'Your NPR 5,000 has been committed to the Agriculture loan. You\'ll earn 18% p.a.';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(Routes.lenderHome);
        }
      },
      child: SystemChromeStyle(
        light: false,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                height: top,
                color: AppColors.navy,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _successCircle(),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: kPoppins,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: kInter,
                            fontSize: 14,
                            color: AppColors.secondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _summaryCard(),
                        const SizedBox(height: 24),
                        if (partial) ...[
                          _infoBox(),
                          const SizedBox(height: 20),
                        ],
                        AppBtn(
                          fullWidth: true,
                          onPressed: () =>
                              context.push(Routes.browseLoans),
                          child: const Text('Browse More Loans'),
                        ),
                        const SizedBox(height: 10),
                        AppBtn(
                          fullWidth: true,
                          variant: AppBtnVariant.secondary,
                          onPressed: () =>
                              context.push(Routes.portfolio),
                          child: const Text('View Portfolio'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successCircle() {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: partial ? AppColors.riskMedBg : AppColors.riskLowBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: partial
                ? const Color(0x33D97706)
                : const Color(0x3316A34A),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        partial ? '⏳' : '✅',
        style: const TextStyle(fontSize: 48),
      ),
    );
  }

  Widget _summaryCard() {
    final rows = [
      ('Your contribution', formatNPR(partial ? 3000 : 5000)),
      ('Expected interest', formatNPR(partial ? 540 : 900)),
      ('First repayment', '15 Nov 2026'),
      ('Loan grade', '🟢 Low Risk'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.alpha(AppColors.teal, 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r.$1,
                    style: const TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    r.$2,
                    style: const TextStyle(
                      fontFamily: kPoppins,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.riskMedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "If the loan doesn't fully fund within 4 days, your money returns to your wallet automatically.",
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
