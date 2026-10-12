import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/pesanan.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';

class DetailPesananScreen extends StatelessWidget {
  final int pesananId;
  const DetailPesananScreen({super.key, required this.pesananId});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final pesanan = data.semuaPesanan.firstWhere((p) => p.idPesanan == pesananId);
    final layanan = data.layananById(pesanan.idLayanan);
    final kurir = data.kurirById(pesanan.idKurir);

    final perluBayar = pesanan.totalBayar > 0 &&
        (pesanan.pembayaran == null || pesanan.pembayaran!.statusVerifikasi == StatusVerifikasi.tidakValid);

    return Scaffold(
      appBar: AppBar(title: Text('Pesanan #${pesanan.idPesanan}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        layanan.namaLayanan,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                    ),
                    StatusBadge(status: pesanan.statusPesanan),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tanggalWaktu(pesanan.tanggalPesan), style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 4),
                InfoRow(icon: Icons.location_on_outlined, label: 'Alamat jemput', value: pesanan.alamatJemput),
                InfoRow(icon: Icons.two_wheeler, label: 'Kurir', value: kurir?.nama ?? 'Belum ditugaskan'),
                InfoRow(
                  icon: Icons.scale_outlined,
                  label: 'Berat cucian',
                  value: pesanan.beratKg > 0 ? beratKg(pesanan.beratKg) : 'Belum ditimbang',
                ),
                if (pesanan.totalBayar > 0)
                  InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total tagihan',
                    value: rupiah(pesanan.totalBayar),
                    emphasize: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (perluBayar) ...[
            _KartuBayar(pesanan: pesanan),
            const SizedBox(height: 16),
          ],
          if (pesanan.pembayaran != null) ...[
            _KartuStatusBayar(pesanan: pesanan),
            const SizedBox(height: 16),
          ],
          AppCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Perjalanan cucianmu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                StatusTimeline(status: pesanan.statusPesanan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuBayar extends StatefulWidget {
  final Pesanan pesanan;
  const _KartuBayar({required this.pesanan});

  @override
  State<_KartuBayar> createState() => _KartuBayarState();
}

class _KartuBayarState extends State<_KartuBayar> {
  MetodeBayar _metode = MetodeBayar.transfer;
  bool _loading = false;

  Future<void> _bayar() async {
    setState(() => _loading = true);
    final err = await context.read<DataService>().bayarPesanan(widget.pesanan, _metode);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Pembayaran terkirim, menunggu verifikasi admin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFFFFF7E6),
      borderColor: const Color(0xFFF3D9A4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Saatnya membayar', style: TextStyle(fontSize: 13, color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            rupiah(widget.pesanan.totalBayar),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const Text('Metode pembayaran', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MetodeBayar.values.map((m) {
              final aktif = _metode == m;
              return ChoiceChip(
                label: Text(m.label),
                selected: aktif,
                onSelected: (_) => setState(() => _metode = m),
                showCheckmark: false,
                selectedColor: AppColors.teal,
                backgroundColor: Colors.white,
                side: BorderSide(color: aktif ? AppColors.teal : AppColors.line),
                labelStyle: TextStyle(
                  color: aktif ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          LoadingButton(label: 'Bayar sekarang', icon: Icons.lock_outline, loading: _loading, onPressed: _bayar),
        ],
      ),
    );
  }
}

class _KartuStatusBayar extends StatelessWidget {
  final Pesanan pesanan;
  const _KartuStatusBayar({required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final bayar = pesanan.pembayaran!;
    final warna = warnaVerifikasi(bayar.statusVerifikasi);

    late final IconData ikon;
    late final String judul;
    switch (bayar.statusVerifikasi) {
      case StatusVerifikasi.valid:
        ikon = Icons.verified_outlined;
        judul = 'Pembayaran terverifikasi';
        break;
      case StatusVerifikasi.menunggu:
        ikon = Icons.hourglass_top;
        judul = 'Menunggu verifikasi admin';
        break;
      case StatusVerifikasi.tidakValid:
        ikon = Icons.error_outline;
        judul = 'Pembayaran ditolak, silakan bayar ulang';
        break;
    }

    return AppCard(
      child: Row(
        children: [
          IconTile(ikon, color: warna),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  '${bayar.metodeBayar.label} • ${rupiah(bayar.jumlahBayar)}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
