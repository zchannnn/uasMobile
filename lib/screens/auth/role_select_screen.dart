import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'login_pelanggan_screen.dart';
import 'login_kurir_screen.dart';
import 'login_admin_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _buka(BuildContext context, Widget layar) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => layar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandMark(size: 96),
                      const SizedBox(height: 20),
                      const Text(
                        'CleanGo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cucian dijemput, dicuci bersih, diantar kembali.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.foam,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle('Masuk sebagai'),
                  _RoleTile(
                    icon: Icons.person_outline,
                    title: 'Pelanggan',
                    subtitle: 'Pesan jemput cucian & pantau statusnya',
                    onTap: () => _buka(context, const LoginPelangganScreen()),
                  ),
                  const SizedBox(height: 10),
                  _RoleTile(
                    icon: Icons.two_wheeler,
                    title: 'Kurir',
                    subtitle: 'Terima tugas jemput & antar',
                    onTap: () => _buka(context, const LoginKurirScreen()),
                  ),
                  const SizedBox(height: 10),
                  _RoleTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin',
                    subtitle: 'Kelola layanan, kurir & pembayaran',
                    onTap: () => _buka(context, const LoginAdminScreen()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconTile(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
