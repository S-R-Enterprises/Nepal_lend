import 'package:dio/dio.dart';

/// Backend-communicable API failure with the server's message.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  static ApiException fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(
        data['message'] as String,
        statusCode: e.response?.statusCode,
      );
    }
    if (e.response == null) {
      return ApiException('Cannot reach the server. Check your connection.');
    }
    return ApiException(
      'Something went wrong.',
      statusCode: e.response?.statusCode,
    );
  }
}
