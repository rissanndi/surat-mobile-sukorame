import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormSuratScreen extends StatefulWidget {
  final String userUid;
  const FormSuratScreen({super.key, required this.userUid});

  @override
  State<FormSuratScreen> createState() => _FormSuratScreenState();
}

class _FormSuratScreenState extends State<FormSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true; // Loading untuk mengambil data awal
  bool _isSubmitting = false; // Loading untuk proses pengajuan

  // State untuk data
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _familyMembers = [];
  List<DropdownMenuItem<String>> _pemohonOptions = [];
  String? _selectedPemohonId;
  Map<String, dynamic>? _selectedPemohonData;

  // Controllers & State untuk form
  final _keperluanController = TextEditingController();
  String? _selectedKategori;
  
  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }
  
  // Fungsi untuk mengambil data awal dengan penanganan error
  Future<void> _fetchInitialData() async {
    try {
      // Ambil data profil utama
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userUid).get();
      if (userDoc.exists) {
        _userProfile = userDoc.data()!..['id'] = 'diri_sendiri'; // Tambahkan id khusus
      }

      // Ambil data anggota keluarga
      final familyQuery = await FirebaseFirestore.instance.collection('users').doc(widget.userUid).collection('anggotaKeluarga').get();
      _familyMembers = familyQuery.docs.map((doc) {
        return doc.data()..['id'] = doc.id; // Tambahkan id dokumen
      }).toList();

      // Bangun opsi untuk dropdown pemohon
      _buildPemohonOptions();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Membangun item-item untuk dropdown pemohon
  void _buildPemohonOptions() {
    _pemohonOptions.clear();
    if (_userProfile != null) {
      _pemohonOptions.add(DropdownMenuItem(
        value: 'diri_sendiri',
        child: Text("${_userProfile!['nama']} (Saya Sendiri)"),
      ));
    }
    for (var member in _familyMembers) {
      _pemohonOptions.add(DropdownMenuItem(
        value: member['id'],
        child: Text("${member['nama']} (${member['statusDiKeluarga']})"),
      ));
    }
  }

  // Memperbarui data yang ditampilkan saat pemohon dipilih
  void _onPemohonChanged(String? newId) {
    setState(() {
      _selectedPemohonId = newId;
      if (newId == 'diri_sendiri') {
        _selectedPemohonData = _userProfile;
      } else {
        _selectedPemohonData = _familyMembers.firstWhere((m) => m['id'] == newId, orElse: () => {});
      }
    });
  }

  // Proses pengajuan surat
  Future<void> _submitSurat() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; });

    try {
      await FirebaseFirestore.instance.collection('surat').add({
        'pembuatId': widget.userUid,
        'kategori': _selectedKategori,
        'dataPemohon': _selectedPemohonData, // Simpan salinan lengkap data pemohon
        'keperluan': _keperluanController.text.trim(),
        'status': 'menunggu_upload_ttd', // Status awal sesuai alur baru
        'tanggalPengajuan': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draf surat berhasil dibuat! Lanjutkan ke proses TTD.'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat surat: $e'), backgroundColor: Colors.red));
    } finally {
       if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Pengajuan Surat")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      hint: const Text("Pilih Jenis Surat"),
                      items: ['Surat Keterangan Domisili', 'Surat Keterangan Usaha', 'Surat Pengantar Nikah', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedKategori = val),
                      validator: (val) => val == null ? 'Jenis surat harus dipilih' : null,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedPemohonId,
                      hint: const Text("Pilih Pemohon Surat"),
                      items: _pemohonOptions,
                      onChanged: _onPemohonChanged,
                      validator: (val) => val == null ? 'Pemohon harus dipilih' : null,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    
                    if (_selectedPemohonData != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Data Pemohon (Otomatis)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(),
                            _buildReadOnlyField("Nama Lengkap", _selectedPemohonData!['nama']),
                            _buildReadOnlyField("NIK", _selectedPemohonData!['nik']),
                            _buildReadOnlyField("Alamat", _selectedPemohonData!['alamat']),
                            _buildReadOnlyField("Pekerjaan", _selectedPemohonData!['pekerjaan']),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _keperluanController,
                      decoration: const InputDecoration(labelText: "Tuliskan Keperluan Surat", border: OutlineInputBorder()),
                      maxLines: 4,
                      validator: (val) => val!.isEmpty ? 'Keperluan harus diisi' : null,
                    ),
                    const SizedBox(height: 32),
                    _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitSurat,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text("Lanjutkan ke Proses Cetak & TTD"),
                        )
                  ],
                ),
              ),
            ),
    );
  }

  // Widget helper untuk menampilkan data read-only
  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value ?? 'Data tidak ditemukan',
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}