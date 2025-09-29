import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Controllers untuk semua field profil
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  // TODO: Tambahkan controller untuk field lainnya jika perlu (agama, status, dll)

  @override
  void initState() {
    super.initState();
    // Pastikan currentUser tidak null sebelum memuat data
    if (currentUser != null) {
      _loadUserData();
    } else {
      // Handle jika user null, meskipun seharusnya tidak terjadi di sini
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leak
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; });
    
    final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    
    if (doc.exists) {
      final data = doc.data()!;
      _namaController.text = data['nama'] ?? '';
      _nikController.text = data['nik'] ?? '';
      _alamatController.text = data['alamat'] ?? '';
      _noHpController.text = data['noHp'] ?? '';
      _tempatLahirController.text = data['tempatLahir'] ?? '';
      _pekerjaanController.text = data['pekerjaan'] ?? '';
    }
    
    setState(() { _isLoading = false; });
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate() || currentUser == null) return;
    
    setState(() { _isLoading = true; });

    try {
      // =========================================================
      // PERUBAHAN UTAMA: MENGGUNAKAN .update() BUKAN .set()
      // =========================================================
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'nama': _namaController.text.trim(),
        'nik': _nikController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'tempatLahir': _tempatLahirController.text.trim(),
        'pekerjaan': _pekerjaanController.text.trim(),
        // Anda bisa tambahkan field lain di sini
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Akun"),
         actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData, // Tambahkan fitur refresh
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _nikController, decoration: const InputDecoration(labelText: 'NIK', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _alamatController, decoration: const InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _noHpController, decoration: const InputDecoration(labelText: 'No. HP', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _tempatLahirController, decoration: const InputDecoration(labelText: 'Tempat Lahir', border: OutlineInputBorder())),
                       const SizedBox(height: 16),
                      TextFormField(controller: _pekerjaanController, decoration: const InputDecoration(labelText: 'Pekerjaan', border: OutlineInputBorder())),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text("Simpan Perubahan"),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}