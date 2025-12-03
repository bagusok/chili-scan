import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<_ScanRecord> _records = const [
    _ScanRecord(
      title: 'Cabai Merah Keriting',
      subtitle: 'Matang sempurna, cocok untuk sambal.',
      status: 'Matang',
      statusColor: Color(0xFFE63B2E),
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      timestamp: '08:45',
      dateLabel: 'Hari ini',
    ),
    _ScanRecord(
      title: 'Cabai Hijau Besar',
      subtitle: 'Belum matang, simpan di tempat teduh.',
      status: 'Belum Matang',
      statusColor: Color(0xFF3F8CFF),
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      timestamp: '07:15',
      dateLabel: 'Hari ini',
    ),
    _ScanRecord(
      title: 'Cabai Rawit',
      subtitle: 'Perlu perawatan, terlihat mengering.',
      status: 'Setengah Matang',
      statusColor: Color(0xFFF0BC00),
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      timestamp: '21:10',
      dateLabel: 'Kemarin',
    ),
    _ScanRecord(
      title: 'Cabai Merah Besar',
      subtitle: 'Matang merata, kadar air ideal.',
      status: 'Matang',
      statusColor: Color(0xFFE63B2E),
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      timestamp: '18:05',
      dateLabel: 'Kemarin',
    ),
  ];

  final List<String> _filters = const [
    'Semua',
    'Matang',
    'Belum Matang',
    'Setengah Matang',
  ];
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              _buildFilterChips(),
              const SizedBox(height: 24),
              ..._buildGroupedHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters
          .map(
            (filter) => ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: primaryColor.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: _selectedFilter == filter
                    ? primaryColor
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildGroupedHistory() {
    final filtered = _selectedFilter == 'Semua'
        ? _records
        : _records.where((r) => r.status == _selectedFilter).toList();

    final Map<String, List<_ScanRecord>> grouped = {};
    for (final record in filtered) {
      grouped.putIfAbsent(record.dateLabel, () => []).add(record);
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
              ...entry.value.map((record) => _HistoryCard(record: record)),
              const SizedBox(height: 24),
            ],
          ),
        )
        .toList();
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final _ScanRecord record;

  @override
  Widget build(BuildContext context) {
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
            child: Image.network(
              record.imageUrl,
              width: 110,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: record.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          record.status,
                          style: TextStyle(
                            color: record.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        record.timestamp,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    record.subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
}

class _ScanRecord {
  const _ScanRecord({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.imageUrl,
    required this.timestamp,
    required this.dateLabel,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String imageUrl;
  final String timestamp;
  final String dateLabel;
}
