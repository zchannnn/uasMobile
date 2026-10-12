import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_scaffold.dart';
import '../pelanggan/home_pelanggan_screen.dart';
import 'register_pelanggan_screen.dart';

class LoginPelangganScreen extends StatefulWidget {
  const LoginPelangganScreen({super.key});

  @override
  State<LoginPelangganScreen> createState() => _LoginPelangganScreenState();
}

class _LoginPelangganScreenState extends State<LoginPelangganScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sembunyi = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<DataService>().loginPelanggan(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePelangganScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.person_outline,
      title: 'Selamat datang',
      subtitle: 'Masuk untuk memesan jemput cucian',
      children: [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passCtrl,
          obscureText: _sembunyi,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!_loading) _login();
          },
          decoration: InputDecoration(
            labelText: 'Kata sandi',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_sembunyi ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _sembunyi = !_sembunyi),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          MessageBox(_error!),
        ],
        const SizedBox(height: 24),
        LoadingButton(label: 'Masuk', loading: _loading, onPressed: _login),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPelangganScreen()),
          ),
          child: const Text('Belum punya akun? Daftar sekarang'),
        ),
      ],
    );
  }
}
