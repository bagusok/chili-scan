import 'dart:developer';

import 'package:chili_scan_app/common/exceptions/api_exception.dart';
import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/services/predict_service.dart';
import 'package:chili_scan_app/services/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredictHistoryState {
  final List<PredictHistoryModel> histories;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;

  const PredictHistoryState({
    this.histories = const <PredictHistoryModel>[],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  PredictHistoryState copyWith({
    List<PredictHistoryModel>? histories,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PredictHistoryState(
      histories: histories ?? this.histories,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GetPredictHistoryNotifier extends AsyncNotifier<PredictHistoryState> {
  static const int _pageSize = 10;

  late final PredictService _predictService;

  @override
  Future<PredictHistoryState> build() async {
    _predictService = ref.read(predictionServiceProvider);
    return _loadPage(page: 1, seed: const <PredictHistoryModel>[]);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncValue.loading();
    } else {
      state = AsyncValue.data(
        current.copyWith(isRefreshing: true, clearError: true),
      );
    }

    try {
      final nextState = await _loadPage(
        page: 1,
        seed: const <PredictHistoryModel>[],
      );
      state = AsyncValue.data(nextState);
    } catch (e, st) {
      log('Refresh predict history failed: $e');
      if (current == null) {
        state = AsyncValue.error(e, st);
      } else {
        state = AsyncValue.data(
          current.copyWith(isRefreshing: false, errorMessage: _messageFrom(e)),
        );
      }
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(isLoadingMore: true, clearError: true),
    );

    final userId = ref.read(supabase).auth.currentUser?.id;

    try {
      final nextPage = current.page + 1;
      final histories = await _predictService.getAllHistory(
        page: nextPage,
        limit: _pageSize,
        userId: userId!,
      );

      final updated = current.copyWith(
        histories: [...current.histories, ...histories],
        page: nextPage,
        hasMore: histories.length == _pageSize,
        isLoadingMore: false,
        isRefreshing: false,
        clearError: true,
      );

      state = AsyncValue.data(updated);
    } catch (e) {
      log('Load more predict history failed: $e');
      state = AsyncValue.data(
        current.copyWith(isLoadingMore: false, errorMessage: _messageFrom(e)),
      );
    }
  }

  Future<PredictHistoryState> _loadPage({
    required int page,
    required List<PredictHistoryModel> seed,
  }) async {
    final userId = ref.read(supabase).auth.currentUser?.id;
    final histories = await _predictService.getAllHistory(
      page: page,
      limit: _pageSize,
      userId: userId!,
    );

    return PredictHistoryState(
      histories: [...seed, ...histories],
      page: page,
      hasMore: histories.length == _pageSize,
    );
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}

final getPredictHistoryNotifierProvider =
    AsyncNotifierProvider<GetPredictHistoryNotifier, PredictHistoryState>(
      GetPredictHistoryNotifier.new,
    );
