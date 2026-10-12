import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pesanan.dart';
import '../../models/user_models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';
import '../auth/role_select_screen.dart';
import 'detail_tugas_screen.dart';

class HomeKurirScreen extends StatelessWidget {
  const HomeKurirScreen({super.key});

  /// Langkah berikutnya untuk kurir pada tiap tahap.
  String _langkah(Pesanan p) {
    switch (p.statusPesanan) {
      case StatusPesanan.menunggu:
        return 'Menunggu penugasan';
      case StatusPesanan.dijemput:
        return 'Jemput & timbang cucian';
      case StatusPesanan.diproses:
        return p.pembayaran?.statusVerifikasi == StatusVerifikasi.valid
            ? 'Siap diantar'
            : 'Menunggu pembayaran pelanggan';
      case StatusPesanan.diantar:
        return 'Antar ke pelanggan';
      case StatusPesanan.selesai:
        return 'Selesai';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final kurir = data.currentKurir!;
    final tugas = data.tugasKurir();
    final aktif = tugas.where((p) => p.statusPesanan != StatusPesanan.selesai).length;
    final tersedia = kurir.statusKurir == StatusKurir.tersedia;

    return Scaffold(
      body: Column(
        children: [
          HeaderBar(
            title: 'Halo, ${kurir.nama.split(' ').first}',
            subtitle: aktif > 0 ? '$aktif tugas belum selesai' : 'Belum ada tugas untukmu',
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
            bottom: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: tersedia ? const Color(0xFF7CF0A6) : const Color(0xFFFFC857),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kurir.statusKurir.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<DataService>().refresh(),
              child: tugas.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 60),
                        EmptyState(
                          icon: Icons.two_wheeler,
                          title: 'Belum ada tugas',
                          message: 'Tugas jemput dan antar akan muncul di sini saat admin menugaskanmu.',
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                      children: [
                        const SectionTitle('Tugas kamu'),
                        for (final p in tugas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TugasCard(
                              pesanan: p,
                              namaLayanan: data.layananById(p.idLayanan).namaLayanan,
                              langkah: _langkah(p),
                            ),
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

class _TugasCard extends StatelessWidget {
  final Pesanan pesanan;
  final String namaLayanan;
  final String langkah;
  const _TugasCard({required this.pesanan, required this.namaLayanan, required this.langkah});

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailTugasScreen(pesananId: p.idPesanan)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$namaLayanan • #${p.idPesanan}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(status: p.statusPesanan),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(p.alamatJemput, style: const TextStyle(fontSize: 13.5, height: 1.35)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusBar(status: p.statusPesanan),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  langkah,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
