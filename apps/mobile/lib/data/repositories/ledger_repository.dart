import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';

/// Ledger boundary. Track B swaps this mock for a transactional API; screens
/// and controllers keep the same contract.
abstract class LedgerRepository {
  Future<WalletSnapshot> loadWallet(String userId);

  Future<PaymentReceipt> postJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required JournalKind kind,
    required PaymentIntentKind intentKind,
    required String userId,
    required String referenceId,
    required int amountPaisa,
    required List<LedgerEntry> entries,
    String? reversalOfId,
  });

  Future<JournalTransaction> journal(String id);

  Future<PaymentReceipt> reverseJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required String userId,
    required PaymentIntentKind intentKind,
    required int amountPaisa,
    required String originalJournalId,
  });
}

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return MockLedgerRepository(api: ref.watch(apiClientProvider));
});

class MockLedgerRepository implements LedgerRepository {
  const MockLedgerRepository({required this.api});

  final ApiClient api;

  @override
  Future<WalletSnapshot> loadWallet(String userId) async {
    final response = await api.getJson('/wallet');
    return WalletSnapshot.fromJson(response);
  }

  @override
  Future<PaymentReceipt> postJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required JournalKind kind,
    required PaymentIntentKind intentKind,
    required String userId,
    required String referenceId,
    required int amountPaisa,
    required List<LedgerEntry> entries,
    String? reversalOfId,
  }) async {
    final response = await api.postJson(
      '/wallet/journals',
      data: <String, dynamic>{
        'journalId': journalId,
        'paymentIntentId': paymentIntentId,
        'idempotencyKey': idempotencyKey,
        'kind': kind.name,
        'intentKind': intentKind.name,
        'userId': userId,
        'referenceId': referenceId,
        'amountPaisa': amountPaisa,
        'reversalOfId': reversalOfId,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      },
    );
    return PaymentReceipt.fromJson(response);
  }

  @override
  Future<JournalTransaction> journal(String id) async {
    final response = await api.getJson('/wallet/journals/$id');
    return JournalTransaction.fromJson(response);
  }

  @override
  Future<PaymentReceipt> reverseJournal({
    required String journalId,
    required String paymentIntentId,
    required String idempotencyKey,
    required String userId,
    required PaymentIntentKind intentKind,
    required int amountPaisa,
    required String originalJournalId,
  }) async {
    final response = await api.postJson(
      '/wallet/journals/$originalJournalId/reverse',
      data: <String, dynamic>{
        'journalId': journalId,
        'paymentIntentId': paymentIntentId,
        'idempotencyKey': idempotencyKey,
        'userId': userId,
        'intentKind': intentKind.name,
        'amountPaisa': amountPaisa,
      },
    );
    return PaymentReceipt.fromJson(response);
  }
}
