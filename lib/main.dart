import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:surat_mobile_sukorame/firebase_options.dart';
import 'package:surat_mobile_sukorame/screens/login_screen.dart';
import 'package:surat_mobile_sukorame/screens/main_screen.dart';
import 'package:surat_mobile_sukorame/screens/verify_email_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Surat Pengantar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget ini akan mengecek status login & verifikasi pengguna
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // =========================================================
          // PERUBAHAN UTAMA ADA DI SINI
          // =========================================================
          final user = snapshot.data!;
          return user.emailVerified
              ? const MainScreen() // JIKA SUDAH VERIFIKASI -> Masuk ke Aplikasi
              : const VerifyEmailScreen(); // JIKA BELUM -> Tampilkan Halaman Verifikasi
        }
        return const LoginScreen(); // Jika belum login, ke halaman login
      },
    );
  }
}