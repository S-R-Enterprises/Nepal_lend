import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';

/// One lender stake together with the loan it belongs to.
class StakeDetail {
  const StakeDetail({required this.stake, required this.loan});

  final Stake stake;
  final Loan loan;

  factory StakeDetail.fromJson(Map<String, dynamic> json) => StakeDetail(
        stake: Stake.fromJson(json['stake'] as Map<String, dynamic>),
        loan: Loan.fromJson(json['loan'] as Map<String, dynamic>),
      );
}

/// Lender-side boundary. Track B keeps the same contract with a transactional
/// funding API; screens and controllers do not post journals themselves.
abstract class FundingRepository {
  Future<List<Loan>> browseLoans({
    RiskBand? riskBand,
    int? minAmountPaisa,
    int? maxAmountPaisa,
    int? maxTenorMonths,
    String sort = 'newest',
  });

  Future<Loan> loanDetails(String id);

  Future<Stake> fund({
    required String loanId,
    required int amountPaisa,
    required String idempotencyKey,
  });

  Future<List<Stake>> myStakes();

  Future<StakeDetail> stake(String id);

  Future<int> expireLoans();
}

final fundingRepositoryProvider = Provider<FundingRepository>((ref) {
  return MockFundingRepository(api: ref.watch(apiClientProvider));
});

class MockFundingRepository implements FundingRepository {
  const MockFundingRepository({required this.api});

  final ApiClient api;

  @override
  Future<List<Loan>> browseLoans({
    RiskBand? riskBand,
    int? minAmountPaisa,
    int? maxAmountPaisa,
    int? maxTenorMonths,
    String sort = 'newest',
  }) async {
    final query = <String, dynamic>{
      'sort': sort,
      'riskBand': ?riskBand?.name,
      'minAmountPaisa': ?minAmountPaisa?.toString(),
      'maxAmountPaisa': ?maxAmountPaisa?.toString(),
      'maxTenorMonths': ?maxTenorMonths?.toString(),
    };
    final response = await api.getJson('/loans/browse', queryParameters: query);
    return (response['items'] as List<dynamic>)
        .map((item) => Loan.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Loan> loanDetails(String id) async {
    final response = await api.getJson('/loans/browse/$id');
    return Loan.fromJson(response);
  }

  @override
  Future<Stake> fund({
    required String loanId,
    required int amountPaisa,
    required String idempotencyKey,
  }) async {
    final response = await api.postJson(
      '/loans/$loanId/fund',
      data: <String, dynamic>{
        'amountPaisa': amountPaisa,
        'idempotencyKey': idempotencyKey,
      },
      moneyMove: true,
      idempotencyKey: idempotencyKey,
    );
    return Stake.fromJson(response);
  }

  @override
  Future<List<Stake>> myStakes() async {
    final response = await api.getJson('/stakes/mine');
    return (response['items'] as List<dynamic>)
        .map((item) => Stake.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<StakeDetail> stake(String id) async {
    final response = await api.getJson('/stakes/$id');
    return StakeDetail.fromJson(response);
  }

  @override
  Future<int> expireLoans() async {
    final response = await api.postJson('/jobs/expire-loans');
    return (response['expired'] as num?)?.toInt() ?? 0;
  }
}
