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

## Instalasi & Pengembangan

### 1. Install Flutter SDK

#### Linux
1. Download Flutter SDK versi stable:
   ```bash
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
   ```
2. Ekstrak dan setup Flutter:
   ```bash
   tar xf flutter_linux_3.19.6-stable.tar.xz
   mv flutter ~/development/
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
3. Tambahkan PATH ke `~/.bashrc` atau `~/.zshrc`:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

#### Windows
1. Download Flutter SDK dari [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Ekstrak file zip ke `C:\src\flutter`
3. Tambahkan `C:\src\flutter\bin` ke PATH environment variable
4. Buka Command Prompt baru dan verifikasi instalasi

#### macOS
1. Download Flutter SDK dari [flutter.dev](https://docs.flutter.dev/get-started/install/macos)
2. Ekstrak ke `~/development/flutter`
3. Setup PATH:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

Setelah instalasi, jalankan di semua OS:
```bash
flutter doctor
```
Ikuti instruksi untuk melengkapi dependensi yang dibutuhkan.

### 2. Install Android Studio
1. Download dan install [Android Studio](https://developer.android.com/studio)
2. Install plugin **Flutter** dan **Dart** melalui menu `Preferences > Plugins`
3. Setup Android SDK di `Preferences > Appearance & Behavior > System Settings > Android SDK`
4. Buat Android Virtual Device (AVD) di `Device Manager`

### 3. Setup Project

1. Clone repository:
   ```bash
   git clone https://github.com/rissanndi/surat-mobile-sukorame.git
   cd surat-mobile-sukorame
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Buka di Android Studio:
   - Pilih **Open an Existing Project**
   - Arahkan ke folder `surat-mobile-sukorame`
   - Tunggu indexing selesai
   - Pastikan device/emulator terdeteksi

### 4. Konfigurasi Firebase

1. Install Firebase CLI:
   ```bash
   curl -sL https://firebase.tools | bash
   # atau dengan npm
   sudo npm install -g firebase-tools
   ```

2. Login dan list projects:
   ```bash
   firebase login
   firebase projects:list
   ```

3. Install & setup FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   export PATH="$PATH:$HOME/.pub-cache/bin"
   echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. Konfigurasi Firebase di project:
   ```bash
   flutterfire configure --project=your_project_id
   ```

5. Update dependencies di `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^2.30.0
     cupertino_icons: ^1.0.8
   ```
   
6. Install dependencies:
   ```bash
   flutter pub get
   ```

7. Inisialisasi Firebase di `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(const MyApp());
   }
   ```


## Instalasi & Pengembangan

### 1. Install Flutter SDK

