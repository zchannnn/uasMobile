// Model untuk tiga aktor sistem: Pelanggan, Kurir, dan Admin
// Struktur field mengikuti tabel `pelanggan`, `kurir`, `admin` di MySQL.
// Password TIDAK pernah dikirim balik oleh API, jadi tidak disimpan di model.
import 'json_utils.dart';

enum StatusKurir { tersedia, bertugas }

extension StatusKurirLabel on StatusKurir {
  String get label => this == StatusKurir.tersedia ? 'Tersedia' : 'Bertugas';
}

StatusKurir statusKurirFromApi(String s) =>
    s == 'Bertugas' ? StatusKurir.bertugas : StatusKurir.tersedia;

class Pelanggan {
  final int idPelanggan;
  String nama;
  String email;
  String noHp;
  String alamat;

  Pelanggan({
    required this.idPelanggan,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> j) => Pelanggan(
        idPelanggan: toInt(j['id_pelanggan']),
        nama: j['nama'] as String,
        email: j['email'] as String,
        noHp: j['no_hp'] as String,
        alamat: j['alamat'] as String,
      );
}

class Kurir {
  final int idKurir;
  String nama;
  String noHp;
  StatusKurir statusKurir;

  Kurir({
    required this.idKurir,
    required this.nama,
    this.noHp = '',
    this.statusKurir = StatusKurir.tersedia,
  });

  factory Kurir.fromJson(Map<String, dynamic> j) => Kurir(
        idKurir: toInt(j['id_kurir']),
        nama: j['nama'] as String,
        noHp: (j['no_hp'] ?? '') as String,
        statusKurir: statusKurirFromApi((j['status_kurir'] ?? 'Tersedia') as String),
      );
}

class Admin {
  final int idAdmin;
  String nama;
  String username;

  Admin({
    required this.idAdmin,
    required this.nama,
    required this.username,
  });

  factory Admin.fromJson(Map<String, dynamic> j) => Admin(
        idAdmin: toInt(j['id_admin']),
        nama: j['nama'] as String,
        username: j['username'] as String,
      );
}
