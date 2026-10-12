import 'package:intl/intl.dart';

final NumberFormat _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

/// 15000 -> "Rp 15.000"
String rupiah(num nilai) => _rp.format(nilai);

/// 2.5 -> "2,5 kg", 3.0 -> "3 kg"
String beratKg(double kg) {
  var s = kg.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  s = s.replaceAll('.', ',');
  return '$s kg';
}

String tanggal(DateTime d) {
  try {
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
  } catch (_) {
    return DateFormat('d MMM yyyy').format(d);
  }
}

String tanggalWaktu(DateTime d) {
  try {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
  } catch (_) {
    return DateFormat('d MMM yyyy, HH:mm').format(d);
  }
}
