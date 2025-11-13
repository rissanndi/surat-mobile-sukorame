import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart'; // Pastikan model surat diimpor
// import 'package:surat_mobile_sukorame/services/supabase_service.dart'; // Belum perlu di sini

class NewSuratScreen extends StatefulWidget {
  const NewSuratScreen({super.key});

  @override
  State<NewSuratScreen> createState() => _NewSuratScreenState();
}

class _NewSuratScreenState extends State<NewSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keperluanController = TextEditingController();
  String? _selectedKategori;
  bool _isLoading = false;

  final List<String> _kategoriSurat = [
    'Surat Keterangan Usaha (SKU)',
    'Surat Keterangan Domisili',
    'Surat Pengantar Nikah',
    'Surat Keterangan Kematian',
    'Surat Keterangan Tidak Mampu (SKTM)',
    'Lain-lain',
  ];

  Map<String, dynamic>? _userData; // Untuk menyimpan data profil pengguna

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data();
        });
      }
    }
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }

  Future<void> _submitSurat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori surat.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data pengguna. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User tidak login.';
      }

      // Buat dokumen baru di koleksi 'surat'
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('surat')
          .doc();

      // Buat objek Surat dengan data awal
      final newSurat = Surat(
        id: docRef.id,
        userId: user.uid,
        kategori: _selectedKategori!,
        keperluan: _keperluanController.text.trim(),
        tanggalPengajuan: DateTime.now(),
        status:
            'menunggu_upload_ttd', // Status awal: Menunggu user unduh & upload TTD
        dataPemohon: {
          'nama': _userData!['nama'],
          'nik': _userData!['nik'],
          'alamat': _userData!['alamat'],
          'rt': _userData!['rt'],
          'rw': _userData!['rw'],
          'email': _userData!['email'],
          // Tambahkan data lain yang relevan dari profil
        },
        urlSuratBerttd: null, // Awalnya kosong
        urlKtp: null, // Awalnya kosong
        urlKk: null, // Awalnya kosong
        urlSuratFinal: null, // Awalnya kosong
        catatanPenolakan: null,
        catatanRt: null,
        catatanRw: null,
      );

      // Simpan objek Surat ke Firestore
      await docRef.set(newSurat.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan surat berhasil! Silakan ikuti langkah selanjutnya.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(); // Kembali ke halaman sebelumnya (biasanya HomeScreen)
      }
    } catch (e) {
      debugPrint('Error submitting surat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengajukan surat: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajukan Surat Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Pilih Kategori Surat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori Surat',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriSurat.map((String value) {
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
                validator: (value) =>
                    value == null ? 'Pilih kategori surat' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Keperluan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keperluanController,
                decoration: const InputDecoration(
                  labelText: 'Jelaskan keperluan Anda',
                  hintText: 'Misal: Untuk melamar pekerjaan di PT...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Keperluan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitSurat,
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
}
