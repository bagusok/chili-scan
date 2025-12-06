import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/services/predict_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final predictHistoryDetailProvider = FutureProvider.autoDispose
    .family<PredictHistoryModel, String>((ref, id) async {
      final service = ref.read(predictionServiceProvider);
      return service.getHistoryById(id);
    });
