import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/features/repayments/data/repayment_service.dart';

/// Borrower repayment boundary. Track B keeps the same contract with a
/// transactional payment + ledger API; screens never post journals directly.
abstract class RepaymentRepository {
  Future<RepaymentOutcome> pay({
    required String loanId,
    required int instalmentNumber,
    required String provider,
    required String idempotencyKey,
  });

  Future<int> sendReminders();

  Future<int> markOverdue();

  Future<ReconciliationOutcome> reconcile();
}

final repaymentRepositoryProvider = Provider<RepaymentRepository>((ref) {
  return MockRepaymentRepository(api: ref.watch(apiClientProvider));
});

class MockRepaymentRepository implements RepaymentRepository {
  const MockRepaymentRepository({required this.api});

  final ApiClient api;

  @override
  Future<RepaymentOutcome> pay({
    required String loanId,
    required int instalmentNumber,
    required String provider,
    required String idempotencyKey,
  }) async {
    final response = await api.postJson(
      '/loans/$loanId/repay',
      data: <String, dynamic>{
        'instalmentNumber': instalmentNumber,
        'provider': provider,
        'idempotencyKey': idempotencyKey,
      },
      moneyMove: true,
      idempotencyKey: idempotencyKey,
    );
    return RepaymentOutcome.fromJson(response);
  }

  @override
  Future<int> sendReminders() async {
    final response = await api.postJson('/jobs/send-reminders');
    return (response['sent'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> markOverdue() async {
    final response = await api.postJson('/jobs/mark-overdue');
    return (response['changed'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<ReconciliationOutcome> reconcile() async {
    final response = await api.postJson('/jobs/reconcile');
    return ReconciliationOutcome.fromJson(response);
  }
}
