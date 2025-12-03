import 'package:chili_scan_app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  late final Dio _apiClient;

  ApiService(this._apiClient);

  Future<Response> fetchData(String endpoint) async {
    try {
      final response = await _apiClient.get(endpoint);
      return response;
    } on DioException catch (e) {
      throw Exception('Failed to load data: ${e.message}');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(apiClientProcider);
  return ApiService(dio);
});
