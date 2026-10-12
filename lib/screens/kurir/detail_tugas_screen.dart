import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../models/pesanan.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/status_badge.dart';

class DetailTugasScreen extends StatefulWidget {
  final int pesananId;
  const DetailTugasScreen({super.key, required this.pesananId});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  final _beratCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _beratCtrl.dispose();
    super.dispose();
  }

  double? get _beratInput => double.tryParse(_beratCtrl.text.trim().replaceAll(',', '.'));

  Future<void> _simpanBerat(Pesanan pesanan) async {
    final berat = _beratInput;
    if (berat == null || berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan berat cucian yang valid')),
      );
      return;
    }
    setState(() => _busy = true);
    final err = await context.read<DataService>().inputBeratDanHitung(pesanan, berat);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Berat tersimpan, tagihan sudah dihitung')),
    );
  }

  Future<void> _ubahStatus(Pesanan pesanan, StatusPesanan status, {bool tutup = false}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final err = await context.read<DataService>().updateStatusPesananKurir(pesanan, status);
    if (mounted) setState(() => _busy = false);
    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
    } else if (tutup && mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final pesanan = data.semuaPesanan.firstWhere((p) => p.idPesanan == widget.pesananId);
    final layanan = data.layananById(pesanan.idLayanan);

    final berat = _beratInput;
    final perkiraan = (berat != null && berat > 0) ? (berat * layanan.hargaPerKg).round() : null;
    final bayarValid = pesanan.pembayaran?.statusVerifikasi == StatusVerifikasi.valid;

    return Scaffold(
      appBar: AppBar(title: Text('Tugas #${pesanan.idPesanan}')),
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
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 4),
                InfoRow(
                  icon: Icons.person_outline,
                  label: 'Pelanggan',
                  value: pesanan.namaPelanggan ?? '-',
                ),
                InfoRow(icon: Icons.location_on_outlined, label: 'Alamat jemput', value: pesanan.alamatJemput),
                if (pesanan.beratKg > 0)
                  InfoRow(icon: Icons.scale_outlined, label: 'Berat cucian', value: beratKg(pesanan.beratKg)),
                if (pesanan.totalBayar > 0)
                  InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total tagihan',
                    value: rupiah(pesanan.totalBayar),
                    emphasize: true,
                  ),
                const SizedBox(height: 8),
                StatusBar(status: pesanan.statusPesanan),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Tahap: dijemput -> timbang cucian
          if (pesanan.statusPesanan == StatusPesanan.dijemput)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Timbang cucian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Harga ${rupiah(layanan.hargaPerKg)} per kg',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _beratCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      labelText: 'Berat',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                  ),
                  if (perkiraan != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Perkiraan tagihan', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            rupiah(perkiraan),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.teal),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  LoadingButton(
                    label: 'Simpan berat & hitung tagihan',
                    icon: Icons.calculate_outlined,
                    loading: _busy,
                    onPressed: () => _simpanBerat(pesanan),
                  ),
                ],
              ),
            ),

          // --- Tahap: diproses -> tunggu bayar, lalu antar
          if (pesanan.statusPesanan == StatusPesanan.diproses) ...[
            if (bayarValid) ...[
              const MessageBox(
                'Pembayaran sudah terverifikasi. Cucian siap diantar.',
                color: AppColors.success,
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 14),
              LoadingButton(
                label: 'Antar cucian sekarang',
                icon: Icons.two_wheeler,
                loading: _busy,
                onPressed: () => _ubahStatus(pesanan, StatusPesanan.diantar),
              ),
            ] else
              const MessageBox(
                'Menunggu pelanggan membayar dan admin memverifikasi sebelum cucian bisa diantar.',
                color: AppColors.amber,
                icon: Icons.hourglass_top,
              ),
          ],

          // --- Tahap: diantar -> tandai selesai
          if (pesanan.statusPesanan == StatusPesanan.diantar)
            LoadingButton(
              label: 'Tandai selesai diantar',
              icon: Icons.check_circle_outline,
              loading: _busy,
              color: AppColors.success,
              onPressed: () => _ubahStatus(pesanan, StatusPesanan.selesai, tutup: true),
            ),

          if (pesanan.statusPesanan == StatusPesanan.selesai)
            const MessageBox(
              'Pesanan ini sudah selesai. Terima kasih!',
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
        ],
      ),
    );
  }
}
