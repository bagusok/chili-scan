import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/providers/get_predict_history_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(getPredictHistoryNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(getPredictHistoryNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: historyState.when(
          data: _buildHistoryContent,
          error: (error, _) => _buildErrorState(error.toString()),
          loading: () => _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(PredictHistoryState state) {
    final histories = state.histories;

    final children = <Widget>[];

    if (histories.isEmpty && !state.isRefreshing) {
      children.add(_buildEmptyState());
    } else {
      children.addAll(_buildGroupedHistory(histories));
    }

    if (state.isLoadingMore) {
      children.add(_buildLoadMoreIndicator());
    }

    if (state.errorMessage != null) {
      children.add(_buildErrorBanner(state.errorMessage!));
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(getPredictHistoryNotifierProvider.notifier).refresh(),
        color: primaryColor,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: children,
        ),
      ),
    );
  }

  List<Widget> _buildGroupedHistory(List<PredictHistoryModel> histories) {
    final grouped = <String, List<PredictHistoryModel>>{};
    for (final history in histories) {
      final label = _dateLabel(history.createdAt);
      grouped.putIfAbsent(label, () => <PredictHistoryModel>[]).add(history);
    }

    return grouped.entries
        .map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...entry.value.map(_buildHistoryCard),
              const SizedBox(height: 24),
            ],
          ),
        )
        .toList();
  }

  Widget _buildHistoryCard(PredictHistoryModel history) {
    final status = _statusLabel(history);
    final statusColor = _statusColor(status);
    final timestamp = _timeLabel(history.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: _buildThumbnail(history.imageUrl),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timestamp,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _titleFor(history),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(history),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: history.id == null
                        ? null
                        : () => context.go(
                            '/history/detail/${history.id}',
                            extra: history,
                          ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: primaryColor,
                    ),
                    child: const Text('Lihat detail'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    final placeholder = Container(
      width: 110,
      height: 130,
      color: const Color(0xFFF1F1F5),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.black38),
    );

    if (url == null || url.isEmpty) {
      return placeholder;
    }

    return Image.network(
      url,
      width: 110,
      height: 130,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 110,
          height: 130,
          color: const Color(0xFFF1F1F5),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.history, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'Belum ada riwayat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Hasil prediksi terakhir akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(getPredictHistoryNotifierProvider.notifier).refresh(),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat riwayat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(getPredictHistoryNotifierProvider.notifier)
                  .refresh(),
              child: const Text('Muat ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  String _titleFor(PredictHistoryModel history) {
    final primary = history.svmResult ?? history.knnResult;
    if (primary == null || primary.isEmpty) {
      return 'Prediksi tidak tersedia';
    }
    return 'Prediksi: ${_localizeStatus(primary)}';
  }

  String _subtitleFor(PredictHistoryModel history) {
    final stats = history.statistics;
    final confidence = stats?.svm?.confidence ?? stats?.knn?.confidence;
    final duration = stats?.svm?.durationMs ?? stats?.knn?.durationMs;

    if (confidence != null && duration != null) {
      return 'Kepercayaan ${_formatPercentage(confidence)} · $duration ms';
    }
    if (confidence != null) {
      return 'Kepercayaan ${_formatPercentage(confidence)}';
    }
    if (duration != null) {
      return 'Durasi $duration ms';
    }
    if (history.knnResult != null) {
      return 'KNN: ${_localizeStatus(history.knnResult!)}';
    }
    return 'Tidak ada detail tambahan';
  }

  String _statusLabel(PredictHistoryModel history) {
    final raw = history.svmResult ?? history.knnResult ?? 'Tidak diketahui';
    return _localizeStatus(raw);
  }

  String _localizeStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'matang':
      case 'ripe':
        return 'Matang';
      case 'belum matang':
      case 'unripe':
        return 'Belum Matang';
      case 'setengah matang':
      case 'half-ripe':
      case 'half ripe':
        return 'Setengah Matang';
      default:
        return raw.isEmpty ? 'Tidak diketahui' : raw;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'matang':
        return const Color(0xFF0FB37C);
      case 'belum matang':
        return const Color(0xFFFD8B51);
      case 'setengah matang':
        return const Color(0xFF7C4DFF);
      default:
        return Colors.black45;
    }
  }

  String _dateLabel(String? isoString) {
    final date = _parseDate(isoString);
    if (date == null) return 'Tanggal tidak diketahui';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDate(target, today)) return 'Hari ini';
    if (_isSameDate(target, yesterday)) return 'Kemarin';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  String _timeLabel(String? isoString) {
    final date = _parseDate(isoString);
    if (date == null) return '--:--';
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  DateTime? _parseDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    return DateTime.tryParse(isoString)?.toLocal();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatPercentage(double value) {
    final percent = (value * 100).clamp(0, 100).toStringAsFixed(1);
    return '$percent%';
  }
}
