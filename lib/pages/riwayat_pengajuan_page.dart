import 'package:flutter/material.dart';

class RiwayatPengajuanPage extends StatelessWidget {
  const RiwayatPengajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengajuan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _RiwayatItem(
                    title: 'Desa Baru',
                    date: '12 Okt 2025',
                    status: 'Ditolak',
                    color: Colors.red,
                  ),
                  _RiwayatItem(
                    title: 'Zacka Nasif',
                    date: '12 Okt 2025',
                    status: 'Selesai',
                    color: Colors.green,
                  ),
                  _RiwayatItem(
                    title: 'Regita Rahmadani',
                    date: '12 Okt 2025',
                    status: 'Selesai',
                    color: Colors.green,
                  ),
                  _RiwayatItem(
                    title: 'Najwa Anggai',
                    date: '12 Okt 2025',
                    status: 'Diproses',
                    color: Colors.orange,
                  ),
                  _RiwayatItem(
                    title: 'Fasti Andian',
                    date: '12 Okt 2025',
                    status: 'Ditolak',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiwayatItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color color;
  const _RiwayatItem({
    required this.title,
    required this.date,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
