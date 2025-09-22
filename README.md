# Aplikasi Manajemen Surat Desa Sukorame

Aplikasi mobile untuk pengelolaan administrasi surat-menyurat di Desa Sukorame, dibangun menggunakan Flutter Framework.

## Deskripsi
Aplikasi ini dikembangkan untuk memudahkan proses administrasi surat di Desa Sukorame, memungkinkan pengelolaan surat masuk dan keluar secara digital, serta meningkatkan efisiensi pelayanan kepada masyarakat.

## Fitur Utama
- Manajemen surat masuk dan keluar
- Pencatatan data pemohon surat
- Pembuatan berbagai jenis surat keterangan
- Tracking status surat
- Notifikasi untuk pemrosesan surat
- Laporan dan statistik surat
- Manajemen pengguna (Admin, Staf, Warga)

## Teknologi
- Framework: Flutter
- Database: SQLite (lokal)
- State Management: Provider
- UI Components: Material Design


## Instalasi Lengkap & Pengembangan

### 1. Install Flutter SDK

Ikuti langkah berikut untuk menginstal Flutter:

- **Linux**:
  1. Download Flutter SDK dari [flutter.dev](https://docs.flutter.dev/get-started/install/linux)
  2. Ekstrak file zip ke lokasi yang diinginkan (misal: `~/development`)
  3. Tambahkan Flutter ke PATH:
     ```bash
     export PATH="$PATH:`pwd`/flutter/bin"
     ```
  4. Jalankan:
     ```bash
     flutter doctor
     ```
  5. Ikuti instruksi pada output `flutter doctor` untuk melengkapi dependensi (misal: Android SDK, Java, dsb).

- **Windows/MacOS**: Lihat panduan resmi di [flutter.dev](https://docs.flutter.dev/get-started/install)

### 2. Install Android Studio

1. Download dan install [Android Studio](https://developer.android.com/studio)
2. Buka Android Studio, install plugin **Flutter** dan **Dart** melalui menu `Preferences > Plugins`
3. Pastikan Android SDK sudah terpasang (cek di `Preferences > Appearance & Behavior > System Settings > Android SDK`)
4. Buat atau pastikan sudah ada Android Virtual Device (AVD) di `Device Manager`

### 3. Clone Repository

```bash
git clone https://github.com/rissanndi/surat-mobile-sukorame.git
cd surat-mobile-sukorame
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Menyambungkan ke Android Studio

1. Buka Android Studio
2. Pilih **Open an Existing Project** dan arahkan ke folder hasil clone (`surat-mobile-sukorame`)
3. Tunggu hingga Android Studio selesai melakukan indexing dan sinkronisasi project
4. Pastikan device emulator atau device fisik sudah terdeteksi (cek di toolbar Android Studio)
5. Jalankan aplikasi dengan klik tombol **Run** (ikon ▶️) atau gunakan perintah:
   ```bash
   flutter run
   ```

### 6. Troubleshooting

- Jika ada error pada `flutter doctor`, ikuti saran perbaikan yang diberikan
- Pastikan semua dependency sudah terinstall dan device/emulator sudah aktif

---

## Struktur Aplikasi

```
lib/
├── models/         # Model data
├── views/          # UI screens
├── controllers/    # Business logic
├── services/       # External services
├── utils/          # Helper functions
└── widgets/        # Reusable components
```

## Target Pengguna
- Admin Desa
- Perangkat Desa
- Warga Desa Sukorame

## Kontribusi
Untuk kontribusi pengembangan, silakan buat issue atau pull request.

## Kontak
Untuk informasi lebih lanjut, hubungi:
- Email: [email]
- Telepon: [nomor telepon]

## Lisensi
Copyright © 2024 Desa Sukorame. All rights reserved.
