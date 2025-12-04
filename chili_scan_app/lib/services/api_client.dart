import 'package:chili_scan_app/common/constants/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider.autoDispose<Dio>(
  (ref) => Dio(BaseOptions(baseUrl: API_BASE_URL)),
);
