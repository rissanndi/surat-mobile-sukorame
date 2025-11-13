import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';
import 'package:surat_mobile_sukorame/models/user_model.dart';
import 'package:surat_mobile_sukorame/screens/admin/admin_main_screen.dart';
import 'package:surat_mobile_sukorame/widgets/surat_card.dart';
import 'package:surat_mobile_sukorame/screens/detail_surat_screen.dart';
import 'package:surat_mobile_sukorame/screens/form_surat_screen.dart';
import 'package:surat_mobile_sukorame/screens/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final userModel = await UserModel.fromFirestore(doc);
        if (mounted) {
          setState(() {
            _currentUserData = userModel;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = _currentUserData?.role ?? 'warga';

    switch (role) {
      case 'kelurahan':
        return AdminMainScreen(); // Redirect to the main admin screen
      case 'rt':
      case 'rw':
      case 'rt_rw':
        return _buildRtRwDashboard();
      case 'warga':
      default:
        return _buildWargaDashboard();
    }
  }

  Widget _buildRtRwDashboard() {
    final user = _currentUserData!;
    bool isRt = user.role == 'rt' || user.role == 'rt_rw';
    bool isRw = user.role == 'rw' || user.role == 'rt_rw';

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Pengurus')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRt)
              _buildSuratList(
                title: 'Menunggu Persetujuan RT',
                status: 'diajukan_ke_rt',
                rt: user.rt,
              ),
            if (isRw)
              _buildSuratList(
                title: 'Menunggu Persetujuan RW',
                status: 'diajukan_ke_rw',
                rw: user.rw,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuratList({required String title, required String status, String? rt, String? rw}) {
    Query query = _firestore.collection('surat').where('status', isEqualTo: status);

    if (rt != null) {
      query = query.where('dataPemohon.rt', isEqualTo: rt);
    }
    if (rw != null) {
      query = query.where('dataPemohon.rw', isEqualTo: rw);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada surat untuk ditinjau.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final surat = Surat.fromFirestore(snapshot.data!.docs[index]);
                    return SuratCard(surat: surat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWargaDashboard() {
    final currentUser = _auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Layanan Surat Sukorame'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen())),
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.grey.shade700, size: 30),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Riwayat Surat Anda", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('surat').where('userId', isEqualTo: currentUser!.uid).orderBy('tanggalPengajuan', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada riwayat surat."));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final surat = Surat.fromFirestore(snapshot.data!.docs[index]);
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailSuratScreen(surat: surat))),
                        child: SuratCard(surat: surat),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormSuratScreen(userUid: currentUser.uid))),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Buat Pengajuan Surat", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
