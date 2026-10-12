// Model Pesanan & Pembayaran, mengikuti enum status pada DDL:
// status_pesanan: Menunggu, Dijemput, Diproses, Diantar, Selesai
// status_verifikasi pembayaran: Menunggu, Valid, Tidak Valid

import 'json_utils.dart';

enum StatusPesanan { menunggu, dijemput, diproses, diantar, selesai }

enum MetodeBayar { transfer, eWallet, tunai }

enum StatusVerifikasi { menunggu, valid, tidakValid }

extension StatusPesananLabel on StatusPesanan {
  String get label {
    switch (this) {
      case StatusPesanan.menunggu:
        return 'Menunggu';
      case StatusPesanan.dijemput:
        return 'Dijemput';
      case StatusPesanan.diproses:
        return 'Diproses';
      case StatusPesanan.diantar:
        return 'Diantar';
      case StatusPesanan.selesai:
        return 'Selesai';
    }
  }
}

extension MetodeBayarLabel on MetodeBayar {
  String get label {
    switch (this) {
      case MetodeBayar.transfer:
        return 'Transfer';
      case MetodeBayar.eWallet:
        return 'E-Wallet';
      case MetodeBayar.tunai:
        return 'Tunai';
    }
  }
}

extension StatusVerifikasiLabel on StatusVerifikasi {
  String get label {
    switch (this) {
      case StatusVerifikasi.menunggu:
        return 'Menunggu';
      case StatusVerifikasi.valid:
        return 'Valid';
      case StatusVerifikasi.tidakValid:
        return 'Tidak Valid';
    }
  }
}

// Nilai dari API sama persis dengan label (mis. 'Tidak Valid', 'E-Wallet').
StatusPesanan statusPesananFromApi(String s) =>
    StatusPesanan.values.firstWhere((e) => e.label == s, orElse: () => StatusPesanan.menunggu);
MetodeBayar metodeBayarFromApi(String s) =>
    MetodeBayar.values.firstWhere((e) => e.label == s, orElse: () => MetodeBayar.transfer);
StatusVerifikasi statusVerifikasiFromApi(String s) =>
    StatusVerifikasi.values.firstWhere((e) => e.label == s, orElse: () => StatusVerifikasi.menunggu);

class Pembayaran {
  final int idPembayaran;
  final int idPesanan;
  final DateTime tanggalBayar;
  final int jumlahBayar;
  final MetodeBayar metodeBayar;
  StatusVerifikasi statusVerifikasi;

  Pembayaran({
    required this.idPembayaran,
    required this.idPesanan,
    required this.tanggalBayar,
    required this.jumlahBayar,
    required this.metodeBayar,
    this.statusVerifikasi = StatusVerifikasi.menunggu,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> j) => Pembayaran(
        idPembayaran: toInt(j['id_pembayaran']),
        idPesanan: toInt(j['id_pesanan']),
        tanggalBayar: DateTime.parse(j['tanggal_bayar'] as String).toLocal(),
        jumlahBayar: toInt(j['jumlah_bayar']),
        metodeBayar: metodeBayarFromApi(j['metode_bayar'] as String),
        statusVerifikasi: statusVerifikasiFromApi(j['status_verifikasi'] as String),
      );
}

class Pesanan {
  final int idPesanan;
  final int idPelanggan;
  final int idLayanan;
  int? idKurir;
  final DateTime tanggalPesan;
  double beratKg;
  int totalBayar;
  final String alamatJemput;
  StatusPesanan statusPesanan;
  Pembayaran? pembayaran;
  String? namaPelanggan;
  String? namaKurir;

  Pesanan({
    required this.idPesanan,
    required this.idPelanggan,
    required this.idLayanan,
    this.idKurir,
    required this.tanggalPesan,
    this.beratKg = 0,
    this.totalBayar = 0,
    required this.alamatJemput,
    this.statusPesanan = StatusPesanan.menunggu,
    this.pembayaran,
    this.namaPelanggan,
    this.namaKurir,
  });

  factory Pesanan.fromJson(Map<String, dynamic> j) => Pesanan(
        idPesanan: toInt(j['id_pesanan']),
        idPelanggan: toInt(j['id_pelanggan']),
        idLayanan: toInt(j['id_layanan']),
        idKurir: toIntOrNull(j['id_kurir']),
        tanggalPesan: DateTime.parse(j['tanggal_pesan'] as String).toLocal(),
        beratKg: toDouble(j['berat_kg']),
        totalBayar: toInt(j['total_bayar']),
        alamatJemput: j['alamat_jemput'] as String,
        statusPesanan: statusPesananFromApi(j['status_pesanan'] as String),
        pembayaran: j['pembayaran'] == null
            ? null
            : Pembayaran.fromJson(j['pembayaran'] as Map<String, dynamic>),
        namaPelanggan: j['pelanggan_nama'] as String?,
        namaKurir: j['kurir_nama'] as String?,
      );
}
