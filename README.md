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

### 1. Install Flutter SDK (Linux)

1. Download Flutter SDK versi stable:
   ```bash
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
   ```
2. Ekstrak file yang diunduh:
   ```bash
   tar xf flutter_linux_3.19.6-stable.tar.xz
   ```
3. Pindahkan folder `flutter` ke direktori yang diinginkan, misal ke `~/development`:
   ```bash
   mv flutter ~/development/
   ```
4. Tambahkan Flutter ke PATH:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
   Agar permanen, tambahkan baris di atas ke file `~/.bashrc` atau `~/.zshrc`.
5. Cek instalasi Flutter:
   ```bash
   flutter doctor
   ```
   Ikuti instruksi yang muncul untuk melengkapi dependensi (Android SDK, Java, dsb).

**Windows/MacOS:** Lihat panduan resmi di [flutter.dev](https://docs.flutter.dev/get-started/install)

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
