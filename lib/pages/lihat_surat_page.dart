import 'package:flutter/material.dart';

class LihatSuratPage extends StatelessWidget {
  final bool isTervalidasi;
  const LihatSuratPage({super.key, this.isTervalidasi = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTervalidasi
              ? 'Lihat Surat Tervalidasi'
              : 'Lihat Surat Belum Tervalidasi',
        ),
        backgroundColor: const Color(0xFF1B7B3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Gambar Surat'),
              ), // Placeholder for image
            ),
            const SizedBox(height: 16),
            if (isTervalidasi) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Unduh'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Total Diverifikasi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Catatan validasi surat'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.green[100],
                child: const Text(
                  'Surat sudah tervalidasi',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Validasi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Catatan validasi surat'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red[100],
                child: const Text(
                  'Surat belum tervalidasi',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
