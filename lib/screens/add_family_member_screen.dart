import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:surat_mobile_sukorame/services/supabase_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  // State
  DateTime? _selectedDate;
  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  String? _selectedStatusKeluarga;
  String? _ktpFileName;
  String? _urlKtp;
  String? _kkFileName;
  String? _urlKk;
  bool _setujuDenganSyarat = false;

  @override
  void dispose() {
    // ... dispose semua controller ...
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _pickAndUploadFile(String docType) async {
    final ImagePicker picker = ImagePicker();
    ImageSource? source;
    await showModalBottomSheet(context: context, builder: (BuildContext context) {
      return SafeArea(child: Wrap(children: <Widget>[
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Pilih dari Galeri'), onTap: () { source = ImageSource.gallery; Navigator.of(context).pop(); }),
        ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Ambil Foto dari Kamera'), onTap: () { source = ImageSource.camera; Navigator.of(context).pop(); }),
      ]));
    });

    if (source == null) return;
    final XFile? image = await picker.pickImage(source: source!);
    if (image == null) return;

    File file = File(image.path);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengunggah ${file.path.split('/').last}...")));
    final publicUrl = await _supabaseService.uploadFile(file, docType);
    if (publicUrl != null) {
      setState(() {
        if (docType == 'ktp') { _ktpFileName = file.path.split('/').last; _urlKtp = publicUrl; } 
        else if (docType == 'kk') { _kkFileName = file.path.split('/').last; _urlKk = publicUrl; }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$docType berhasil diunggah!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengunggah $docType."), backgroundColor: Colors.red));
    }
  }

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate() || !_setujuDenganSyarat) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi semua data dan centang kotak persetujuan."), backgroundColor: Colors.red));
      return;
    }
    if (_urlKtp == null || _urlKk == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon unggah KTP dan KK."), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Menyimpan ke sub-koleksi 'anggotaKeluarga'
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('anggotaKeluarga').add({
        'nama': _namaController.text.trim(), 'nik': _nikController.text.trim(),
        'tempatLahir': _tempatLahirController.text.trim(), 'pekerjaan': _pekerjaanController.text.trim(),
        'urlFotoKtp': _urlKtp, 'urlFotoKk': _urlKk,
        'tanggalLahir': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'jenisKelamin': _selectedJenisKelamin ?? '', 'agama': _selectedAgama ?? '',
        'statusPerkawinan': _selectedStatusKawin ?? '', 'statusDiKeluarga': _selectedStatusKeluarga ?? '',
        'kewarganegaraan': 'WNI',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anggota keluarga berhasil ditambahkan!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Anggota Keluarga")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Semua field form sama persis dengan CompleteProfileScreen,
              // jadi Anda bisa salin-tempel dari sana.
              TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama Lengkap (sesuai KTP)"), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _nikController, decoration: const InputDecoration(labelText: "NIK"), keyboardType: TextInputType.number, maxLength: 16, validator: (v) => v!.length != 16 ? 'NIK harus 16 digit' : null),
              // ... Tambahkan semua field lainnya (Tempat Lahir, Tanggal Lahir, Radio, Dropdown, dll) persis seperti di CompleteProfileScreen
              const SizedBox(height: 24),
              const Text("Dokumen Pendukung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildUploadButton(title: 'Upload Foto KTP', fileName: _ktpFileName, onPressed: () => _pickAndUploadFile('ktp')),
              const SizedBox(height: 12),
              _buildUploadButton(title: 'Upload Foto KK', fileName: _kkFileName, onPressed: () => _pickAndUploadFile('kk')),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text("Saya menyatakan data anggota keluarga ini benar.", style: TextStyle(fontSize: 14)),
                value: _setujuDenganSyarat,
                onChanged: (val) => setState(() => _setujuDenganSyarat = val!),
                controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoading || !_setujuDenganSyarat ? null : _addMember,
                      child: const Text("Simpan Anggota Keluarga"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Anda bisa salin-tempel widget _buildUploadButton dari CompleteProfileScreen ke sini
  Widget _buildUploadButton({required String title, String? fileName, required VoidCallback onPressed}) {
     bool isUploaded = fileName != null;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(isUploaded ? Icons.check_circle : Icons.upload_file),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(fileName ?? title, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUploaded ? Colors.green : null))),
            if (isUploaded) const Icon(Icons.done, color: Colors.green)
          ],
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isUploaded ? Colors.green : Colors.black54,
        side: BorderSide(color: isUploaded ? Colors.green : Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}