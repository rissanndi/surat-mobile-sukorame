import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/widgets/family_tab_view.dart';
import 'package:surat_mobile_sukorame/widgets/profile_tab_view.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController adalah cara termudah untuk membuat halaman dengan tab
    return DefaultTabController(
      length: 2, // Jumlah tab kita
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pengaturan Akun"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Profil Saya"),
              Tab(icon: Icon(Icons.group), text: "Anggota Keluarga"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Konten untuk tab pertama
            ProfileTabView(),
            // Konten untuk tab kedua
            FamilyTabView(),
          ],
        ),
      ),
    );
  }
}