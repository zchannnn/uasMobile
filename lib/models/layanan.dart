// Model untuk jenis layanan laundry (cuci reguler, cuci-setrika, cuci ekspres)
import 'json_utils.dart';

class Layanan {
  final int idLayanan;
  String namaLayanan;
  int hargaPerKg;
  String estimasiWaktu;

  Layanan({
    required this.idLayanan,
    required this.namaLayanan,
    required this.hargaPerKg,
    required this.estimasiWaktu,
  });

  factory Layanan.fromJson(Map<String, dynamic> j) => Layanan(
        idLayanan: toInt(j['id_layanan']),
        namaLayanan: j['nama_layanan'] as String,
        hargaPerKg: toInt(j['harga_per_kg']),
        estimasiWaktu: (j['estimasi_waktu'] ?? '') as String,
      );
}
