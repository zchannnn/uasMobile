import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/pesanan.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';

class VerifikasiPembayaranScreen extends StatelessWidget {
  const VerifikasiPembayaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final perluVerifikasi = data.semuaPesanan
        .where((p) => p.pembayaran != null && p.pembayaran!.statusVerifikasi == StatusVerifikasi.menunggu)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi pembayaran')),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataService>().refresh(),
        child: perluVerifikasi.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 60),
                  EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'Tidak ada yang perlu diverifikasi',
                    message: 'Pembayaran baru dari pelanggan akan muncul di sini.',
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                children: [
                  for (final p in perluVerifikasi)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _VerifikasiCard(pesanan: p),
                    ),
                ],
              ),
      ),
    );
  }
}

class _VerifikasiCard extends StatefulWidget {
  final Pesanan pesanan;
  const _VerifikasiCard({required this.pesanan});

  @override
  State<_VerifikasiCard> createState() => _VerifikasiCardState();
}

class _VerifikasiCardState extends State<_VerifikasiCard> {
  bool _busy = false;

  Future<void> _verifikasi(bool valid) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final err = await context.read<DataService>().verifikasiPembayaran(widget.pesanan, valid);
    if (mounted) setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(content: Text(err ?? (valid ? 'Pembayaran ditandai valid' : 'Pembayaran ditandai tidak valid'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pesanan;
    final bayar = p.pembayaran!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Pesanan #${p.idPesanan}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              VerifikasiBadge(status: bayar.statusVerifikasi),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${p.namaPelanggan ?? 'Pelanggan'} • ${tanggalWaktu(bayar.tanggalBayar)}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Text(rupiah(bayar.jumlahBayar), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('via ${bayar.metodeBayar.label}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4), width: 1.4),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Tidak valid'),
                  onPressed: _busy ? null : () => _verifikasi(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    disabledBackgroundColor: AppColors.success.withValues(alpha: 0.55),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Valid'),
                  onPressed: _busy ? null : () => _verifikasi(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
