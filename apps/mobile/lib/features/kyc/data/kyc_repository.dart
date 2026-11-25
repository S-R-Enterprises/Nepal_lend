import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/mock_kyc_repository.dart';

/// Boundary between the KYC UI and verification storage. Track B adds an HTTP
/// implementation that uploads to a signed URL; screens stay unchanged.
abstract class KycRepository {
  Future<KycProfile> load();

  Future<KycProfile> submitDocument(
    KycStepKind kind, {
    required PickedDocument document,
  });

  Future<KycProfile> submitPersonalDetails(Map<String, String> details);

  /// Demo admin action; in Track B this is an authenticated admin endpoint.
  Future<KycProfile> decide(
    KycStepKind kind,
    KycStatus decision, {
    String? reason,
  });

  Future<KycProfile> approveAll();
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return MockKycRepository(api: ref.watch(apiClientProvider));
});
