import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/encryption.dart';

class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  final _formKey = GlobalKey<FormState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // Controllers untuk semua field yang bisa diedit
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  // Cache decrypted values to avoid repeated async decrypts for UI
  final Map<String, String> _decryptedFields = {};

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || currentUser == null) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Encrypt sensitive fields client-side before sending to Firestore.
      final encNama = await encryptField(_namaController.text.trim());
      final encNik = await encryptField(_nikController.text.trim());
      final encAlamat = await encryptField(_alamatController.text.trim());
      final encNoHp = await encryptField(_noHpController.text.trim());
      final encPekerjaan = await encryptField(_pekerjaanController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'nama': encNama,
        'nik': encNik,
        'alamat': encAlamat,
        'noHp': encNoHp,
        'pekerjaan': encPekerjaan,
        // koordinatAlamat akan diupdate terpisah oleh _getCurrentLocation
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
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

  // Async helper: decrypt fields from userData and populate controllers/cache.
  Future<void> _decryptAndSetControllers(Map<String, dynamic> userData) async {
    try {
      final nama = await tryDecryptField(userData['nama'] as String?);
      final nik = await tryDecryptField(userData['nik'] as String?);
      final alamat = await tryDecryptField(userData['alamat'] as String?);
      final noHp = await tryDecryptField(userData['noHp'] as String?);
      final pekerjaan = await tryDecryptField(userData['pekerjaan'] as String?);
      final tempatLahir = await tryDecryptField(userData['tempatLahir'] as String?);

      if (mounted) {
        setState(() {
        if (_namaController.text.isEmpty) _namaController.text = nama;
        if (_nikController.text.isEmpty) _nikController.text = nik;
        if (_alamatController.text.isEmpty) _alamatController.text = alamat;
        if (_noHpController.text.isEmpty) _noHpController.text = noHp;
        if (_pekerjaanController.text.isEmpty) _pekerjaanController.text = pekerjaan;

        _decryptedFields['tempatLahir'] = tempatLahir;
        _decryptedFields['jenisKelamin'] = userData['jenisKelamin'] ?? '';
        _decryptedFields['agama'] = userData['agama'] ?? '';
        _decryptedFields['statusPerkawinan'] = userData['statusPerkawinan'] ?? '';
        _decryptedFields['statusDiKeluarga'] = userData['statusDiKeluarga'] ?? '';
        _decryptedFields['rt'] = (userData['rt'] ?? '').toString();
        _decryptedFields['rw'] = (userData['rw'] ?? '').toString();
      });
      }
    } catch (_) {
      // ignore decryption errors for UI; show raw values instead
    }
  }


  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("User tidak ditemukan."));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Data profil tidak ditemukan."));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        
        // Decrypt and fill controllers/cache (async). Only call once when controllers are empty.
        if (_namaController.text.isEmpty && _nikController.text.isEmpty && _alamatController.text.isEmpty && _noHpController.text.isEmpty && _pekerjaanController.text.isEmpty) {
          // run async decrypt and populate controllers
          _decryptAndSetControllers(userData);
        }
        
        // Mengambil dan format tanggal lahir - handle berbagai tipe (Timestamp atau String)
        final dynamic tglLahirField = userData['tanggalLahir'];
        String tglLahirFormatted = '-';
        try {
          if (tglLahirField == null) {
            tglLahirFormatted = '-';
          } else if (tglLahirField is Timestamp) {
            tglLahirFormatted = DateFormat('dd MMMM yyyy').format(tglLahirField.toDate());
          } else if (tglLahirField is String) {
            // Coba parse ISO-8601 seperti "yyyy-MM-dd" atau fallback ke string mentah
            try {
              final dt = DateTime.parse(tglLahirField);
              tglLahirFormatted = DateFormat('dd MMMM yyyy').format(dt);
            } catch (_) {
              tglLahirFormatted = tglLahirField;
            }
          } else {
            // Jika tipe lain, paksa jadi string
            tglLahirFormatted = tglLahirField.toString();
          }
        } catch (e) {
          // Guard: jika parsing gagal, tampilkan tanda '-'
          tglLahirFormatted = '-';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Data yang Bisa Diubah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _nikController, decoration: const InputDecoration(labelText: 'NIK', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.length != 16 ? 'NIK harus 16 digit' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _alamatController, decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _noHpController, decoration: const InputDecoration(labelText: 'No. HP', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _pekerjaanController, decoration: const InputDecoration(labelText: 'Pekerjaan', border: OutlineInputBorder())),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text("Data Tetap (Tidak Dapat Diubah)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(title: const Text("Email"), subtitle: Text(userData['email'] ?? '-')),
                ListTile(title: const Text("Tempat, Tanggal Lahir"), subtitle: Text("${_decryptedFields['tempatLahir'] ?? userData['tempatLahir'] ?? '-'}, $tglLahirFormatted")),
                ListTile(title: const Text("Jenis Kelamin"), subtitle: Text(_decryptedFields['jenisKelamin'] ?? userData['jenisKelamin'] ?? '-')),
                ListTile(title: const Text("Agama"), subtitle: Text(_decryptedFields['agama'] ?? userData['agama'] ?? '-')),
                ListTile(title: const Text("Status Perkawinan"), subtitle: Text(_decryptedFields['statusPerkawinan'] ?? userData['statusPerkawinan'] ?? '-')),
                ListTile(title: const Text("Status di Keluarga"), subtitle: Text(_decryptedFields['statusDiKeluarga'] ?? userData['statusDiKeluarga'] ?? '-')),
                ListTile(title: const Text("RT / RW"), subtitle: Text("RT ${_decryptedFields['rt'] ?? userData['rt'] ?? '-'} / RW ${_decryptedFields['rw'] ?? userData['rw'] ?? '-'}")),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                

                const SizedBox(height: 32),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _saveChanges,
                        child: const Text("Simpan Perubahan Profil"),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}