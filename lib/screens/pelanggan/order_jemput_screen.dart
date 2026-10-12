import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/layanan.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';

class OrderJemputScreen extends StatefulWidget {
  const OrderJemputScreen({super.key});

  @override
  State<OrderJemputScreen> createState() => _OrderJemputScreenState();
}

class _OrderJemputScreenState extends State<OrderJemputScreen> {
  Layanan? _dipilih;
  late final TextEditingController _alamatCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final pelanggan = context.read<DataService>().currentPelanggan!;
    _alamatCtrl = TextEditingController(text: pelanggan.alamat);
  }

  @override
  void dispose() {
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_dipilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis layanan terlebih dahulu')),
      );
      return;
    }
    if (_alamatCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat penjemputan wajib diisi')),
      );
      return;
    }
    setState(() => _loading = true);
    final err = await context.read<DataService>().buatPesanan(
          idLayanan: _dipilih!.idLayanan,
          alamatJemput: _alamatCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Pesanan dibuat, kurir akan segera ditugaskan')),
    );
    if (err == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final layananList = context.watch<DataService>().daftarLayanan;

    return Scaffold(
      appBar: AppBar(title: const Text('Order jemput')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LoadingButton(
            label: 'Buat pesanan',
            icon: Icons.check_circle_outline,
            loading: _loading,
            onPressed: _submit,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionTitle('Pilih layanan'),
          if (layananList.isEmpty)
            const MessageBox(
              'Belum ada layanan tersedia. Hubungi admin.',
              color: AppColors.amber,
              icon: Icons.info_outline,
            ),
          for (final l in layananList)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LayananTile(
                layanan: l,
                dipilih: _dipilih?.idLayanan == l.idLayanan,
                onTap: () => setState(() => _dipilih = l),
              ),
            ),
          const SizedBox(height: 14),
          const SectionTitle('Alamat penjemputan'),
          TextField(
            controller: _alamatCtrl,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Alamat lengkap, patokan, nomor rumah',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tagihan dihitung dari berat cucian setelah kurir menimbangnya.',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _LayananTile extends StatelessWidget {
  final Layanan layanan;
  final bool dipilih;
  final VoidCallback onTap;
  const _LayananTile({required this.layanan, required this.dipilih, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: dipilih ? AppColors.mist : Colors.white,
      borderColor: dipilih ? AppColors.teal : AppColors.line,
      borderWidth: dipilih ? 1.8 : 1,
      child: Row(
        children: [
          Icon(
            dipilih ? Icons.check_circle : Icons.circle_outlined,
            color: dipilih ? AppColors.teal : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(layanan.namaLayanan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      'Estimasi ${layanan.estimasiWaktu}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rupiah(layanan.hargaPerKg),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal),
              ),
              const Text('per kg', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
