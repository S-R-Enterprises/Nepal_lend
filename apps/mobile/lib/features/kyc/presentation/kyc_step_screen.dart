import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class KycStepScreen extends ConsumerStatefulWidget {
  const KycStepScreen({super.key, required this.kind});

  final KycStepKind kind;

  @override
  ConsumerState<KycStepScreen> createState() => _KycStepScreenState();
}

class _KycStepScreenState extends ConsumerState<KycStepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _citizenshipNumber = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _reason = TextEditingController();

  PickedDocument? _picked;
  String? _localError;

  @override
  void initState() {
    super.initState();
    final details = ref.read(kycProvider).profile.details;
    _fullName.text = details['fullName'] ?? '';
    _citizenshipNumber.text = details['citizenshipNumber'] ?? '';
    _dateOfBirth.text = details['dateOfBirth'] ?? '';
    _bankName.text = details['bankName'] ?? '';
    _accountNumber.text = details['accountNumber'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(kycProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _citizenshipNumber.dispose();
    _dateOfBirth.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick(PickSource source) async {
    final document = await ref.read(documentPickerProvider).pick(source);
    if (document == null || !mounted) return;
    setState(() {
      _picked = document;
      _localError = null;
    });
  }

  Future<void> _submit(BuildContext context, KycStep step) async {
    final l10n = L10n.of(context);
    setState(() => _localError = null);
    final controller = ref.read(kycProvider.notifier);
    final bool ok;

    if (widget.kind.isDocument) {
      final document = _picked;
      if (document == null) {
        setState(() => _localError = l10n.captureDocumentFirstError);
        return;
      }
      ok = await controller.submitDocument(widget.kind, document: document);
    } else {
      if (!_formKey.currentState!.validate()) return;
      ok = await controller.submitPersonalDetails(<String, String>{
        'fullName': _fullName.text.trim(),
        'citizenshipNumber': _citizenshipNumber.text.trim(),
        'dateOfBirth': _dateOfBirth.text.trim(),
        'bankName': _bankName.text.trim(),
        'accountNumber': _accountNumber.text.trim(),
      });
    }

    if (ok && context.mounted) context.go('/kyc');
  }

  Future<void> _decide(KycStatus decision) async {
    final ok = await ref.read(kycProvider.notifier).decide(
          widget.kind,
          decision,
          reason: decision == KycStatus.rejected ? _reason.text : null,
        );
    if (ok && mounted) context.go('/kyc');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final kyc = ref.watch(kycProvider);
    final step = kyc.profile.step(widget.kind);
    final rejectionReason = step.reason;
    final isMock = ref.watch(envProvider).isMock;
    final stepNumber = KycStepKind.values.indexOf(widget.kind) + 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.kind.label)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenStateView(
                isLoading: kyc.isBusy && step.status == KycStatus.notStarted,
                isEmpty: false,
                error: kyc.error,
                onRetry: () => ref.read(kycProvider.notifier).load(),
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              StepIndicator(total: 4, completed: kyc.profile.completedCount),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.kycStepProgress(stepNumber),
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              Text(widget.kind.description,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              if (step.isVerified)
                _VerifiedPanel(kind: widget.kind)
              else if (step.isInReview)
                _ReviewPanel(
                  step: step,
                  reasonController: _reason,
                  isMock: isMock,
                  busy: kyc.isBusy,
                  onApprove: () => _decide(KycStatus.verified),
                  onReject: () => _decide(KycStatus.rejected),
                )
              else ...[
                if (step.isRejected) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      rejectionReason != null
                          ? l10n.kycRejectedNotice(rejectionReason)
                          : l10n.kycRejectedNoticeNoReason,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (widget.kind.isDocument)
                  _DocumentCapture(
                    document: _picked,
                    onPick: _pick,
                  )
                else
                  _PersonalDetailsForm(
                    formKey: _formKey,
                    fullName: _fullName,
                    citizenshipNumber: _citizenshipNumber,
                    dateOfBirth: _dateOfBirth,
                    bankName: _bankName,
                    accountNumber: _accountNumber,
                  ),
                const SizedBox(height: AppSpacing.lg),
                if (kyc.uploading) const LinearProgressIndicator(minHeight: 4),
                if (kyc.error != null || _localError != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _localError ?? kyc.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: step.isRejected
                      ? l10n.resubmitForReviewButton
                      : l10n.submitForReviewButton,
                  loading: kyc.isBusy || kyc.uploading,
                  onPressed: () => _submit(context, step),
                  expand: true,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.backToChecklistButton,
                variant: AppButtonVariant.text,
                onPressed: () => context.go('/kyc'),
                expand: true,
             ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCapture extends StatelessWidget {
  const _DocumentCapture({
    required this.document,
    required this.onPick,
  });

  final PickedDocument? document;
  final void Function(PickSource source) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.takePhotoButton,
          variant: AppButtonVariant.secondary,
          icon: Icons.photo_camera_outlined,
          onPressed: () => onPick(PickSource.camera),
          expand: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.chooseFromGalleryButton,
          variant: AppButtonVariant.secondary,
          icon: Icons.photo_library_outlined,
          onPressed: () => onPick(PickSource.gallery),
          expand: true,
        ),
        const SizedBox(height: AppSpacing.md),
        if (document == null)
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.outline.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined,
                  size: 48, color: AppColors.muted),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Image.file(
                  File(document!.path),
                  height: 200,
                  cacheWidth: (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
                  cacheHeight: (200 * MediaQuery.devicePixelRatioOf(context))
                      .round(),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    color: AppColors.outline.withValues(alpha: 0.25),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 40, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.selectedDocumentText(document!.name),
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: () => onPick(PickSource.gallery),
                style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48)),
                child: Text(l10n.chooseDifferentPhotoButton),
              ),
            ],
          ),
      ],
    );
  }
}

