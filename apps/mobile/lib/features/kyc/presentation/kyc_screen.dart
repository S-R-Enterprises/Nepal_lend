import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/state/auth_controller.dart';
import '../../../routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/data/auth_repository.dart' show authRepositoryProvider;
import '../data/kyc_models.dart';
import '../data/kyc_repository.dart';
import '../../../shared/widgets/ui.dart';

class KYCScreen extends ConsumerStatefulWidget {
  const KYCScreen({super.key});

  @override
  ConsumerState<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends ConsumerState<KYCScreen> {
  static const _meta = <String, ({String icon, String sublabel})>{
    'citizenship': (icon: '🪪', sublabel: 'Citizenship / Passport'),
    'selfie': (icon: '🤳', sublabel: 'Live photo verification'),
    'details': (icon: '📝', sublabel: 'Personal details'),
    'bank_statement': (icon: '🏦', sublabel: 'Bank statement · last 6 months'),
  };

  KycStatus? _status;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _expanded;
  final TextEditingController _nameController = TextEditingController();
  final Map<String, XFile> _captures = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await ref.read(kycRepositoryProvider).getStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _loading = false;
        _expanded ??= _firstPending(status);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  String? _firstPending(KycStatus status) {
    for (final step in status.steps) {
      if (!step.isApproved) return step.id;
    }
    return null;
  }

  Future<void> _completeStep(String stepId) async {
    final name = _nameController.text.trim();
    if (stepId == 'details' && name.isEmpty) {
      setState(() => _error = 'Enter your full name to continue');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (stepId == 'details') {
        await ref.read(authRepositoryProvider).updateProfile(name: name);
      }
      final status = await ref.read(kycRepositoryProvider).verifyStep(stepId);
      if (!mounted) return;
      setState(() {
        _status = status;
        _busy = false;
        _expanded = _firstPending(status) ?? stepId;
        if (stepId != 'details') _captures.remove(stepId);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  void _finish() {
    final role = ref.read(authControllerProvider);
    context.go(
      role == UserRole.lender ? Routes.lenderHome : Routes.borrowerHome,
    );
  }

  Color _dotColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.riskLow;
      case 'In review':
      case 'Pending':
        return AppColors.riskMed;
      case 'Rejected':
      case 'Needs changes':
        return AppColors.riskHigh;
      default:
        return AppColors.border;
    }
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
            Expanded(child: _body()),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }
    final status = _status;
    if (status == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Could not load KYC status.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kInter,
                  fontSize: 14,
                  color: AppColors.danger,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              AppBtn(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status.isVerified) ...[
            _verifiedBanner(),
            const SizedBox(height: 16),
          ] else ...[
            _infoBanner(),
            const SizedBox(height: 16),
          ],
          if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.danger,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          for (var i = 0; i < status.steps.length; i++)
            _stepRow(i, status.steps[i]),
          _nrbNotice(),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final approved = _status?.approvedCount ?? 0;
    final total = _status?.steps.length ?? 4;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Stack(
        children: [
          const Positioned.fill(child: DhakaPattern(opacity: 0.08)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20 + MediaQuery.of(context).padding.top,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KYC Verification',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'पहिचान प्रमाणीकरण',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 12,
                      color: Color(0x8CFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: Color(0xB3FFFFFF),
                      ),
                    ),
                    Text(
                      '$approved of $total complete',
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: approved.toDouble(),
                  max: total.toDouble(),
                  height: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifiedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.riskLowBg,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎉', style: TextStyle(fontSize: 18, height: 1.3)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Identity verified! Your account is fully verified — you can now request loans or fund them.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.riskLow,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ℹ️', style: TextStyle(fontSize: 18, height: 1.3)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'KYC is required by Nepal Rastra Bank regulations. Your data is encrypted and never sold.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: Color(0xFF0D7A7A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int index, KycStep step) {
    final meta = _meta[step.id];
    final isExpanded = _expanded == step.id;
    final last = index == (_status?.steps.length ?? 0) - 1;
    final lineColor =
        step.isApproved ? AppColors.riskLow : AppColors.border;
    return Stack(
      children: [
        _stepDot(index, step),
        if (!last)
          Positioned(
            left: 11,
            top: 28,
            bottom: 0,
            child: Container(width: 2, color: lineColor),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 12),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isExpanded ? AppColors.teal : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(
                    () => _expanded = isExpanded ? '' : step.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        Text(meta?.icon ?? '📄',
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.label,
                                style: const TextStyle(
                                  fontFamily: kPoppins,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.navy,
                                ),
                              ),
                              Text(
                                meta?.sublabel ?? '',
                                style: const TextStyle(
                                  fontFamily: kInter,
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusPill(status: step.status),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: _stepDetails(step),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepDot(int index, KycStep step) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _dotColor(step.status),
        shape: BoxShape.circle,
      ),
      child: step.isApproved
          ? const Text(
              '✓',
              style: TextStyle(fontSize: 12, color: AppColors.white),
            )
          : Text(
              '${index + 1}',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
    );
  }

  Widget _stepDetails(KycStep step) {
    if (step.isApproved) {
      final date = step.updatedAt != null && step.updatedAt!.length >= 10
          ? ' on ${step.updatedAt!.substring(0, 10)}'
          : '';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Approved$date. This step is complete.',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                color: AppColors.riskLow,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    if (step.id == 'details') {
      final ready = _nameController.text.trim().isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We need your full name as it appears on your citizenship.',
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 13,
              color: AppColors.secondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          AppInput(
            label: 'Full name',
            placeholder: 'e.g. Aarav Sharma',
            controller: _nameController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _actionBtn(
            'Submit details',
            enabled: ready,
            onTap: () => _completeStep('details'),
          ),
          const SizedBox(height: 8),
          _devNote(),
        ],
      );
    }

    final description = switch (step.id) {
      'citizenship' =>
        'Photograph the front of your citizenship card or passport.',
      'selfie' => 'Take a clear, well-lit selfie — face the camera directly.',
      _ =>
        'Upload a photo of your bank statement covering the last 6 months. All entries must be readable.',
    };
    final captureLabel = switch (step.id) {
      'citizenship' => 'Scan citizenship',
      'selfie' => 'Take selfie',
      _ => 'Upload bank statement',
    };
    final capture = _captures[step.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 13,
            color: AppColors.secondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        if (capture == null)
          _actionBtn(
            captureLabel,
            enabled: true,
            onTap: () => _pickDocument(step.id),
          )
        else ...[
          _capturePreview(capture),
          const SizedBox(height: 12),
          _actionBtn(
            'Submit for verification',
            enabled: true,
            onTap: () => _completeStep(step.id),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _busy ? null : () => _pickDocument(step.id),
            child: const Text(
              'Choose a different photo',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.teal,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        _devNote(),
      ],
    );
  }

  Future<void> _pickDocument(String stepId) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text(
                'Add document photo',
                style: TextStyle(
                  fontFamily: kPoppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.navy,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.teal,
              ),
              title: const Text(
                'Take photo',
                style: TextStyle(fontFamily: kInter, fontSize: 14),
              ),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.teal,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(fontFamily: kInter, fontSize: 14),
              ),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.secondary),
              title: const Text(
                'Cancel',
                style: TextStyle(fontFamily: kInter, fontSize: 14),
              ),
              onTap: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _captures[stepId] = picked;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not capture the image. Please try again.');
    }
  }

  Widget _capturePreview(XFile file) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(file.path),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Photo attached. Check it is sharp and all four corners are visible, then submit.',
            style: TextStyle(
              fontFamily: kInter,
              fontSize: 13,
              color: AppColors.secondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _devNote() {
    return const Text(
      'Dev note: photos stay on this device until document upload ships with '
      'the admin console. Review is instant in this build.',
      style: TextStyle(
        fontFamily: kInter,
        fontSize: 11,
        color: AppColors.secondary,
        height: 1.4,
      ),
    );
  }

  Widget _actionBtn(
    String label, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final live = enabled && !_busy;
    return Material(
      color: live ? AppColors.mint : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: live ? onTap : null,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _busy && enabled
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: kInter,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: live ? AppColors.teal : AppColors.secondary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _nrbNotice() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF9C3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏛️', style: TextStyle(fontSize: 16, height: 1.3)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'NepalLend operates under NRB\'s Digital Financial Service guidelines. KYC data is processed per BAFIA 2073.',
              style: TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: Color(0xFF78350F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: AppBtn(
        fullWidth: true,
        onPressed: _finish,
        child: Text(
          (_status?.isVerified ?? false) ? 'Continue' : 'Continue anyway',
        ),
      ),
    );
  }
}
