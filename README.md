# CleanGo Laundry — Aplikasi Mobile Antar-Jemput

Flutter (3 aktor: **Pelanggan**, **Kurir**, **Admin**) + backend **PHP REST API** + database **MySQL**.
Backend ada di folder `../cleango_api` (lihat README di sana untuk deploy & daftar endpoint).

```
HP (Flutter app)  --HTTPS/JSON-->  cleango_api (PHP)  --PDO-->  MySQL
```

## 1. Siapkan backend dulu
Ikuti `cleango_api/README.md` (import `schema.sql`, upload ke hosting, jalankan `seed.php`).
Pastikan `https://domainkamu.com/api/ping` menampilkan `{"ok":true,...}`.

## 2. Arahkan app ke API kamu
Ubah `apiBaseUrl` di `lib/config.dart`, **atau** kirim saat build (tanpa edit kode):

```bash
--dart-define=API_BASE_URL=https://domainkamu.com/api
```

> Wajib **HTTPS**. Android 9+ memblokir `http://` biasa pada app release.

## 3. Jalankan
```bash
flutter create .        # hanya jika folder android/ belum ada
flutter pub get
flutter run --dart-define=API_BASE_URL=https://domainkamu.com/api
```

### Izin internet (WAJIB untuk APK release)
Buka `android/app/src/main/AndroidManifest.xml` dan pastikan ada baris ini
**di atas** tag `<application ...>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Tanpa ini app jalan normal saat debug, tapi di APK release **tidak bisa konek ke server**.

## 4. Build APK untuk di-install di HP
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://domainkamu.com/api
```
Hasil: `build/app/outputs/flutter-apk/app-release.apk` → kirim ke HP (WhatsApp/Drive/kabel),
buka file, izinkan "Install dari sumber tidak dikenal", selesai.

Untuk ukuran lebih kecil: tambahkan `--split-per-abi` (pilih `app-arm64-v8a-release.apk` untuk HP modern).

### Publish ke Google Play (opsional)
Buat keystore & atur signing (https://docs.flutter.dev/deployment/android), ubah `applicationId`
di `android/app/build.gradle`, lalu `flutter build appbundle --release --dart-define=...`.

## Akun percobaan
Hanya ada jika kamu menjalankan `seed.php?...&demo=1` (hapus akun demo sebelum dipakai publik):

| Role      | Username/Email   | Password |
|-----------|------------------|----------|
| Pelanggan | siti@mail.com    | 123456   |
| Kurir     | 081200000001     | 123456   |
| Admin     | admin            | (SEED_ADMIN_PASSWORD di config.php) |

## Alur demo
1. **Pelanggan** → Order Jemput → pilih layanan & alamat.
2. **Admin** → Tugaskan Kurir.
3. **Kurir** → input berat (tagihan = berat × harga/kg, dihitung di server).
4. **Pelanggan** → bayar. 5. **Admin** → Verifikasi Pembayaran (Valid).
6. **Kurir** → Antar Cucian → Tandai Selesai. 7. **Admin** → Laporan Transaksi.

Data otomatis diperbarui tiap 10 detik, jadi perubahan dari aktor lain muncul tanpa restart.

## Struktur
```
lib/
  config.dart        # URL API
  models/            # Pelanggan, Kurir, Admin, Layanan, Pesanan, Pembayaran (+ fromJson)
  services/          # DataService = client REST API + cache + polling
  screens/           # auth, pelanggan, kurir, admin
  widgets/
```

## Pengembangan lanjutan
- Simpan token login (`shared_preferences`/`flutter_secure_storage`) agar tidak login ulang tiap buka app.
- Push notification (Firebase Cloud Messaging) menggantikan polling.
- Halaman admin untuk menambah kurir (API `POST /kurir` sudah tersedia).
- Rate limiting login di sisi server/Cloudflare.
