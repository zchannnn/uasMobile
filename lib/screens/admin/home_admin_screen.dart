import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pesanan.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../auth/role_select_screen.dart';
import 'kelola_layanan_screen.dart';
import 'kelola_kurir_screen.dart';
import 'tugaskan_kurir_screen.dart';
import 'verifikasi_pembayaran_screen.dart';
import 'laporan_transaksi_screen.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final admin = data.currentAdmin!;
    final semua = data.semuaPesanan;

    final perluKurir = semua.where((p) => p.statusPesanan == StatusPesanan.menunggu).length;
    final perluVerifikasi =
        semua.where((p) => p.pembayaran?.statusVerifikasi == StatusVerifikasi.menunggu).length;
    final berjalan = semua.where((p) => p.statusPesanan != StatusPesanan.selesai).length;

    final menu = [
      _MenuItem(
        'Tugaskan kurir',
        'Pilih kurir untuk pesanan baru',
        Icons.assignment_ind_outlined,
        const TugaskanKurirScreen(),
        badge: perluKurir,
      ),
      _MenuItem(
        'Verifikasi pembayaran',
        'Periksa pembayaran dari pelanggan',
        Icons.verified_outlined,
        const VerifikasiPembayaranScreen(),
        badge: perluVerifikasi,
      ),
      _MenuItem('Kelola layanan', 'Atur jenis layanan & harga per kg', Icons.local_laundry_service_outlined,
          const KelolaLayananScreen()),
      _MenuItem('Kelola kurir', 'Daftarkan kurir & lihat statusnya', Icons.two_wheeler, const KelolaKurirScreen()),
      _MenuItem('Laporan transaksi', 'Ringkasan pembayaran masuk', Icons.bar_chart_rounded,
          const LaporanTransaksiScreen()),
    ];

    return Scaffold(
      body: Column(
        children: [
          HeaderBar(
            title: 'Dashboard admin',
            subtitle: admin.nama,
            actions: [
              HeaderAction(
                icon: Icons.logout,
                tooltip: 'Keluar',
                onPressed: () {
                  context.read<DataService>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
            bottom: Row(
              children: [
                Expanded(child: HeaderStat(value: '$perluKurir', label: 'Perlu kurir')),
                const SizedBox(width: 10),
                Expanded(child: HeaderStat(value: '$perluVerifikasi', label: 'Perlu verifikasi')),
                const SizedBox(width: 10),
                Expanded(child: HeaderStat(value: '$berjalan', label: 'Pesanan berjalan')),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<DataService>().refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                children: [
                  const SectionTitle('Menu'),
                  for (final m in menu)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MenuTile(item: m),
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

class _MenuItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  final int badge;
  _MenuItem(this.label, this.subtitle, this.icon, this.screen, {this.badge = 0});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconTile(item.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(item.subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
              ],
            ),
          ),
          if (item.badge > 0)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(12)),
              child: Text(
                '${item.badge}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
