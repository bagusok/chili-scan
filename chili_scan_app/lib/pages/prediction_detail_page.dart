import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/models/predict_history_model.dart';
import 'package:chili_scan_app/providers/predict_history_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredictionDetailPage extends ConsumerStatefulWidget {
  const PredictionDetailPage({
    super.key,
    required this.historyId,
    this.initialHistory,
  });

  const PredictionDetailPage.missing({super.key})
    : historyId = '',
      initialHistory = null;

  final String historyId;
  final PredictHistoryModel? initialHistory;

  @override
  ConsumerState<PredictionDetailPage> createState() =>
      _PredictionDetailPageState();
}

class _PredictionDetailPageState extends ConsumerState<PredictionDetailPage> {
  PredictHistoryModel? _cachedHistory;

  @override
  void initState() {
    super.initState();
    _cachedHistory = widget.initialHistory;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historyId.isEmpty) {
      return _buildMissingState(context);
    }

    final provider = predictHistoryDetailProvider(widget.historyId);
    final asyncHistory = ref.watch(provider);
    asyncHistory.whenData((history) {
      _cachedHistory = history;
    });

    void retry() => ref.invalidate(provider);
    final inlineError = asyncHistory.maybeWhen(
      error: (error, _) => error.toString(),
      orElse: () => null,
    );

    if (_cachedHistory == null) {
      return asyncHistory.when(
        data: (history) =>
            _buildDetailScaffold(context, history, onRefresh: retry),
        loading: () => _buildPureLoadingState(),
        error: (error, _) => _buildErrorState(context, retry, error.toString()),
      );
    }

    return _buildDetailScaffold(
      context,
      _cachedHistory!,
      onRefresh: retry,
      inlineError: inlineError,
      showLinearLoading: asyncHistory is AsyncLoading,
    );
  }

  Widget _buildDetailScaffold(
    BuildContext context,
    PredictHistoryModel record, {
    VoidCallback? onRefresh,
    String? inlineError,
    bool showLinearLoading = false,
  }) {
    final status = _statusLabel(record);
    final statusColor = _statusColor(status);
    final dateLabel = _dateLabel(record.createdAt);
    final timeLabel = _timeLabel(record.createdAt);

    final children = <Widget>[
      if (inlineError != null) _buildInlineErrorBanner(inlineError, onRefresh),
      _buildHeroSection(record, status, statusColor, dateLabel, timeLabel),
      const SizedBox(height: 16),
      _buildSummaryCard(status, statusColor, dateLabel, timeLabel),
      const SizedBox(height: 16),
      _buildResultSection(
        title: 'Metode Support Vector Machine',
        result: record.svmResult,
        stats: record.statistics?.svm,
      ),
      const SizedBox(height: 16),
      _buildResultSection(
        title: 'Metode K-Nearest Neighbor',
        result: record.knnResult,
        stats: record.statistics?.knn,
      ),
      const SizedBox(height: 16),
      _buildMetaSection(record),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Prediksi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: 'Muat ulang',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
              if (showLinearLoading)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(minHeight: 4),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPureLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Prediksi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    VoidCallback onRetry,
    String message,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Prediksi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
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
              const Text(
                'Gagal memuat detail prediksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissingState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Prediksi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.black26),
            const SizedBox(height: 12),
            const Text(
              'Data tidak ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Silakan kembali ke halaman riwayat dan pilih prediksi lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineErrorBanner(String message, VoidCallback? onRetry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    PredictHistoryModel record,
    String status,
    Color statusColor,
    String dateLabel,
    String timeLabel,
  ) {
    final placeholder = Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F5),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 48, color: Colors.black38),
    );

    final image = record.imageUrl;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: image == null || image.isEmpty
              ? placeholder
              : Image.network(
                  image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          left: 20,
          top: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String status,
    Color statusColor,
    String dateLabel,
    String timeLabel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Prediksi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    timeLabel,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection({
    required String title,
    String? result,
    PredictHistoryKnn? stats,
  }) {
    final status = result == null || result.isEmpty
        ? 'Tidak tersedia'
        : _localizeStatus(result);
    final hasData = result != null && result.isNotEmpty;
    final confidence = stats?.confidence;
    final duration = stats?.durationMs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: hasData ? primaryColor : Colors.black38,
            ),
          ),
          const SizedBox(height: 12),
          if (confidence != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Tingkat kepercayaan'),
                    const Spacer(),
                    Text(_formatPercentage(confidence)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (confidence).clamp(0, 1),
                    color: primaryColor,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  label: 'Kepercayaan',
                  value: confidence != null
                      ? _formatPercentage(confidence)
                      : '--',
                  icon: Icons.insights_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricTile(
                  label: 'Durasi',
                  value: duration != null ? '$duration ms' : '--',
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8F0)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaSection(PredictHistoryModel record) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Teknis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _metaRow('ID Prediksi', record.id ?? '-'),
          _metaRow('Pengguna', record.userId ?? '-'),
          _metaRow('Sumber Gambar', record.imageUrl ?? '-'),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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

  String _formatPercentage(double value) {
    final percent = (value * 100).clamp(0, 100).toStringAsFixed(1);
    return '$percent%';
  }
}
