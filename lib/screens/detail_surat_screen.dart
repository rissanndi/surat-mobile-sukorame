import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:surat_mobile_sukorame/models/user_model.dart';
import 'package:surat_mobile_sukorame/services/supabase_service.dart';
import 'package:surat_mobile_sukorame/services/pdf_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailSuratScreen extends StatefulWidget {
  final Surat surat;
  const DetailSuratScreen({super.key, required this.surat});

  @override
  State<DetailSuratScreen> createState() => _DetailSuratScreenState();
}

class _DetailSuratScreenState extends State<DetailSuratScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final PdfService _pdfService = PdfService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUserData;
  bool _isLoadingUserData = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      setState(() => _isLoadingUserData = false);
      return;
    }
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final userModel = await UserModel.fromFirestore(doc);
        if (mounted) {
          setState(() {
            _currentUserData = userModel;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingUserData = false);
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tidak bisa membuka: $url')));
      }
    }
  }

  Future<void> _downloadPdf() async {
    final pdfBytes = await _pdfService.generateSuratPdf(widget.surat);
    await _pdfService.printPdf(pdfBytes);
  }

  Future<void> _pickAndUploadSuratTtd(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final imageFile = File(pickedFile.path);
      final downloadUrl = await _supabaseService.uploadFile(
        imageFile,
        'surat_ttd/${widget.surat.id}',
      );

      if (downloadUrl == null) throw 'Gagal mendapatkan URL setelah upload.';

      await _firestore.collection('surat').doc(widget.surat.id).update({
        'urlSuratBerttd': downloadUrl,
        'status': 'diajukan_ke_rt',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surat berhasil diunggah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _updateSuratStatus(String newStatus, {String? catatan}) async {
    try {
      final Map<String, dynamic> updateData = {'status': newStatus};
      if (catatan != null) {
        if (newStatus == 'ditolak_rt') {
          updateData['catatanRt'] = catatan;
        } else if (newStatus == 'ditolak_rw') {
          updateData['catatanRw'] = catatan;
        }
      }

      await _firestore
          .collection('surat')
          .doc(widget.surat.id)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status surat berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRejectionDialog(String newStatus) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Surat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Alasan Penolakan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateSuratStatus(newStatus, catatan: controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialActionSection(Surat currentSurat) {
    final user = _currentUserData;
    if (user == null) return const SizedBox.shrink();

    final isRt = user.role == 'rt' || user.role == 'rt_rw';
    final isRw = user.role == 'rw' || user.role == 'rt_rw';

    bool canAct = false;
    String newStatusOnApprove = '';
    String newStatusOnReject = '';

    if (isRt &&
        currentSurat.status == 'diajukan_ke_rt' &&
        user.rt == currentSurat.dataPemohon['rt']) {
      canAct = true;
      newStatusOnApprove = 'diajukan_ke_rw';
      newStatusOnReject = 'ditolak_rt';
    } else if (isRw &&
        currentSurat.status == 'diajukan_ke_rw' &&
        user.rw == currentSurat.dataPemohon['rw']) {
      canAct = true;
      newStatusOnApprove = 'disetujui_rw';
      newStatusOnReject = 'ditolak_rw';
    }

    if (!canAct) return const SizedBox.shrink();

    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tindakan Pengurus',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRejectionDialog(newStatusOnReject),
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateSuratStatus(newStatusOnApprove),
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWargaActionSection(Surat currentSurat) {
    switch (currentSurat.status) {
      case 'menunggu_upload_ttd':
        return Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Langkah Selanjutnya",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "1. Unduh & Cetak Draf Surat.\n2. Tanda tangani.\n3. Foto/Scan hasilnya lalu unggah kembali.",
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.download),
                  label: const Text("Unduh Draf Surat (PDF)"),
                ),
                const SizedBox(height: 8),
                if (_isUploading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _pickAndUploadSuratTtd(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Kamera"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _pickAndUploadSuratTtd(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Galeri"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      // Other cases for warga...
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surat.kategori)),
      body: _isLoadingUserData
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('surat')
                  .doc(widget.surat.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final updatedSurat = Surat.fromFirestore(snapshot.data!);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action section for officials (RT/RW)
                      _buildOfficialActionSection(updatedSurat),
                      // Action section for the citizen who created the letter
                      if (_auth.currentUser?.uid == updatedSurat.userId)
                        _buildWargaActionSection(updatedSurat),

                      const SizedBox(height: 24),
                      const Text(
                        "Detail Pengajuan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Status"),
                        subtitle: Text(
                          updatedSurat.status
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Keperluan"),
                        subtitle: Text(updatedSurat.keperluan),
                      ),
                      if (updatedSurat.urlSuratBerttd != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Surat Bertanda Tangan"),
                          subtitle: InkWell(
                            onTap: () =>
                                _launchURL(updatedSurat.urlSuratBerttd!),
                            child: const Text(
                              'Lihat Lampiran',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      // ... other details
                    ],
                  ),
                );
              },
            ),
    );
  }
}
