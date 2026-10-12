// Helper kecil untuk membaca JSON dari API secara aman.

int toInt(dynamic v) => v is num ? v.toInt() : int.parse('$v');
double toDouble(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
int? toIntOrNull(dynamic v) => v == null ? null : toInt(v);
