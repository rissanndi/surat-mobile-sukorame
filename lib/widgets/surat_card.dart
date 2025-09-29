import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:intl/intl.dart';

class SuratCard extends StatelessWidget {
  final Surat surat;
  const SuratCard({super.key, required this.surat});

  // Fungsi untuk menentukan warna, teks, dan border status
  Map<String, dynamic> _getStatusAppearance(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return {
          'text': 'Selesai',
          'textColor': Colors.green.shade800,
          'backgroundColor': Colors.green.shade100,
          'borderColor': Colors.green.shade400,
        };
      case 'ditolak_rt':
      case 'ditolak_rw':
      case 'ditolak': // Menambahkan fallback "ditolak"
        return {
          'text': 'Ditolak',
          'textColor': Colors.red.shade800,
          'backgroundColor': Colors.red.shade100,
          'borderColor': Colors.red.shade400,
        };
      default: // 'diajukan', 'diproses_rt', 'disetujui_rt', dll.
        return {
          'text': 'Diproses',
          'textColor': Colors.orange.shade800,
          'backgroundColor': Colors.orange.shade100,
          'borderColor': Colors.orange.shade400,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = _getStatusAppearance(surat.status);
    final formattedDate = DateFormat('dd/MM/yyyy').format(surat.tanggalPengajuan.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: appearance['borderColor'], width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigasi ke halaman detail surat
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailSuratScreen(surat: surat)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SURAT PENGANTAR / KETERANGAN",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (surat.status != 'selesai' && surat.status != 'ditolak')
                      const Text(
                        "Estimasi selesai 24 jam kerja",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    if (surat.status == 'selesai' || surat.status == 'ditolak')
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: appearance['backgroundColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appearance['text'],
                      style: TextStyle(color: appearance['textColor'], fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}