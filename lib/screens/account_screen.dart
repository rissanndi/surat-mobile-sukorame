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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'about') {
                  // TODO: Navigasi ke halaman "Tentang Aplikasi"
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur "Tentang Aplikasi" sedang dikembangkan.')));
                } else if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Tentang Aplikasi'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
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
            // Konten untuk tab pertama (Profil Saya)
            ProfileTabView(),
            // Konten untuk tab kedua (Anggota Keluarga)
            FamilyTabView(),
          ],
        ),
      ),
    );
  }
}