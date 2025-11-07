import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:surat_mobile_sukorame/models/family_member_model.dart';
import 'package:surat_mobile_sukorame/screens/add_family_member_screen.dart'; // Import ini jika belum ada

class FamilyTabView extends StatefulWidget {
  const FamilyTabView({super.key});

  @override
  State<FamilyTabView> createState() => _FamilyTabViewState();
}

class _FamilyTabViewState extends State<FamilyTabView> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _confirmDeleteMember(BuildContext context, FamilyMember member) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Anggota Keluarga?'),
          content: Text('Anda yakin ingin menghapus ${member.namaLengkap} dari daftar anggota keluarga?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _deleteFamilyMember(member.id); // Panggil fungsi hapus
                Navigator.of(dialogContext).pop(); // Tutup dialog setelah menghapus
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFamilyMember(String memberId) async {
    if (currentUser == null) return;

    try {
      // Hapus dari sub-koleksi 'anggotaKeluarga' di bawah dokumen pengguna
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid) // Pastikan ID pengguna yang benar
          .collection('anggotaKeluarga')
          .doc(memberId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggota keluarga berhasil dihapus.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus anggota keluarga: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Silakan login untuk melihat anggota keluarga."));
    }

    return Column(
      children: [
        // Tombol untuk menambah anggota keluarga baru
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddFamilyMemberScreen(userUid: currentUser!.uid)),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Tambah Anggota Keluarga"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Lebar penuh
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // STREAM HARUS MERUJUK KE SUB-KOLEKSI
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .collection('anggotaKeluarga')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('Error loading family members: ${snapshot.error}'); // Debugging
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Belum ada anggota keluarga yang ditambahkan."));
              }

              final familyMembers = snapshot.data!.docs.map((doc) => FamilyMember.fromFirestore(doc)).toList();

              return ListView.builder(
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  final member = familyMembers[index];
                  final tglLahirFormatted = DateFormat('dd MMM yyyy').format(member.tanggalLahir);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                      title: Text(member.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NIK: ${member.nik}'),
                          Text('Status: ${member.statusDiKeluarga}'),
                          Text('Lahir: ${member.tempatLahir}, $tglLahirFormatted'),
                          Text('Pekerjaan: ${member.pekerjaan}'), // Tampilkan pekerjaan
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteMember(context, member),
                      ),
                      onTap: () {
                        // TODO: Implementasi navigasi ke EditFamilyMemberScreen jika diperlukan
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detail ${member.namaLengkap} (Fitur edit belum tersedia)')),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}