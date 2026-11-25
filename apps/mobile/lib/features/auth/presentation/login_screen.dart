import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).sendCode(_phoneController.text);
    if (!mounted) return;
    if (ref.read(authProvider).pendingPhone != null) {
      context.go('/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final auth = ref.watch(authProvider);
    final isMock = ref.watch(envProvider).isMock;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Icon(Icons.phone_android, size: 64, color: AppColors.primary),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.loginEnterPhoneTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.loginPhoneExplanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppInput(
                  label: l10n.mobileNumberLabel,
                  hint: l10n.mobileNumberHint,
                  controller: _phoneController,
                  prefixText: l10n.nepalPhonePrefix,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final digits = MockAuthRepository.normalizePhone(value ?? '');
                    return MockAuthRepository.isValidNepaliMobile(digits)
                        ? null
                        : l10n.invalidMobileNumberError;
                  },
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(auth.error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.sendCodeButton,
                  loading: auth.isBusy,
                  onPressed: _sendCode,
                  expand: true,
                ),
                if (isMock) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.useDemoAccountButton,
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: () async {
                      await ref.read(authProvider.notifier).demoSignIn();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.loginDemoCodeHint,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    textAlign: TextAlign.center,
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
