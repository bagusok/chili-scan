import 'dart:developer';

import 'package:chili_scan_app/common/exceptions/api_exception.dart';
import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/services/api_client.dart';
import 'package:chili_scan_app/services/supabase_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

class PredictService {
  late final SupabaseClient _db;
  late final Dio _httpClient;

  PredictService({required SupabaseClient db, required Dio httpClient})
    : _db = db,
      _httpClient = httpClient;

  Future<PredictHistoryModel> predict({required XFile image}) async {
    try {
      MultipartFile multipartFile;
      // base url
      log('Making prediction request to: ${_httpClient.options.baseUrl}');

      if (kIsWeb) {
        // WEB: Tidak bisa menggunakan path, ambil bytes
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: image.name);
      } else {
        // MOBILE: Aman pakai file path
        multipartFile = await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        );
      }

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await _httpClient.post(
        '/predict',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        return PredictHistoryModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
          error: 'Prediction failed with status code ${response.statusCode}',
          message: 'Prediction failed',
        );
      }
    } catch (e) {
      throw ApiException(error: e.toString(), message: e.toString());
    }
  }

  Future<PredictHistoryModel> getHistoryById(String id) async {
    try {
      final response = await _db
          .from('predict_history')
          .select()
          .eq('id', id)
          .single();

      log(response.toString());

      return PredictHistoryModel.fromJson(response);
    } catch (e) {
      // SupabaseThrowingException sudah punya message
      throw ApiException(
        error: e.toString(),
        message: "Failed to fetch history",
      );
    }
  }

  Future<List<PredictHistoryModel>> getAllHistory({
    int page = 1,
    int limit = 10,
    required String userId,
  }) async {
    try {
      final response = await _db
          .from('predict_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      log(response.toString());

      return (response as List)
          .map((e) => PredictHistoryModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiException(error: e.toString(), message: e.toString());
    }
  }
}

final predictionServiceProvider = Provider((Ref ref) {
  final supabaseClient = ref.read(supabase);
  final dioClient = ref.read(apiClientProvider);
  return PredictService(db: supabaseClient, httpClient: dioClient);
});
