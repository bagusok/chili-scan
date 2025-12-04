import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({super.key});

  @override
  ConsumerState<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  void _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [Color(0xFFF8F5FF), Color(0xFFFFFBF5)],
            // ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              auth.when(
                data: (s) => _buildProfileHeader(
                  textTheme,
                  s.user?.userMetadata['name'] ?? 'User',
                ),
                error: (e, _) => Text('Error: $e'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 24),
              // _buildInfoCard(textTheme),
              // const SizedBox(height: 24),
              _buildSettingsList(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => {_logout()},
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(TextTheme textTheme, String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=52'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  userName,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
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
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Keamanan Akun',
            subtitle: 'Ubah password dan metode login',
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifikasi',
            subtitle: 'Kelola pengingat dan alert',
          ),
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Bantuan',
            subtitle: 'Pusat bantuan & kontak CS',
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
        if (title != 'Bantuan')
          const Divider(height: 0, indent: 72, endIndent: 16),
      ],
    );
  }
}
