import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _resendSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resend(String phone) async {
    await ref.read(authProvider.notifier).sendCode(phone);
    if (!mounted) return;
    if (ref.read(authProvider).error == null) _startTimer();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).verifyCode(_codeController.text);
    // A successful verification triggers the router's auth redirect.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final auth = ref.watch(authProvider);
    final phone = auth.pendingPhone;
    final isMock = ref.watch(envProvider).isMock;

    if (phone == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.verifyNumberTitle)),
        body: ErrorState(
          message: l10n.requestCodeBeforeEnteringError,
          onRetry: () => context.go('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyNumberTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Icon(Icons.sms_outlined, size: 64, color: AppColors.primary),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.enterSixDigitCodeTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.sentToPhoneText(phone),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _codeController,
                  autofocus: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.otpCodeLabel,
                    hintText: l10n.otpCodeHint,
                    counterText: '',
                  ),
                  validator: (value) => value?.length == 6
                      ? null
                      : l10n.enterAllSixDigitsError,
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(auth.error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _secondsRemaining == 0 ? () => _resend(phone) : null,
                    style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48)),
                    child: Text(
                      _secondsRemaining == 0
                          ? l10n.resendCodeButton
                          : l10n.resendCountdown(_secondsRemaining),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.verifyAndContinueButton,
                  loading: auth.isBusy,
                  onPressed: _verify,
                  expand: true,
                ),
                if (isMock) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.otpDemoCodeNotice(MockAuthRepository.demoCode),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
