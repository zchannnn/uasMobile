import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/layanan.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_widgets.dart';

class KelolaLayananScreen extends StatelessWidget {
  const KelolaLayananScreen({super.key});

  Future<void> _bukaForm(BuildContext context, {Layanan? layanan}) async {
    final messenger = ScaffoldMessenger.of(context);
    final berhasil = await showDialog<bool>(
      context: context,
      builder: (_) => _FormLayananDialog(layanan: layanan),
    );
    if (berhasil == true) {
      messenger.showSnackBar(
        SnackBar(content: Text(layanan == null ? 'Layanan ditambahkan' : 'Layanan diperbarui')),
      );
    }
  }

  Future<void> _hapus(BuildContext context, Layanan l) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = context.read<DataService>();
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus layanan?'),
        content: Text('"${l.namaLayanan}" akan dihapus dari daftar layanan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    final err = await service.hapusLayanan(l.idLayanan);
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Layanan dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    final layananList = context.watch<DataService>().daftarLayanan;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola layanan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah layanan'),
      ),
      body: layananList.isEmpty
          ? const EmptyState(
              icon: Icons.local_laundry_service_outlined,
              title: 'Belum ada layanan',
              message: 'Tambahkan layanan pertama agar pelanggan bisa memesan.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              children: [
                for (final l in layananList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                      child: Row(
                        children: [
                          const IconTile(Icons.local_laundry_service_outlined),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.namaLayanan, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '${rupiah(l.hargaPerKg)}/kg • estimasi ${l.estimasiWaktu}',
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ubah',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _bukaForm(context, layanan: l),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: () => _hapus(context, l),
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

class _FormLayananDialog extends StatefulWidget {
  final Layanan? layanan;
  const _FormLayananDialog({this.layanan});

  @override
  State<_FormLayananDialog> createState() => _FormLayananDialogState();
}

class _FormLayananDialogState extends State<_FormLayananDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _estimasiCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final l = widget.layanan;
    _namaCtrl = TextEditingController(text: l?.namaLayanan ?? '');
    _hargaCtrl = TextEditingController(text: l?.hargaPerKg.toString() ?? '');
    _estimasiCtrl = TextEditingController(text: l?.estimasiWaktu ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _estimasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final service = context.read<DataService>();
    final nama = _namaCtrl.text.trim();
    final harga = int.parse(_hargaCtrl.text.trim());
    final estimasi = _estimasiCtrl.text.trim();
    final l = widget.layanan;
    final err = l == null
        ? await service.tambahLayanan(nama, harga, estimasi)
        : await service.ubahLayanan(l.idLayanan, nama, harga, estimasi);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.layanan == null ? 'Tambah layanan' : 'Ubah layanan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              TextFormField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama layanan'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga per kg', prefixText: 'Rp '),
                validator: (v) {
                  final h = int.tryParse((v ?? '').trim());
                  return (h == null || h <= 0) ? 'Isi harga yang valid' : null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _estimasiCtrl,
                decoration: const InputDecoration(labelText: 'Estimasi waktu', hintText: 'mis. 2 hari'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                MessageBox(_error!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        SizedBox(
          width: 110,
          child: LoadingButton(label: 'Simpan', loading: _loading, onPressed: _simpan),
        ),
      ],
    );
  }
}
