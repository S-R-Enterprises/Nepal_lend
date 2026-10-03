import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'kyc_models.dart';

final kycRepositoryProvider = Provider<KycRepository>(
  (ref) => KycRepository(ref.watch(apiClientProvider)),
);

class KycRepository {
  KycRepository(this._api);

  final ApiClient _api;

  Future<KycStatus> getStatus() async {
    try {
      final res = await _api.dio.get('/me/kyc');
      return KycStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<KycStatus> verifyStep(String stepId) async {
    try {
      final res = await _api.dio.post('/me/kyc/steps/$stepId/verify');
      return KycStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
