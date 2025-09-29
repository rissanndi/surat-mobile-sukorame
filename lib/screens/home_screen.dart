import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:surat_mobile_sukorame/screens/form_surat_screen.dart';
import 'package:surat_mobile_sukorame/widgets/surat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Silakan login ulang")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              // PASTIKAN Anda sudah membuat folder 'assets' dan mendaftarkannya di pubspec.yaml
              // Image.asset('assets/logo_pemkab.png', height: 40),
              // const SizedBox(width: 8),
              // Image.asset('assets/logo_sukorame.png', height: 35),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.account_circle, color: Colors.grey.shade700, size: 30),
              onPressed: () { 
                // Aksi ini akan ditangani oleh BottomNavigationBar di MainScreen
                // Anda bisa biarkan kosong atau hapus jika tidak diperlukan lagi
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Riwayat Surat",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('surat')
                    .where('pembuatId', isEqualTo: currentUser.uid)
                    .orderBy('tanggalPengajuan', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    debugPrint("Firestore Error: ${snapshot.error}");
                    return Center(child: Text("Error: ${snapshot.error}\n\nCek Debug Console untuk link pembuatan indeks Firestore."));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Belum ada riwayat surat.\nKlik 'Buat Surat' untuk memulai.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final suratDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: suratDocs.length,
                    itemBuilder: (context, index) {
                      final surat = Surat.fromFirestore(suratDocs[index]);
                      return SuratCard(surat: surat);
                    },
                  );
                },
              ),
            ),
            // Tombol Buat Surat di bawah
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        // Mengirim UID pengguna yang sedang login ke halaman form
                        builder: (context) => FormSuratScreen(userUid: currentUser.uid),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E565D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Buat Surat", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}