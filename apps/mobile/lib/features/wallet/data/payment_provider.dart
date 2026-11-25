import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';

class PaymentResult {
  const PaymentResult({
    required this.reference,
    required this.provider,
  });

  final String reference;
  final String provider;
}

/// Payment boundary. Track B replaces this with a real gateway SDK; the wallet
/// controller only depends on this interface.
abstract class PaymentProvider {
  Future<PaymentResult> charge({
    required int amountPaisa,
    required String idempotencyKey,
  });

  Future<PaymentResult> payout({
    required int amountPaisa,
    required String idempotencyKey,
  });
}

/// Instant demo gateway with a one-shot failure switch for error-state tests.
class SimulatedPaymentProvider implements PaymentProvider {
  bool _failNext = false;

  void failNextPayment() => _failNext = true;

  @override
  Future<PaymentResult> charge({
    required int amountPaisa,
    required String idempotencyKey,
  }) async {
    _consumeFailure();
    return PaymentResult(
      reference: 'sim-charge-${amountPaisa}_$idempotencyKey',
      provider: 'simulated',
    );
  }

  @override
  Future<PaymentResult> payout({
    required int amountPaisa,
    required String idempotencyKey,
  }) async {
    _consumeFailure();
    return PaymentResult(
      reference: 'sim-payout-${amountPaisa}_$idempotencyKey',
      provider: 'simulated',
    );
  }

  void _consumeFailure() {
    if (!_failNext) return;
    _failNext = false;
    throw const AppFailure(
      'payment_failed',
      'The payment could not be completed. Try again.',
    );
  }
}

final simulatedPaymentProviderProvider =
    Provider<SimulatedPaymentProvider>((ref) => SimulatedPaymentProvider());

final paymentProviderProvider = Provider<PaymentProvider>((ref) {
  return ref.watch(simulatedPaymentProviderProvider);
});
