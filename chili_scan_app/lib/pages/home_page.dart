import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_ScanHistoryItem> _historyItems = const [
    _ScanHistoryItem(
      title: 'Matang',
      description: 'Cabai siap dipanen dengan tingkat kepedasan tinggi.',
      statusLabel: 'Siap Panen',
      timestamp: '2 jam lalu',
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      statusColor: Color(0xFFE63B2E),
    ),
    _ScanHistoryItem(
      title: 'Belum Matang',
      description: 'Masih muda, cocok untuk olahan tumis dan sambal segar.',
      statusLabel: 'Belum Matang',
      timestamp: 'Kemarin',
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      statusColor: Color(0xFF3F8CFF),
    ),
    _ScanHistoryItem(
      title: 'Setengah Matang',
      description:
          'Sedang dalam proses pematangan, perawatan ekstra disarankan.',
      statusLabel: 'Setengah Matang',
      timestamp: '3 hari lalu',
      imageUrl:
          'https://png.pngtree.com/thumb_back/fh260/background/20221022/pngtree-plant-hot-pepper-plant-green-image-photo-image_1274814.jpg',
      statusColor: Color(0xFFF0BC00),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(textTheme),
                _buildQuickActions(),
                _buildStatsRow(),
                _buildSectionHeader(
                  title: 'Riwayat Scan',
                  actionLabel: 'Lihat Semua',
                  onActionTap: () {},
                ),
                _buildHistoryList(),

                // _buildTipsCard(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/300?img=5',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Bagusokz!',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tanamanmu terlihat sehat. Ayo cek hasil scan terbaru.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/scanner');
            },
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Mulai Scan Cepat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.camera_alt_rounded,
            title: 'Kamera',
            subtitle: 'Ambil gambar baru',
            color: primaryColor,
            onTap: () {
              context.push('/scanner');
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.photo_library_rounded,
            title: 'Galeri',
            subtitle: 'Pilih dari album',
            color: const Color(0xFF00C49A),
            onTap: () {
              context.push('/scanner');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        _StatCard(
          label: 'Total Scan',
          value: '128',
          icon: Icons.scatter_plot_rounded,
          color: Color(0xFF4A90E2),
        ),
        _StatCard(
          label: 'Matang',
          value: '64',
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFE63B2E),
        ),
        _StatCard(
          label: 'Belum Matang',
          value: '12',
          icon: Icons.error_outline_rounded,
          color: Color(0xFFF0BC00),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(onPressed: onActionTap, child: Text(actionLabel)),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _historyItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return _ScanHistoryCard(item: item);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
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
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ScanHistoryCard extends StatelessWidget {
  const _ScanHistoryCard({required this.item});

  final _ScanHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.network(
            item.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),

          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.statusColor.withValues(alpha: 90),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  item.timestamp,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHistoryItem {
  const _ScanHistoryItem({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.timestamp,
    required this.imageUrl,
    required this.statusColor,
  });

  final String title;
  final String description;
  final String statusLabel;
  final String timestamp;
  final String imageUrl;
  final Color statusColor;
}
