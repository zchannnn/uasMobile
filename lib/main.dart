import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'screens/auth/role_select_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const CleanGoApp());
}

class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataService(),
      child: MaterialApp(
        title: 'CleanGo Laundry',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RoleSelectScreen(),
      ),
    );
  }
}
