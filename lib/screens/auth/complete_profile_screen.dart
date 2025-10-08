import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:surat_mobile_sukorame/services/gdrive_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driveService = GoogleDriveService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  // State untuk Dropdown & Date
  DateTime? _selectedDate;
  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  
  // Variabel state untuk file
  String? _ktpFileName;
  String? _gdriveFileIdKtp;
  String? _kkFileName;
  String? _gdriveFileIdKk;

  @override
  void dispose(){
    // ... dispose semua controller ...
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // ... (fungsi _pickAndUploadFile tetap sama seperti sebelumnya)

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    // ... (validasi upload KTP & KK tetap sama)
    setState(() { _isLoading = true; });

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
        // ... field uid, email, noHp, nama, nik, alamat, tempatLahir, pekerjaan (sama seperti sebelumnya)
        // Menambahkan field yang baru
        'tanggalLahir': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'jenisKelamin': _selectedJenisKelamin ?? '',
        'agama': _selectedAgama ?? '',
        'statusPerkawinan': _selectedStatusKawin ?? '',
        'rt': _rtController.text.trim(),
        'rw': _rwController.text.trim(),
        'kewarganegaraan': 'WNI',
        // ... (field gdrive_fileId, role, createdAt tetap sama)
      });
    } catch (e) {
      // ... error handling
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lengkapi Profil Anda"), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... TextFormField untuk Nama, NIK, Alamat, No HP, Tempat Lahir, Pekerjaan (sama seperti sebelumnya)
              const SizedBox(height: 16),

              // Input Tanggal Lahir
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedDate == null ? 'Pilih Tanggal Lahir' : 'Tanggal Lahir: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Dropdown Jenis Kelamin
              DropdownButtonFormField<String>(
                value: _selectedJenisKelamin,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin', border: OutlineInputBorder()),
                items: ['Laki-laki', 'Perempuan'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _selectedJenisKelamin = val),
                validator: (val) => val == null ? 'Pilih jenis kelamin' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Agama
              DropdownButtonFormField<String>(
                value: _selectedAgama,
                decoration: const InputDecoration(labelText: 'Agama', border: OutlineInputBorder()),
                items: ['Islam', 'Kristen Protestan', 'Kristen Katolik', 'Hindu', 'Buddha', 'Khonghucu'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _selectedAgama = val),
                validator: (val) => val == null ? 'Pilih agama' : null,
              ),
              const SizedBox(height: 16),
              
              // Dropdown Status Perkawinan
              DropdownButtonFormField<String>(
                value: _selectedStatusKawin,
                decoration: const InputDecoration(labelText: 'Status Perkawinan', border: OutlineInputBorder()),
                items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatusKawin = val),
                validator: (val) => val == null ? 'Pilih status' : null,
              ),
              const SizedBox(height: 16),

              // Input RT & RW
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _rtController, decoration: const InputDecoration(labelText: 'RT', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _rwController, decoration: const InputDecoration(labelText: 'RW', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Dokumen Pendukung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              // ... Tombol Upload KTP & KK (sama seperti sebelumnya) ...
              
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      // ... (styling tombol sama seperti sebelumnya)
                      child: const Text("Simpan dan Lanjutkan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (widget _buildUploadButton tetap sama seperti sebelumnya)
}