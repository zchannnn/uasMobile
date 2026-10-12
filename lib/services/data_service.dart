import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/layanan.dart';
import '../models/pesanan.dart';
import '../models/user_models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// DataService = jembatan antara UI dan REST API (PHP + MySQL).
///
/// - Data dari server disimpan di cache (`_layanan`, `_kurir`, `_pesanan`) sehingga
///   getter yang dipakai UI tetap sinkron seperti sebelumnya.
/// - Semua aksi yang mengubah data (login, order, bayar, dst.) kini `Future` dan
///   mengembalikan `String?` = pesan error, atau `null` jika sukses.
/// - Selama login, data disegarkan otomatis tiap [_pollInterval] supaya status
///   pesanan terlihat "real-time" di semua aktor.
class DataService extends ChangeNotifier {
  static const _pollInterval = Duration(seconds: 10);
  static const _timeout = Duration(seconds: 20);

  String? _token;
  Timer? _poller;
  bool _syncing = false;
  int _syncSeq = 0;

  List<Layanan> _layanan = [];
  List<Kurir> _kurir = [];
  List<Pesanan> _pesanan = [];

  // Sesi pengguna yang sedang login
  Pelanggan? currentPelanggan;
  Kurir? currentKurir;
  Admin? currentAdmin;

  List<Layanan> get daftarLayanan => List.unmodifiable(_layanan);
  List<Kurir> get daftarKurir => List.unmodifiable(_kurir);
  List<Pesanan> get semuaPesanan => List.unmodifiable(_pesanan);

  // ------------------ HTTP ------------------

  Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final req = http.Request(method, Uri.parse('$apiBaseUrl$path'))
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
    if (body != null) req.body = jsonEncode(body);

    http.Response res;
    try {
      res = await http.Response.fromStream(await req.send().timeout(_timeout));
    } on TimeoutException {
      throw ApiException('Server tidak merespons. Coba lagi sebentar.');
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {}

    if (json == null) {
      throw ApiException('Respons server tidak valid (HTTP ${res.statusCode}).', res.statusCode);
    }
    if (json['ok'] != true) {
      throw ApiException((json['error'] ?? 'Terjadi kesalahan') as String, res.statusCode);
    }
    return json['data'];
  }

  Future<String?> _guard(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// Panggil endpoint yang mengubah data, lalu segarkan cache.
  Future<String?> _mutate(String method, String path, {Map<String, dynamic>? body}) {
    return _guard(() async {
      await _request(method, path, body: body);
      await _silentSync(force: true);
    });
  }

  // ------------------ SINKRONISASI ------------------

  Future<void> _sync() async {
    final seq = ++_syncSeq;
    final d = await _request('GET', '/sync') as Map<String, dynamic>;
    if (seq != _syncSeq || _token == null) return; // respons usang / sudah logout
    _layanan = (d['layanan'] as List).map((e) => Layanan.fromJson(e as Map<String, dynamic>)).toList();
    _kurir = (d['kurir'] as List).map((e) => Kurir.fromJson(e as Map<String, dynamic>)).toList();
    _pesanan = (d['pesanan'] as List).map((e) => Pesanan.fromJson(e as Map<String, dynamic>)).toList();

    final me = d['me'] as Map<String, dynamic>;
    switch (d['role']) {
      case 'pelanggan':
        currentPelanggan = Pelanggan.fromJson(me);
        break;
      case 'kurir':
        currentKurir = Kurir.fromJson(me);
        break;
      case 'admin':
        currentAdmin = Admin.fromJson(me);
        break;
    }
    notifyListeners();
  }

  /// Segarkan data tanpa melempar error (dipakai polling & setelah aksi).
  Future<void> _silentSync({bool force = false}) async {
    if (_token == null || (_syncing && !force)) return;
    _syncing = true;
    try {
      await _sync();
    } catch (_) {
      // abaikan; akan dicoba lagi pada siklus berikutnya
    } finally {
      _syncing = false;
    }
  }

  /// Tarik-ulang data secara manual (mis. pull-to-refresh).
  Future<void> refresh() => _silentSync();

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(_pollInterval, (_) => _silentSync());
  }

