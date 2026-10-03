import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes.dart';
import '../../../core/state/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../data/auth_repository.dart'
    show AuthException, authRepositoryProvider;
import '../../../shared/widgets/ui.dart';

const List<String> _keys = [
  '1', '2', '3',
  '4', '5', '6',
  '7', '8', '9',
  '*', '0', '⌫',
];

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({
    super.key,
    this.requestId = '',
    this.phone = '',
    this.devCode = '',
  });

  /// From the `/auth/otp/request` step; empty when the screen is opened
  /// without a live challenge (e.g. render smoke tests).
  final String requestId;
  final String phone;

  /// Non-production echo of the generated code (dev builds show it on
  /// screen since no real SMS is delivered). Empty in production.
  final String devCode;

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  String _otp = '';
  int _timer = 30;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.devCode.length == 6) _otp = widget.devCode;
  }

  Future<void> _verify() async {
    if (widget.requestId.isEmpty) {
      setState(() => _error = 'Session expired. Request a new code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.verifyOtp(widget.requestId, _otp);
      if (!mounted) return;

      final localRole = ref.read(authControllerProvider);
      if (session.user.role != localRole.name) {
        await repo.updateProfile(role: localRole.name);
        if (!mounted) return;
      }

      if (session.isNewUser) {
        context.go(Routes.kyc);
      } else {
        context.go(
          localRole == UserRole.lender ? Routes.lenderHome : Routes.borrowerHome,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onKey(String k) {
    setState(() {
      if (k == '⌫') {
        if (_otp.isNotEmpty) _otp = _otp.substring(0, _otp.length - 1);
      } else if (_otp.length < 6 && k != '*') {
        _otp = '$_otp$k';
      }
    });
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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'We sent a 6-digit code to\n',
                        style: const TextStyle(
                          fontFamily: kInter,
                          fontSize: 15,
                          color: AppColors.secondary,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                            text: widget.phone.isEmpty
                                ? '+977 9812345678'
                                : '+977 ${widget.phone}',
                            style: const TextStyle(
                              fontFamily: kInter,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.devCode.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => setState(() => _otp = widget.devCode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Dev build — no SMS is sent. Tap to fill: '
                            '${widget.devCode}',
                            style: const TextStyle(
                              fontFamily: kInter,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    OTPInput(value: _otp),
                    const SizedBox(height: 28),
                    _resend(),
                    const SizedBox(height: 28),
                    _keypad(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: kInter,
                        fontSize: 12,
                        color: AppColors.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  AppBtn(
                    fullWidth: true,
                    disabled: _otp.length < 6 || _loading,
                    onPressed: _verify,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
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
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify Number',
                  style: TextStyle(
                    fontFamily: kPoppins,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'नम्बर प्रमाणित गर्नुहोस्',
                    style: TextStyle(
                      fontFamily: kInter,
                      fontSize: 13,
                      color: Color(0x99FFFFFF),
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

  Widget _resend() {
    if (_timer > 0) {
      final t = _timer < 10 ? '0$_timer' : '$_timer';
      return Text.rich(
        TextSpan(
          text: 'Resend code in ',
          style: const TextStyle(
            fontFamily: kInter,
            fontSize: 13,
            color: AppColors.secondary,
          ),
          children: [
            TextSpan(
              text: '00:${t}s',
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _timer = 30),
      child: const Text(
        'Resend OTP',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kInter,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _keypad() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 4; r++) ...[
            if (r > 0) const SizedBox(height: 2),
            Row(
              children: [
                for (var c = 0; c < 3; c++) ...[
                  if (c > 0) const SizedBox(width: 2),
                  Expanded(child: _key(_keys[r * 3 + c])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _key(String k) {
    final backspace = k == '⌫';
    return Material(
      color: backspace ? AppColors.mint : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onKey(k),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              k,
              style: TextStyle(
                fontFamily: kPoppins,
                fontSize: backspace ? 18 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
