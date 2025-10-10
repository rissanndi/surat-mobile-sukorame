import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    setState(() { _isLoading = true; });

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'nama': _namaController.text.trim(),
        'nik': _nikController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'pekerjaan': _pekerjaanController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() { _isLoading = false; });
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
        // Isi controller dengan data dari Firestore (hanya jika field controller masih kosong)
        if (_namaController.text.isEmpty) _namaController.text = userData['nama'] ?? '';
        if (_nikController.text.isEmpty) _nikController.text = userData['nik'] ?? '';
        if (_alamatController.text.isEmpty) _alamatController.text = userData['alamat'] ?? '';
        if (_noHpController.text.isEmpty) _noHpController.text = userData['noHp'] ?? '';
        if (_pekerjaanController.text.isEmpty) _pekerjaanController.text = userData['pekerjaan'] ?? '';
        
        // Mengambil dan format tanggal lahir
        final Timestamp? tglLahirTimestamp = userData['tanggalLahir'];
        final String tglLahirFormatted = tglLahirTimestamp != null 
          ? DateFormat('dd MMMM yyyy').format(tglLahirTimestamp.toDate()) 
          : '-';

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
                
                const Text("Data Tetap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(title: const Text("Email"), subtitle: Text(userData['email'] ?? '-')),
                ListTile(title: const Text("Tempat, Tanggal Lahir"), subtitle: Text("${userData['tempatLahir'] ?? '-'}, $tglLahirFormatted")),
                ListTile(title: const Text("Jenis Kelamin"), subtitle: Text(userData['jenisKelamin'] ?? '-')),
                ListTile(title: const Text("Agama"), subtitle: Text(userData['agama'] ?? '-')),
                ListTile(title: const Text("Status Perkawinan"), subtitle: Text(userData['statusPerkawinan'] ?? '-')),
                ListTile(title: const Text("Status di Keluarga"), subtitle: Text(userData['statusDiKeluarga'] ?? '-')),
                ListTile(title: const Text("RT / RW"), subtitle: Text("RT ${userData['rt'] ?? '-'} / RW ${userData['rw'] ?? '-'}")),
                
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _saveChanges,
                        child: const Text("Simpan Perubahan"),
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}