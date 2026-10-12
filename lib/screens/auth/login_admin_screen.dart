import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_scaffold.dart';
import '../admin/home_admin_screen.dart';

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({super.key});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sembunyi = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<DataService>().loginAdmin(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeAdminScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.admin_panel_settings_outlined,
      title: 'Masuk admin',
      subtitle: 'Kelola layanan, kurir & pembayaran',
      children: [
        TextField(
          controller: _userCtrl,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
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
      ],
    );
  }
}