class _PersonalDetailsForm extends StatelessWidget {
  static final RegExp accountNumberPattern = RegExp(r'^[0-9]{5,20}$');

  const _PersonalDetailsForm({
    required this.formKey,
    required this.fullName,
    required this.citizenshipNumber,
    required this.dateOfBirth,
    required this.bankName,
    required this.accountNumber,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullName;
  final TextEditingController citizenshipNumber;
  final TextEditingController dateOfBirth;
  final TextEditingController bankName;
  final TextEditingController accountNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppInput(
            label: l10n.fullNameLabel,
            hint: l10n.fullNameHint,
            controller: fullName,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.enterFullNameError
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: l10n.citizenshipNumberLabel,
            hint: l10n.citizenshipNumberHint,
            controller: citizenshipNumber,
            validator: (value) => value == null || value.trim().length < 5
                ? l10n.enterCitizenshipNumberError
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: l10n.dateOfBirthLabel,
            hint: l10n.dateOfBirthHint,
            controller: dateOfBirth,
            keyboardType: TextInputType.datetime,
            validator: (value) => DateTime.tryParse(value ?? '') == null
                ? l10n.invalidDateFormatError
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: l10n.bankNameLabel,
            hint: l10n.bankNameHint,
            controller: bankName,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.enterBankNameError
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: l10n.bankAccountNumberLabel,
            hint: l10n.bankAccountNumberHint,
            controller: accountNumber,
            keyboardType: TextInputType.number,
            validator: (value) => value == null ||
                    !accountNumberPattern.hasMatch(value.trim())
                ? l10n.enterFiveToTwentyDigitsError
                : null,
          ),
        ],
      ),
    );
  }
}

class _VerifiedPanel extends StatelessWidget {
  const _VerifiedPanel({required this.kind});

  final KycStepKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.verified, color: AppColors.success, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.kycStepVerifiedTitle(kind.label),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.kycStepLockedNote,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.step,
    required this.reasonController,
    required this.isMock,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final KycStep step;
  final TextEditingController reasonController;
  final bool isMock;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.hourglass_top,
                  color: AppColors.warning, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.kycStepSubmittedTitle(step.kind.label),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.kycStepReviewNote,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (isMock) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.demoReviewerTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            label: l10n.rejectionReasonLabel,
            hint: l10n.rejectionReasonHint,
            controller: reasonController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.approveStepButton,
            loading: busy,
            onPressed: onApprove,
            expand: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.rejectStepButton,
            variant: AppButtonVariant.secondary,
            loading: busy,
            onPressed: onReject,
            expand: true,
          ),
        ],
      ],
    );
  }
}
