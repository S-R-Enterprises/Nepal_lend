import 'package:dio/dio.dart';

/// A stable error shape shared by repositories and screens.
class AppFailure implements Exception {
  const AppFailure(this.code, this.message);

  final String code;
  final String message;

  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final code = data['error']?.toString() ?? 'request_failed';
        final message = data['message']?.toString();
        return AppFailure(code, message ?? messageFor(code));
      }
      final status = error.response?.statusCode;
      return AppFailure(
        'http_$status',
        status == null
            ? 'No connection. Check your internet and try again.'
            : messageFor('http_$status'),
      );
    }
    return const AppFailure('unknown', 'Something went wrong. Please try again.');
  }

  @override
  String toString() => 'AppFailure($code: $message)';
}

String messageFor(String code) => switch (code) {
      'unauthorized' || 'invalid_token' => 'Please sign in again.',
      'forbidden' => 'You do not have permission to do that.',
      'kyc_required' => 'Complete verification first.',
      'account_suspended' => 'This account is suspended.',
      'not_found' => 'We could not find that.',
      'validation_error' => 'Check the details and try again.',
      'role_required' => 'Switch to the correct account type to continue.',
      'invalid_transition' => 'That action is not available for this loan.',
      'invalid_amount' => 'Enter a loan amount between NPR 10,000 and NPR 5,00,000.',
      'invalid_tenor' => 'Choose a tenor between 3 and 60 months.',
      'below_minimum' => 'The minimum amount is NPR 1,000.',
      'exceeds_remaining' => 'That is more than the amount still needed.',
      'insufficient_balance' => 'Your wallet balance is too low.',
      'ledger_unbalanced' => 'The transaction could not be balanced. Try again.',
      'payment_failed' => 'The payment could not be completed. Try again.',
      'conflict' => 'This was already submitted.',
      'rate_limited' => 'Too many attempts. Please wait a moment.',
      'http_401' => 'Please sign in again.',
      'http_403' => 'You do not have permission to do that.',
      'http_404' => 'We could not find that.',
      'http_429' => 'Too many attempts. Please wait a moment.',
      'http_503' => 'The service is unavailable. Try again shortly.',
      _ => 'Something went wrong. Please try again.',
    };