- Ikuti panduan resmi sesuai OS di [flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- Setelah install, jalankan:
  ```bash
  flutter doctor
  ```
  Ikuti instruksi untuk melengkapi dependensi (Android SDK, Java, dsb).

### 2. Install Android Studio

1. Download dan install [Android Studio](https://developer.android.com/studio)
2. Install plugin **Flutter** dan **Dart** melalui menu `Preferences > Plugins`
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

### 5. Buka Project di Android Studio

1. Buka Android Studio
2. Pilih **Open an Existing Project** dan arahkan ke folder hasil clone (`surat-mobile-sukorame`)
3. Tunggu hingga Android Studio selesai melakukan indexing dan sinkronisasi project
4. Pastikan device emulator atau device fisik sudah terdeteksi (cek di toolbar Android Studio)
5. Jalankan aplikasi dengan klik tombol **Run** (ikon ▶️) atau gunakan perintah:
   ```bash
   flutter run
   ```

### 6. Instalasi & Konfigurasi Firebase

1. **Install Firebase CLI (`firebase-tools`)**
   - **Metode npm (Node.js):**
     ```bash
     sudo apt update
     sudo apt install nodejs npm
     sudo npm install -g firebase-tools
     ```
   - **Metode script resmi (tanpa npm):**
     ```bash
     curl -sL https://firebase.tools | bash
     # atau jika membutuhkan akses root
     sudo curl -sL https://firebase.tools | bash
     ```
   - Jika perintah `firebase` sudah bisa dijalankan di terminal, Anda tidak perlu menginstall ulang dengan npm.

2. **Login ke Firebase**
   ```bash
   firebase login
   ```
   Ikuti instruksi di terminal dan browser untuk login ke akun Google Anda.

3. **Melihat Daftar Project Firebase**
   Untuk melihat daftar project Firebase beserta Project ID yang akan digunakan pada konfigurasi, jalankan:
   ```bash
   firebase projects:list
   ```
   Contoh hasil:
   ┌──────────────────────┬──────────────┬────────────────┬──────────────────────┐
   │ Project Display Name │ Project ID   │ Project Number │ Resource Location ID │
   ├──────────────────────┼──────────────┼────────────────┼──────────────────────┤
   │ mpl3e2               │ mpl3e2-82b6c │ 770513006721   │ [Not specified]      │
   ├──────────────────────┼──────────────┼────────────────┼──────────────────────┤
   │ pml3e2               │ pml3e2-a1af5 │ 635645933703   │ [Not specified]      │
   └──────────────────────┴──────────────┴────────────────┴──────────────────────┘
   Gunakan **Project ID** (misal: `pml3e2-a1af5`) pada langkah konfigurasi Firebase di perintah:
   ```bash
   flutterfire configure --project=pml3e2-a1af5
   ```

4. **Install FlutterFire CLI**
   Jalankan:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   Setelah selesai, tambahkan ke PATH agar perintah `flutterfire` bisa digunakan:
   ```bash
   export PATH="$PATH:$HOME/.pub-cache/bin"
   source ~/.bashrc
   # atau jika menggunakan zsh
   source ~/.zshrc
   ```

5. **Konfigurasi Firebase ke Project Flutter**
   Jalankan:
   ```bash
   flutterfire configure --project=project_id_anda
   ```
   > **Catatan:**
   > Ganti `project_id_anda` dengan Project ID Firebase Anda, **tanpa tanda <>**.
   > Contoh:
   > ```bash
   > flutterfire configure --project=pml3e2-a1af5
   > ```

6. **Install Dependency Firebase di Flutter**
    Tambahkan ke `pubspec.yaml` pada bagian dependencies:
    ```yaml
    dependencies:
       flutter:
          sdk: flutter
       firebase_core: ^2.30.0
       cupertino_icons: ^1.0.8
       # dependency lain...
    ```
    Lalu jalankan:
    ```bash
    flutter pub get
    ```

7. **Inisialisasi Firebase di Kode Flutter**
   Pada file `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(const MyApp());
   }
   ```

8. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

Referensi:
- [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/)
- [Firebase Console](https://console.firebase.google.com/)

### 7. Troubleshooting Instalasi Firebase CLI dan FlutterFire CLI

- Jika muncul error versi Node.js saat install `firebase-tools`, update Node.js ke versi 20 atau lebih baru:
  ```bash
  sudo apt update
  sudo apt install curl
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  ```
- Jika muncul error `EEXIST: file already exists` pada `/usr/local/bin/firebase`, hapus file tersebut sebelum install ulang:
  ```bash
  sudo rm /usr/local/bin/firebase
  sudo npm install -g firebase-tools
  ```
- Jika perintah `flutterfire` tidak ditemukan setelah aktivasi, pastikan sudah menambahkan ke PATH:
  ```bash
  export PATH="$PATH:$HOME/.pub-cache/bin"
  source ~/.bashrc
  # atau jika menggunakan zsh
  source ~/.zshrc
  ```
  Jangan gunakan `sudo` saat menjalankan `flutterfire`.
  Jika tetap tidak bisa, tutup terminal, buka terminal baru, lalu coba lagi.

# Troubleshooting

### Flutter Setup
- Jika ada error pada `flutter doctor`, ikuti saran perbaikan yang diberikan
- Pastikan semua dependency sudah terinstall dan device/emulator sudah aktif
- Jika ada masalah PATH, restart terminal atau logout/login ulang

### Firebase Setup
- Jika error versi Node.js saat install firebase-tools:
  ```bash
  sudo apt update && sudo apt install curl
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
  ```

- Jika error `EEXIST: file already exists`:
  ```bash
  sudo rm /usr/local/bin/firebase
  sudo npm install -g firebase-tools
  ```

- Jika `flutterfire` tidak ditemukan:
  ```bash
  export PATH="$PATH:$HOME/.pub-cache/bin"
  source ~/.bashrc  # atau source ~/.zshrc
  ```
  Jangan gunakan sudo untuk flutterfire

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

## Referensi
- [Flutter Documentation](https://docs.flutter.dev)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Console](https://console.firebase.google.com)

## Kontak
Untuk informasi lebih lanjut, hubungi:
- Email: [email]
- Telepon: [nomor telepon]

## Lisensi
Copyright © 2024 Desa Sukorame. All rights reserved.
