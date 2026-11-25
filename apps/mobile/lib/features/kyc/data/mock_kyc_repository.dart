import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_repository.dart';

/// Mock KYC storage. Document bytes stay on the device; only the path is
/// recorded. Track B replaces the mock adapter with signed cloud uploads.
class MockKycRepository implements KycRepository {
  const MockKycRepository({required this.api});

  final ApiClient api;

  @override
  Future<KycProfile> load() async {
    final response = await api.getJson('/me/kyc');
    return KycProfile.fromJson(response);
  }

  @override
  Future<KycProfile> submitDocument(
    KycStepKind kind, {
    required PickedDocument document,
  }) async {
    final upload = await api.postJson(
      '/me/kyc/documents',
      data: <String, dynamic>{
        'step': kind.name,
        'fileName': document.name,
        'localPath': document.path,
      },
    );
    return _submit(
      kind,
      documentPath: upload['localPath'] as String? ?? document.path,
      documentName: document.name,
    );
  }

  @override
  Future<KycProfile> submitPersonalDetails(Map<String, String> details) =>
      _submit(KycStepKind.personalDetails, details: details);

  @override
  Future<KycProfile> decide(
    KycStepKind kind,
    KycStatus decision, {
    String? reason,
  }) async {
    final response = await api.postJson(
      '/me/kyc/admin/decide',
      data: <String, dynamic>{
        'step': kind.name,
        'decision': decision.name,
        'reason': ?reason,
      },
    );
    return KycProfile.fromJson(response);
  }

  @override
  Future<KycProfile> approveAll() async {
    final response = await api.postJson('/me/kyc/admin/approve-all');
    return KycProfile.fromJson(response);
  }

  Future<KycProfile> _submit(
    KycStepKind kind, {
    String? documentPath,
    String? documentName,
    Map<String, String>? details,
  }) async {
    final response = await api.postJson(
      '/me/kyc/steps/${kind.routeSegment}/submit',
      data: <String, dynamic>{
        'documentPath': ?documentPath,
        'documentName': ?documentName,
        'details': ?details,
      },
    );
    return KycProfile.fromJson(response);
  }
}
