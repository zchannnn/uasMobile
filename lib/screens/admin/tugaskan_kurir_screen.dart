import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/pesanan.dart';
import '../../models/user_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';

class TugaskanKurirScreen extends StatelessWidget {
  const TugaskanKurirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final menunggu = data.semuaPesanan.where((p) => p.statusPesanan == StatusPesanan.menunggu).toList();
    final kurirTersedia = data.daftarKurir.where((k) => k.statusKurir == StatusKurir.tersedia).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tugaskan kurir')),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataService>().refresh(),
        child: menunggu.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 60),
                  EmptyState(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Semua pesanan sudah ditugaskan',
                    message: 'Pesanan baru yang butuh kurir akan muncul di sini.',
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                children: [
                  for (final p in menunggu)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.layananById(p.idLayanan).namaLayanan} • #${p.idPesanan}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.namaPelanggan ?? 'Pelanggan'} • ${tanggalWaktu(p.tanggalPesan)}',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.muted),
                                const SizedBox(width: 8),
                                Expanded(child: Text(p.alamatJemput, style: const TextStyle(height: 1.35))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text('Pilih kurir', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                            const SizedBox(height: 8),
                            if (kurirTersedia.isEmpty)
                              const MessageBox(
                                'Tidak ada kurir tersedia saat ini.',
                                color: AppColors.amber,
                                icon: Icons.info_outline,
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kurirTersedia
                                    .map(
                                      (k) => ActionChip(
                                        label: Text(k.nama),
                                        avatar: const Icon(Icons.two_wheeler, size: 18, color: AppColors.teal),
                                        backgroundColor: AppColors.mist,
                                        side: BorderSide.none,
                                        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                                        onPressed: () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          final err = await context.read<DataService>().tugaskanKurir(p, k.idKurir);
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(err ?? '${k.nama} ditugaskan untuk pesanan #${p.idPesanan}'),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
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
