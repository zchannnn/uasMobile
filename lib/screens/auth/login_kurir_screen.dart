import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_scaffold.dart';
import '../kurir/home_kurir_screen.dart';

class LoginKurirScreen extends StatefulWidget {
  const LoginKurirScreen({super.key});

  @override
  State<LoginKurirScreen> createState() => _LoginKurirScreenState();
}

class _LoginKurirScreenState extends State<LoginKurirScreen> {
  final _hpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sembunyi = true;

  @override
  void dispose() {
    _hpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<DataService>().loginKurir(_hpCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeKurirScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.two_wheeler,
      title: 'Masuk kurir',
      subtitle: 'Lihat tugas jemput & antar',
      children: [
        TextField(
          controller: _hpCtrl,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined)),
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
        const SizedBox(height: 16),
        const Text(
          'Belum punya akun? Minta admin untuk mendaftarkan kamu sebagai kurir.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}
