import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:surat_mobile_sukorame/screens/detail_surat_screen.dart';

class FormSuratScreen extends StatefulWidget {
  final String userUid;
  const FormSuratScreen({super.key, required this.userUid});

  @override
  State<FormSuratScreen> createState() => _FormSuratScreenState();
}

class _FormSuratScreenState extends State<FormSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _familyMembers = [];
  final List<DropdownMenuItem<String>> _pemohonOptions = [];
  String? _selectedPemohonId;
  Map<String, dynamic>? _selectedPemohonData;

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

  Future<void> _fetchInitialData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
          .get();
      if (userDoc.exists) {
        _userProfile = userDoc.data()!..['id'] = 'diri_sendiri';
      }

      final familyQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
          .collection('anggotaKeluarga')
          .get();
      _familyMembers =
          familyQuery.docs.map((doc) => doc.data()..['id'] = doc.id).toList();

      _buildPemohonOptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gagal memuat data: $e"),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  void _onPemohonChanged(String? newId) {
    setState(() {
      _selectedPemohonId = newId;
      if (newId == 'diri_sendiri') {
        _selectedPemohonData = _userProfile;
      } else {
        _selectedPemohonData = _familyMembers
            .firstWhere((m) => m['id'] == newId, orElse: () => {});
      }
    });
  }

  Future<void> _submitSurat() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
    });

    DocumentReference? newSuratRef;

    try {
      // Bersihkan data pemohon dari field yang tidak perlu
      final Map<String, dynamic> cleanPemohonData =
          Map.from(_selectedPemohonData!);
      cleanPemohonData.remove('fcmToken');
      cleanPemohonData.remove('lastTokenUpdate');
      cleanPemohonData.remove('id');
      cleanPemohonData.remove('uid');
      cleanPemohonData.remove('urlFotoKk');
      cleanPemohonData.remove('urlFotoKtp');
      cleanPemohonData.remove('createdAt');

      newSuratRef = await FirebaseFirestore.instance.collection('surat').add({
        'userId': widget.userUid,
        'kategori': _selectedKategori,
        'dataPemohon': cleanPemohonData,
        'keperluan': _keperluanController.text.trim(),
        'status': 'menunggu_upload_ttd',
        'tanggalPengajuan': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        final newSuratSnapshot = await newSuratRef.get();
        final newSurat = Surat.fromFirestore(newSuratSnapshot);

        _showConfirmationDialog(newSurat);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membuat surat: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted)
        setState(() {
          _isSubmitting = false;
        });
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
                      items: [
                        'Surat Keterangan Domisili',
                        'Surat Keterangan Usaha',
                        'Surat Pengantar Nikah',
                        'Lainnya'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedKategori = val),
                      validator: (val) =>
                          val == null ? 'Jenis surat harus dipilih' : null,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedPemohonId,
                      hint: const Text("Pilih Pemohon Surat"),
                      items: _pemohonOptions,
                      onChanged: _onPemohonChanged,
                      validator: (val) =>
                          val == null ? 'Pemohon harus dipilih' : null,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                    if (_selectedPemohonData != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Data Pemohon (Otomatis)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(),
                            _buildReadOnlyField(
                                "Nama Lengkap", _selectedPemohonData!['nama']),
                            _buildReadOnlyField(
                                "NIK", _selectedPemohonData!['nik']),
                            _buildReadOnlyField(
                                "Alamat", _selectedPemohonData!['alamat']),
                            _buildReadOnlyField("Pekerjaan",
                                _selectedPemohonData!['pekerjaan']),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _keperluanController,
                      decoration: const InputDecoration(
                          labelText: "Tuliskan Keperluan Surat",
                          border: OutlineInputBorder()),
                      maxLines: 4,
                      validator: (val) =>
                          val!.isEmpty ? 'Keperluan harus diisi' : null,
                    ),
                    const SizedBox(height: 32),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitSurat,
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text("Ajukan Surat"),
                          )
                  ],
                ),
              ),
            ),
    );
  }

  void _showConfirmationDialog(Surat newSurat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Surat Berhasil Dibuat'),
          content: const Text(
              'Langkah selanjutnya:\n1. Download surat pada halaman detail.\n2. Print surat yang telah di-download.\n3. Tanda tangani surat tersebut.\n4. Upload kembali surat yang telah ditandatangani.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => DetailSuratScreen(surat: newSurat)),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
