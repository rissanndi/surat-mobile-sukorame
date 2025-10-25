import 'package:flutter/material.dart';

class PengajuanPage extends StatelessWidget {
  const PengajuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan')),
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
                  _PengajuanItem(title: 'Desa Baru', date: '12 Okt 2025'),
                  _PengajuanItem(title: 'Zacka Nasif', date: '12 Okt 2025'),
                  _PengajuanItem(
                    title: 'Regita Rahmadani',
                    date: '12 Okt 2025',
                  ),
                  _PengajuanItem(title: 'Najwa Anggai', date: '12 Okt 2025'),
                  _PengajuanItem(title: 'Fasti Andian', date: '12 Okt 2025'),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Pengajuan tervalidasi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Riwayat pengajuan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PengajuanItem extends StatelessWidget {
  final String title;
  final String date;
  const _PengajuanItem({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(date),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('Lihat')),
      ),
    );
  }
}