  void _clearSession() {
    _poller?.cancel();
    _poller = null;
    _token = null;
    currentPelanggan = null;
    currentKurir = null;
    currentAdmin = null;
    _layanan = [];
    _kurir = [];
    _pesanan = [];
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  // ------------------ AUTENTIKASI ------------------

  Future<String?> registerPelanggan({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String alamat,
  }) {
    return _guard(() async {
      await _request('POST', '/auth/register', body: {
        'nama': nama,
        'email': email,
        'no_hp': noHp,
        'password': password,
        'alamat': alamat,
      });
    });
  }

  Future<String?> _login(String path, Map<String, dynamic> body) {
    return _guard(() async {
      final d = await _request('POST', path, body: body) as Map<String, dynamic>;
      _token = d['token'] as String;
      try {
        await _sync(); // mengisi currentPelanggan/Kurir/Admin + semua data
      } catch (e) {
        _clearSession();
        rethrow;
      }
      _startPolling();
    });
  }

  Future<String?> loginPelanggan(String email, String password) =>
      _login('/auth/login/pelanggan', {'email': email, 'password': password});

  Future<String?> loginKurir(String noHp, String password) =>
      _login('/auth/login/kurir', {'no_hp': noHp, 'password': password});

  Future<String?> loginAdmin(String username, String password) =>
      _login('/auth/login/admin', {'username': username, 'password': password});

  void logout() {
    final token = _token;
    if (token != null) {
      // beritahu server (best effort, tidak perlu ditunggu)
      http.post(
        Uri.parse('$apiBaseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      ).catchError((_) => http.Response('', 0));
    }
    _clearSession();
    notifyListeners();
  }

  // ------------------ LOOKUP (dari cache) ------------------

  Layanan layananById(int id) => _layanan.firstWhere((l) => l.idLayanan == id);

  Kurir? kurirById(int? id) {
    if (id == null) return null;
    for (final k in _kurir) {
      if (k.idKurir == id) return k;
    }
    return null;
  }

  List<Pesanan> pesananMilikPelanggan() {
    // server sudah memfilter sesuai pelanggan yang login; urutan terbaru dulu
    return _pesanan.toList()..sort((a, b) => b.tanggalPesan.compareTo(a.tanggalPesan));
  }

  List<Pesanan> tugasKurir() {
    // server sudah memfilter sesuai kurir yang login
    return _pesanan.toList()..sort((a, b) => a.tanggalPesan.compareTo(b.tanggalPesan));
  }

  List<Pesanan> laporanTransaksi({DateTime? dari, DateTime? sampai}) {
    return _pesanan.where((p) {
      if (dari != null && p.tanggalPesan.isBefore(dari)) return false;
      if (sampai != null && p.tanggalPesan.isAfter(sampai)) return false;
      return p.pembayaran != null;
    }).toList()
      ..sort((a, b) => b.tanggalPesan.compareTo(a.tanggalPesan));
  }

  // ------------------ PELANGGAN ------------------

  Future<String?> buatPesanan({required int idLayanan, required String alamatJemput}) =>
      _mutate('POST', '/pesanan', body: {'id_layanan': idLayanan, 'alamat_jemput': alamatJemput});

  Future<String?> bayarPesanan(Pesanan pesanan, MetodeBayar metode) =>
      _mutate('POST', '/pesanan/${pesanan.idPesanan}/bayar', body: {'metode_bayar': metode.label});

  // ------------------ ADMIN ------------------

  Future<String?> tugaskanKurir(Pesanan pesanan, int idKurir) =>
      _mutate('POST', '/pesanan/${pesanan.idPesanan}/tugaskan', body: {'id_kurir': idKurir});

  Future<String?> tambahLayanan(String nama, int hargaPerKg, String estimasi) => _mutate(
        'POST',
        '/layanan',
        body: {'nama_layanan': nama, 'harga_per_kg': hargaPerKg, 'estimasi_waktu': estimasi},
      );

  Future<String?> ubahLayanan(int idLayanan, String nama, int hargaPerKg, String estimasi) => _mutate(
        'PUT',
        '/layanan/$idLayanan',
        body: {'nama_layanan': nama, 'harga_per_kg': hargaPerKg, 'estimasi_waktu': estimasi},
      );

  Future<String?> hapusLayanan(int idLayanan) => _mutate('DELETE', '/layanan/$idLayanan');

  /// Admin mendaftarkan akun kurir baru (login kurir memakai No. HP + kata sandi ini).
  Future<String?> tambahKurir({required String nama, required String noHp, required String password}) =>
      _mutate('POST', '/kurir', body: {'nama': nama, 'no_hp': noHp, 'password': password});

  Future<String?> verifikasiPembayaran(Pesanan pesanan, bool valid) =>
      _mutate('POST', '/pesanan/${pesanan.idPesanan}/verifikasi', body: {'valid': valid});

  // ------------------ KURIR ------------------

  /// Kurir menimbang cucian; server menghitung total_bayar (berat × harga/kg)
  /// dan otomatis mengubah status pesanan menjadi Diproses.
  Future<String?> inputBeratDanHitung(Pesanan pesanan, double beratKg) =>
      _mutate('POST', '/pesanan/${pesanan.idPesanan}/berat', body: {'berat_kg': beratKg});

  Future<String?> updateStatusPesananKurir(Pesanan pesanan, StatusPesanan status) =>
      _mutate('POST', '/pesanan/${pesanan.idPesanan}/status', body: {'status_pesanan': status.label});
}
