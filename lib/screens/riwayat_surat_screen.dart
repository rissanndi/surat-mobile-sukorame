import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surat_mobile_sukorame/theme/app_theme.dart';

class RiwayatSuratScreen extends StatefulWidget {
  const RiwayatSuratScreen({super.key});

  @override
  State<RiwayatSuratScreen> createState() => _RiwayatSuratScreenState();
}

class _RiwayatSuratScreenState extends State<RiwayatSuratScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Surat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('surat')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat surat'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    data['jenisSurat'] ?? 'Tidak ada judul',
                    style: AppTextStyles.subtitle1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${data['status'] ?? 'Menunggu'}',
                        style: AppTextStyles.body2,
                      ),
                      Text(
                        'Tanggal: ${(data['createdAt'] as Timestamp).toDate().toString().split(' ')[0]}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  trailing: _getStatusIcon(data['status'] ?? 'Menunggu'),
                  onTap: () {
                    // TODO: Implement detail view
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return const Icon(Icons.check_circle, color: AppTheme.success);
      case 'ditolak':
        return const Icon(Icons.cancel, color: AppTheme.error);
      case 'dalam proses':
        return const Icon(Icons.access_time, color: AppTheme.warning);
      default:
        return const Icon(Icons.pending, color: AppTheme.secondary);
    }
  }
}