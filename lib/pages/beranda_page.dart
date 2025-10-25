import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/logo.png', height: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Surat Mobile Sukorame',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusButton(
                  label: 'Total Pengajuan',
                  color: Colors.green,
                  count: 12,
                ),
                _StatusButton(
                  label: 'Belum Divalidasi',
                  color: Colors.orange,
                  count: 3,
                ),
                _StatusButton(
                  label: 'Sudah Divalidasi',
                  color: Colors.blue,
                  count: 7,
                ),
                _StatusButton(label: 'Ditolak', color: Colors.red, count: 2),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'STATISTIK DATA WARGA BARU TAHUN 2025',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Grafik Warga Baru'),
              ), // Placeholder chart
            ),
            const SizedBox(height: 24),
            const Text(
              'STATISTIK DATA SURAT MASUK TAHUN 2025',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Grafik Surat Masuk'),
              ), // Placeholder chart
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _StatusButton({
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
