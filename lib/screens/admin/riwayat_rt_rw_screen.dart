import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiwayatRTRWScreen extends StatelessWidget {
  const RiwayatRTRWScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat RT/RW'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('riwayatRTRW').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data?.docs ?? [];

          if (history.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat RT/RW'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final historyData = history[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(historyData['nama'] ?? 'Nama tidak tersedia'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jabatan: ${historyData['tipe']?.toUpperCase() ?? 'Tidak tersedia'}'),
                      Text('Nomor: ${historyData['nomor'] ?? 'Tidak tersedia'}'),
                      Text('Periode: ${historyData['periodeMulai']?.split('T')[0]} - ${historyData['periodeAkhir']?.split('T')[0]}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
