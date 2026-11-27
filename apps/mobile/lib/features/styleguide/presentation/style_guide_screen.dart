import 'package:flutter/material.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

/// Live component gallery — blueprint §5.2.
class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.styleGuideTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(title: l10n.styleGuideColoursSection, children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _Swatch(color: AppColors.primary, label: l10n.swatchPrimaryLabel),
                  _Swatch(color: AppColors.success, label: l10n.swatchSuccessLabel),
                  _Swatch(color: AppColors.warning, label: l10n.swatchWarningLabel),
                  _Swatch(color: AppColors.error, label: l10n.swatchErrorLabel),
                  _Swatch(color: AppColors.riskLow, label: l10n.swatchRiskLowLabel),
                  _Swatch(
                    color: AppColors.riskMedium,
                    label: l10n.swatchRiskMediumLabel,
                  ),
                  _Swatch(color: AppColors.riskHigh, label: l10n.swatchRiskHighLabel),
                ],
              ),
            ]),
            _Section(title: l10n.styleGuideTypographySection, children: [
              Text(
                l10n.typographyDisplayTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                l10n.typographyTitleSample,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                l10n.typographyBodySample,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                l10n.typographyCaptionSample,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
            _Section(title: l10n.styleGuideButtonsSection, children: [
              AppButton(label: l10n.styleGuidePrimaryAction),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.styleGuideSecondaryAction,
                variant: AppButtonVariant.secondary,
                icon: Icons.download_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.styleGuideDisabledButton,
                onPressed: null,
                variant: AppButtonVariant.text,
              ),
            ]),
            _Section(title: l10n.styleGuideInputsSection, children: [
              AppInput(
                label: l10n.loanAmountLabel,
                hint: l10n.styleGuideAmountHint,
                controller: _controller,
                prefixText: l10n.nprPrefix,
                keyboardType: TextInputType.number,
              ),
            ]),
            _Section(title: l10n.styleGuideCardsSection, children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AmountText(paisa: 20000000, large: true),
                    const SizedBox(height: AppSpacing.sm),
                    RiskBadge(grade: l10n.styleGuideDemoGrade, band: 'medium'),
                  ],
                ),
              ),
            ]),
            _Section(title: l10n.styleGuideProgressSection, children: [
              const FundingProgress(fundedPaisa: 12800000, amountPaisa: 20000000),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  StatusChip(label: l10n.statusVerified, tone: AppTone.success),
                  StatusChip(label: l10n.statusInReview, tone: AppTone.warning),
                  StatusChip(label: l10n.statusRejected, tone: AppTone.error),
                  StatusChip(label: l10n.statusOpen),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const StepIndicator(total: 4, completed: 2),
            ]),
            _Section(title: l10n.styleGuideStatesSection, children: [
              const SkeletonLoader(height: 20),
              const SizedBox(height: AppSpacing.md),
              EmptyState(
                title: l10n.styleGuideNoLoansYet,
                message: l10n.styleGuideNoLoansMessage,
              ),
              ErrorState(
                message: l10n.styleGuideErrorStateMessage,
                onRetry: () {},
              ),
            ]),
            _Section(title: l10n.styleGuideBottomSheetSection, children: [
              AppButton(
                label: l10n.openConfirmationSheetButton,
                variant: AppButtonVariant.secondary,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BottomSheetScaffold(
                    title: l10n.confirmFundingSheetTitle,
                    actionLabel: l10n.confirmAndFundButton,
                    children: [
                      const AmountText(paisa: 500000),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.expectedInterestDemoText),
                    ],
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
}
