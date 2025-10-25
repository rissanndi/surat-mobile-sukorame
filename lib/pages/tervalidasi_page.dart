import 'package:flutter/material.dart';

class TervalidasiPage extends StatelessWidget {
  const TervalidasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tervalidasi')),
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
                  _TervalidasiItem(title: 'Desa Baru', date: '12 Okt 2025'),
                  _TervalidasiItem(title: 'Zacka Nasif', date: '12 Okt 2025'),
                  _TervalidasiItem(
                    title: 'Regita Rahmadani',
                    date: '12 Okt 2025',
                  ),
                  _TervalidasiItem(title: 'Najwa Anggai', date: '12 Okt 2025'),
                  _TervalidasiItem(title: 'Fasti Andian', date: '12 Okt 2025'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TervalidasiItem extends StatelessWidget {
  final String title;
  final String date;
  const _TervalidasiItem({required this.title, required this.date});

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
