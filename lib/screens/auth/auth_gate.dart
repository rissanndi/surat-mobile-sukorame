// lib/screens/auth_gate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/screens/admin/admin_main_screen.dart';
import 'package:surat_mobile_sukorame/screens/auth/complete_profile_screen.dart';
import 'package:surat_mobile_sukorame/screens/auth/login_register_screen.dart';
import 'package:surat_mobile_sukorame/screens/main_screen.dart';
import 'package:surat_mobile_sukorame/screens/verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!authSnapshot.hasData) {
          return const LoginRegisterScreen();
        }

        final user = authSnapshot.data!;

        if (!user.emailVerified) {
          return VerifyEmailScreen(user: user);
        }

        return StreamBuilder<DocumentSnapshot>( 
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(), 
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Cek apakah dokumen profil ada
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Jika dokumen profil TIDAK ADA, paksa untuk melengkapi profil
              return CompleteProfileScreen(user: user);
            }
            
            // Ambil data user termasuk role
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            // Normalisasi role agar perbandingan tidak sensitif terhadap case/spasi
            final String role = (userData['role'] ?? 'warga').toString().toLowerCase().trim();
            
            print('Debug - User Role: $role'); // Debug print
            print('Debug - Full userData: $userData'); // Debug print

            // Arahkan ke halaman yang sesuai berdasarkan role
            if (role == 'kelurahan' || role == 'admin') {
              print('Debug - Directing to AdminMainScreen'); // Debug print
              return const AdminMainScreen();
            } else {
              print('Debug - Directing to MainScreen'); // Debug print
              return const MainScreen(); // Untuk warga
            }
          },
        );
      },
    );
  }
}