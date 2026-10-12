import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_scaffold.dart';

class RegisterPelangganScreen extends StatefulWidget {
  const RegisterPelangganScreen({super.key});

  @override
  State<RegisterPelangganScreen> createState() => _RegisterPelangganScreenState();
}

class _RegisterPelangganScreenState extends State<RegisterPelangganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _noHp = TextEditingController();
  final _password = TextEditingController();
  final _alamat = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sembunyi = true;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _noHp.dispose();
    _password.dispose();
    _alamat.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<DataService>().registerPelanggan(
          nama: _nama.text.trim(),
          email: _email.text.trim(),
          noHp: _noHp.text.trim(),
          password: _password.text,
          alamat: _alamat.text.trim(),
        );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil, silakan login')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Buat akun',
      subtitle: 'Daftar sebagai pelanggan CleanGo',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nama lengkap', prefixIcon: Icon(Icons.badge_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noHp,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _sembunyi,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  helperText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_sembunyi ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _sembunyi = !_sembunyi),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _alamat,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Alamat penjemputan',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          MessageBox(_error!),
        ],
        const SizedBox(height: 24),
        LoadingButton(label: 'Daftar', loading: _loading, onPressed: _daftar),
      ],
    );
  }
}
