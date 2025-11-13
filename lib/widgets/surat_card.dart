import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:intl/intl.dart';
import 'package:surat_mobile_sukorame/screens/detail_surat_screen.dart'; // Import DetailSuratScreen

class SuratCard extends StatelessWidget {
  final Surat surat;
  const SuratCard({super.key, required this.surat});

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
      case 'menunggu_upload_ttd':
        return {
          'text': 'Perlu Tindakan',
          'textColor': Colors.blue.shade800,
          'backgroundColor': Colors.blue.shade100,
          'borderColor': Colors.blue.shade400,
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

  void _handleMenuSelection(String value, BuildContext context) {
    if (value == 'detail') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailSuratScreen(surat: surat)));
    } else if (value == 'batal') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Batalkan Pengajuan?"),
          content: const Text("Apakah Anda yakin ingin membatalkan pengajuan surat ini? Tindakan ini tidak dapat diurungkan."),
          actions: [
            TextButton(child: const Text("Tidak"), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('surat').doc(surat.id).delete();
                  // Tutup dialog
                  Navigator.of(ctx).pop(); 
                  // Tampilkan snackbar sukses
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan surat berhasil dibatalkan.'), backgroundColor: Colors.green));
                } catch (e) {
                  // Tampilkan snackbar error
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membatalkan surat: $e'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = _getStatusAppearance(surat.status);
    final formattedDate = DateFormat('dd MMMM yyyy').format(surat.tanggalPengajuan);

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
          // Navigasi ke halaman detail surat saat card di-tap
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailSuratScreen(surat: surat)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surat.kategori.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (surat.status != 'selesai' && surat.status != 'ditolak_rt' && surat.status != 'ditolak_rw')
                      const Text(
                        "Estimasi selesai 24 jam kerja",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
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
                  // PopupMenuButton sebagai ganti ikon chevron_right
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey), // Ikon tiga titik vertikal
                    onSelected: (value) => _handleMenuSelection(value, context),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Lihat Detail'),
                          ],
                        ),
                      ),
                      // Tampilkan opsi "Batalkan" hanya jika status memungkinkan
                      if (surat.status == 'menunggu_upload_ttd' || surat.status == 'diajukan_ke_rt')
                        const PopupMenuItem<String>(
                          value: 'batal',
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Batalkan Pengajuan', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}