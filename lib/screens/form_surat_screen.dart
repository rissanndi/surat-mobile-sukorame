import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Ganti dengan ID user yang sedang login nantinya
const String currentUserId = "id_user_warga_1";

class FormSuratScreen extends StatefulWidget {
  final String userUid;
  const FormSuratScreen({super.key, required this.userUid});

  @override
  State<FormSuratScreen> createState() => _FormSuratScreenState();
}

class _FormSuratScreenState extends State<FormSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk setiap input
  final _namaController = TextEditingController(text: "Budi Santoso (Otomatis)");
  final _nikController = TextEditingController(text: "350xxxxxxxx (Otomatis)");
  final _keperluanController = TextEditingController();

  String? _selectedKategori;
  final List<String> _kategoriOptions = [
    'Surat Keterangan Domisili',
    'Surat Keterangan Usaha',
    'Surat Pengantar Nikah',
    'Lainnya'
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Data yang akan disimpan ke Firestore
        final Map<String, dynamic> dataSurat = {
          'pembuatId': widget.userUid,
          'kategori': _selectedKategori,
          'dataPemohon': { // Data ini nantinya akan diambil dari profil user
            'nama': _namaController.text,
            'nik': _nikController.text,
          },
          'keperluan': _keperluanController.text,
          'status': 'diajukan',
          'tanggalPengajuan': Timestamp.now(),
          'catatanPenolakan': null,
          // --- MENGGUNAKAN PLACEHOLDER UNTUK GAMBAR ---
          'urlTtdPemohon': 'placeholder.jpg',
          'urlKtp': 'placeholder.jpg',
          'urlKk': 'placeholder.jpg',
        };

        // Simpan ke Firestore
        await FirebaseFirestore.instance.collection('surat').add(dataSurat);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Surat berhasil diajukan!')),
        );
        Navigator.of(context).pop();

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pengajuan Surat"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kategori Surat
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                hint: const Text("Pilih Kategori Surat"),
                items: _kategoriOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedKategori = newValue;
                  });
                },
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // Data Diri (Contoh Otomatis)
              TextFormField(
                controller: _namaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Nama", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nikController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "NIK", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              // Keperluan
              TextFormField(
                controller: _keperluanController,
                decoration: const InputDecoration(labelText: "Keperluan / Keterangan", border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Keperluan harus diisi' : null,
              ),
              const SizedBox(height: 24),
              
              // --- TOMBOL UPLOAD PLACEHOLDER ---
              const Text("Dokumen Pendukung:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildPlaceholderUpload("Upload KTP"),
              _buildPlaceholderUpload("Upload KK"),
              _buildPlaceholderUpload("Upload Tanda Tangan"),
              
              const SizedBox(height: 32),
              
              // Tombol Aksi
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Ajukan Surat"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk tombol upload palsu
  Widget _buildPlaceholderUpload(String title) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_upload_outlined),
        title: Text(title),
        trailing: const Icon(Icons.check_circle, color: Colors.grey),
        onTap: () {
          // Tidak melakukan apa-apa saat diklik
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur upload akan ditambahkan nanti.')),
          );
        },
      ),
    );
  }
}