import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/loan.dart';

/// Loan boundary. Track B keeps the same contract with a transactional API.
abstract class LoanRepository {
  Future<Loan> createApplication({
    required String purpose,
    required int amountPaisa,
    required int tenorMonths,
    required int monthlyIncomePaisa,
  });

  Future<List<Loan>> myLoans();

  Future<Loan> loan(String id);

  Future<Loan> submitForReview(String id);

  Future<Loan> approve(String id);

  Future<Loan> signAgreement({
    required String id,
    required String signedBy,
  });
}

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return MockLoanRepository(api: ref.watch(apiClientProvider));
});

class MockLoanRepository implements LoanRepository {
  const MockLoanRepository({required this.api});

  final ApiClient api;

  @override
  Future<Loan> createApplication({
    required String purpose,
    required int amountPaisa,
    required int tenorMonths,
    required int monthlyIncomePaisa,
  }) async {
    final response = await api.postJson(
      '/loans/applications',
      data: <String, dynamic>{
        'purpose': purpose,
        'amountPaisa': amountPaisa,
        'tenorMonths': tenorMonths,
        'monthlyIncomePaisa': monthlyIncomePaisa,
      },
    );
    return Loan.fromJson(response);
  }

  @override
  Future<List<Loan>> myLoans() async {
    final response = await api.getJson('/loans/mine');
    return (response['loans'] as List<dynamic>)
        .map((item) => Loan.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Loan> loan(String id) async {
    final response = await api.getJson('/loans/$id');
    return Loan.fromJson(response);
  }

  @override
  Future<Loan> submitForReview(String id) async {
    final response = await api.postJson('/loans/$id/submit');
    return Loan.fromJson(response);
  }

  @override
  Future<Loan> approve(String id) async {
    final response = await api.postJson('/loans/$id/admin/approve');
    return Loan.fromJson(response);
  }

  @override
  Future<Loan> signAgreement({
    required String id,
    required String signedBy,
  }) async {
    final response = await api.postJson(
      '/loans/$id/agreement',
      data: <String, dynamic>{'signedBy': signedBy},
    );
    return Loan.fromJson(response);
  }
}
