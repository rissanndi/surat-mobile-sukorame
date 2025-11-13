import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:surat_mobile_sukorame/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/surat_model.dart';

class ApprovedLettersScreen extends StatelessWidget {
  const ApprovedLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat Disetujui'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('surat')
            .where('status', whereIn: ['disetujui_rw', 'selesai'])
            .orderBy('tanggalPengajuan', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final letters = snapshot.data?.docs ?? [];
          
          if (letters.isEmpty) {
            return const Center(child: Text('Belum ada surat yang disetujui'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final surat = Surat.fromFirestore(letters[index]);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(surat.kategori),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pemohon: ${surat.dataPemohon['nama'] ?? 'Tidak tersedia'}'),
                      Text('Tanggal: ${DateFormat('dd MMMM yyyy').format(surat.tanggalPengajuan)}'),
                      Row(
                        children: [
                          _buildStatusChip(surat.status),
                          if (surat.urlSuratFinal != null) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Surat Final'),
                              avatar: const Icon(Icons.file_present, size: 16),
                              backgroundColor: Colors.blue.shade100,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _showDetailDialog(context, surat),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusMap = {
      'disetujui_rw': {'label': 'Disetujui RW', 'color': Colors.orange.shade100, 'textColor': Colors.orange.shade900},
      'selesai': {'label': 'Selesai', 'color': Colors.green.shade100, 'textColor': Colors.green.shade900},
    };

    final statusData = statusMap[status.toLowerCase()] ?? {'label': status, 'color': Colors.grey.shade100, 'textColor': Colors.grey.shade900};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusData['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusData['label'] as String,
        style: TextStyle(color: statusData['textColor'] as Color, fontSize: 12),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Surat surat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(surat.kategori),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(context, 'Pemohon', surat.dataPemohon['nama']),
              _buildDetailItem(context, 'NIK', surat.dataPemohon['nik']),
              _buildDetailItem(context, 'Alamat', surat.dataPemohon['alamat']),
              _buildDetailItem(context, 'RT/RW', '${surat.dataPemohon['rt']}/${surat.dataPemohon['rw']}'),
              _buildDetailItem(context, 'Keperluan', surat.keperluan),
              _buildDetailItem(context, 'Tanggal Pengajuan', 
                DateFormat('dd MMMM yyyy').format(surat.tanggalPengajuan)),
              _buildDetailItem(context, 'Status', surat.status),
              if (surat.catatanRt != null)
                _buildDetailItem(context, 'Catatan RT', surat.catatanRt!),
              if (surat.catatanRw != null)
                _buildDetailItem(context, 'Catatan RW', surat.catatanRw!),
              if (surat.urlSuratFinal != null)
                _buildDetailItem(context, 'Surat Final', 'Tersedia', isLink: true, url: surat.urlSuratFinal),
            ],
          ),
        ),
        actions: [
          if (surat.status == 'disetujui_rw')
            ElevatedButton(
              onPressed: () => _uploadFinalLetter(context, surat),
              child: const Text('Upload Surat Final'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFinalLetter(BuildContext context, Surat surat) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;

    try {
      final File imageFile = File(pickedFile.path);
      final String? downloadUrl = await SupabaseService().uploadFile(imageFile, 'surat_final/${surat.id}');

      if (downloadUrl == null) {
        throw 'Gagal mendapatkan URL setelah upload.';
      }

      await FirebaseFirestore.instance.collection('surat').doc(surat.id).update({
        'urlSuratFinal': downloadUrl,
        'status': 'selesai',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Surat final berhasil diunggah!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengunggah surat: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildDetailItem(BuildContext context, String label, String? value, {bool isLink = false, String? url}) {
    if (value == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          if (isLink && url != null)
            InkWell(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak bisa membuka: $url')));
                }
                            },
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(value),
          const Divider(),
        ],
      ),
    );
  }
}