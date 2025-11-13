import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/surat_service.dart';

class LihatSuratPage extends StatefulWidget {
  const LihatSuratPage({super.key});

  @override
  State<LihatSuratPage> createState() => _LihatSuratPageState();
}

class _LihatSuratPageState extends State<LihatSuratPage> {
  final SuratService _suratService = SuratService();
  String? _keterangan;

  Future<void> _updateStatus(String id, String status) async {
    try {
      if (_keterangan == null || _keterangan!.trim().isEmpty) {
        throw Exception('Keterangan harus diisi');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');

      await _suratService.updateStatus(
        suratId: id,
        status: status,
        olehUid: user.uid,
        catatan: _keterangan,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String suratId = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Surat'),
        backgroundColor: const Color(0xFF1B7B3A),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _suratService.getSuratById(suratId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final suratData = snapshot.data;
          if (suratData == null) {
            return const Center(child: Text('Surat tidak ditemukan'));
          }

          final bool isTervalidasi = suratData['status'] == 'selesai';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${suratData['kategori'] ?? '-'}'),
                        const SizedBox(height: 8),
                        Text('Keperluan: ${suratData['keperluan'] ?? '-'}'),
                        const SizedBox(height: 8),
                        Text('Status: ${suratData['status'] ?? '-'}'),
                        const SizedBox(height: 8),
                        Text(
                            'Tanggal: ${suratData['tanggalPengajuan']?.toDate()?.toString() ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(child: Text('Preview Surat')),
                ),
                const SizedBox(height: 16),
                if (isTervalidasi) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement download functionality
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Unduh'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement print functionality
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Cetak'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Catatan: ${suratData['catatan'] ?? '-'}'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Surat sudah tervalidasi',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ] else ...[
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _keterangan = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(suratId, 'selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Validasi'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(suratId, 'ditolak'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Tolak'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Surat belum tervalidasi',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
