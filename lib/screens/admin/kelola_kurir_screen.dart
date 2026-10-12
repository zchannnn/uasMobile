import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_models.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class KelolaKurirScreen extends StatelessWidget {
  const KelolaKurirScreen({super.key});

  Future<void> _tambah(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final nama = await showDialog<String>(
      context: context,
      builder: (_) => const _FormKurirDialog(),
    );
    if (nama != null) {
      messenger.showSnackBar(SnackBar(content: Text('Kurir $nama berhasil ditambahkan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final kurirList = data.daftarKurir;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola kurir')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambah(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah kurir'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataService>().refresh(),
        child: kurirList.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 60),
                  EmptyState(
                    icon: Icons.two_wheeler,
                    title: 'Belum ada kurir',
                    message: 'Tekan "Tambah kurir" untuk mendaftarkan kurir pertama.',
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                children: [
                  for (final k in kurirList)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            const IconTile(Icons.two_wheeler),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(k.nama, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(k.noHp, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Pill(
                              text: k.statusKurir.label,
                              color: k.statusKurir == StatusKurir.tersedia ? AppColors.success : AppColors.amber,
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

class _FormKurirDialog extends StatefulWidget {
  const _FormKurirDialog();

  @override
  State<_FormKurirDialog> createState() => _FormKurirDialogState();
}

class _FormKurirDialogState extends State<_FormKurirDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _sembunyi = true;
  String? _error;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final nama = _namaCtrl.text.trim();
    final err = await context.read<DataService>().tambahKurir(
          nama: nama,
          noHp: _hpCtrl.text.trim(),
          password: _passCtrl.text,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    Navigator.pop(context, nama);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah kurir'),
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
                decoration: const InputDecoration(labelText: 'Nama kurir'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _hpCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. HP',
                  helperText: 'Dipakai kurir untuk login',
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'No. HP wajib diisi';
                  if (!RegExp(r'^[0-9+]{9,15}$').hasMatch(s)) return 'No. HP tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passCtrl,
                obscureText: _sembunyi,
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  helperText: 'Minimal 6 karakter',
                  suffixIcon: IconButton(
                    icon: Icon(_sembunyi ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _sembunyi = !_sembunyi),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
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
