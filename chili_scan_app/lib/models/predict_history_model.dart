class PredictHistoryModel {
  String? id;
  String? userId;
  String? imageUrl;
  String? svmResult;
  String? knnResult;
  PredictHistoryStatistics? statistics;
  String? createdAt;

  PredictHistoryModel({
    this.id,
    this.userId,
    this.imageUrl,
    this.svmResult,
    this.knnResult,
    this.statistics,
    this.createdAt,
  });

  PredictHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    imageUrl = json['image_url'];
    svmResult = json['svm_result'];
    knnResult = json['knn_result'];
    statistics = json['statistics'] != null
        ? PredictHistoryStatistics.fromJson(json['statistics'])
        : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['image_url'] = imageUrl;
    data['svm_result'] = svmResult;
    data['knn_result'] = knnResult;
    if (statistics != null) {
      data['statistics'] = statistics!.toJson();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class PredictHistoryStatistics {
  PredictHistoryKnn? knn;
  PredictHistoryKnn? svm;

  PredictHistoryStatistics({this.knn, this.svm});

  PredictHistoryStatistics.fromJson(Map<String, dynamic> json) {
    knn = json['knn'] != null ? PredictHistoryKnn.fromJson(json['knn']) : null;
    svm = json['svm'] != null ? PredictHistoryKnn.fromJson(json['svm']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (knn != null) {
      data['knn'] = knn!.toJson();
    }
    if (svm != null) {
      data['svm'] = svm!.toJson();
    }
    return data;
  }
}

class PredictHistoryKnn {
  double? confidence;
  int? durationMs;

  PredictHistoryKnn({this.confidence, this.durationMs});

  PredictHistoryKnn.fromJson(Map<String, dynamic> json) {
    confidence = json['confidence'];
    durationMs = json['duration_ms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['confidence'] = confidence;
    data['duration_ms'] = durationMs;
    return data;
  }
}
