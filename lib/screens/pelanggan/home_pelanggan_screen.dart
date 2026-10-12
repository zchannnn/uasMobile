import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/layanan.dart';
import '../../models/pesanan.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';
import '../auth/role_select_screen.dart';
import 'order_jemput_screen.dart';
import 'detail_pesanan_screen.dart';

class HomePelangganScreen extends StatelessWidget {
  const HomePelangganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final pelanggan = data.currentPelanggan!;
    final pesananList = data.pesananMilikPelanggan();
    final aktif = pesananList.where((p) => p.statusPesanan != StatusPesanan.selesai).length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderJemputScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Order jemput'),
      ),
      body: Column(
        children: [
          HeaderBar(
            title: 'Halo, ${pelanggan.nama.split(' ').first}',
            subtitle: aktif > 0 ? '$aktif pesanan sedang berjalan' : 'Mau cuci apa hari ini?',
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
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<DataService>().refresh(),
              child: pesananList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 60),
                        EmptyState(
                          icon: Icons.local_laundry_service_outlined,
                          title: 'Belum ada pesanan',
                          message: 'Tekan "Order jemput" dan kurir akan datang mengambil cucianmu.',
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
                      children: [
                        const SectionTitle('Pesanan kamu'),
                        for (final p in pesananList)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PesananCard(pesanan: p, layanan: data.layananById(p.idLayanan)),
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

class _PesananCard extends StatelessWidget {
  final Pesanan pesanan;
  final Layanan layanan;
  const _PesananCard({required this.pesanan, required this.layanan});

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPesananScreen(pesananId: p.idPesanan)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconTile(Icons.local_laundry_service_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(layanan.namaLayanan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      'Pesanan #${p.idPesanan} • ${tanggal(p.tanggalPesan)}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: p.statusPesanan),
            ],
          ),
          const SizedBox(height: 16),
          StatusBar(status: p.statusPesanan),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.beratKg > 0 ? beratKg(p.beratKg) : 'Menunggu ditimbang kurir',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              Text(
                p.totalBayar > 0 ? rupiah(p.totalBayar) : '-',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
