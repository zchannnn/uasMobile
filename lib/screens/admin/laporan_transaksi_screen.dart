import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';

class LaporanTransaksiScreen extends StatelessWidget {
  const LaporanTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final laporan = data.laporanTransaksi();
    final totalPendapatan = laporan.fold<int>(0, (sum, p) => sum + p.pembayaran!.jumlahBayar);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan transaksi')),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataService>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total pendapatan',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(totalPendapatan),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${laporan.length} transaksi',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('Riwayat'),
            if (laporan.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada transaksi',
                  message: 'Pembayaran dari pelanggan akan tercatat di sini.',
                ),
              ),
            for (final p in laporan)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const IconTile(Icons.receipt_long_outlined),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${p.idPesanan} • ${data.layananById(p.idLayanan).namaLayanan}',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tanggalWaktu(p.tanggalPesan),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rupiah(p.pembayaran!.jumlahBayar),
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          VerifikasiBadge(status: p.pembayaran!.statusVerifikasi),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
