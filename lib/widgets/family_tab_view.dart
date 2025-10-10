import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/screens/add_family_member_screen.dart';

class FamilyTabView extends StatelessWidget {
  const FamilyTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text("User tidak ditemukan."));

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('anggotaKeluarga')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada anggota keluarga yang ditambahkan."),
            );
          }

          final familyDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: familyDocs.length,
            itemBuilder: (context, index) {
              final memberData = familyDocs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(memberData['nama'] ?? 'Tanpa Nama'),
                  subtitle: Text(memberData['statusDiKeluarga'] ?? '-'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // TODO: Buat logika hapus anggota keluarga
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddFamilyMemberScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}