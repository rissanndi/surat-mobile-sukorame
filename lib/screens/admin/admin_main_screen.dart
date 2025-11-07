import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surat_mobile_sukorame/screens/admin/approved_letters_screen.dart';
import 'package:surat_mobile_sukorame/screens/admin/penduduk_screen.dart';
import 'package:surat_mobile_sukorame/screens/admin/rt_rw_screen.dart';
import 'package:surat_mobile_sukorame/screens/admin/riwayat_rt_rw_screen.dart';
import 'package:surat_mobile_sukorame/screens/admin/rekrut_rt_rw_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = (screenSize.width - 48) / 2; // 2 columns with 16 padding
    final cardHeight = cardWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Kelurahan'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                // Navigate to account/settings screen
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SizedBox())); // placeholder if needed
              } else if (value == 'logout') {
                await Future.microtask(() => FirebaseAuth.instance.signOut());
                // After sign out, auth stream will redirect to Login via AuthGate
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person), SizedBox(width:8), Text('Akun')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width:8), Text('Logout', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selamat Datang, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Data Penduduk',
                  icon: Icons.people,
                  color: Colors.green[600]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PendudukScreen()),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                ),
                _buildMenuCard(
                  context,
                  title: 'Surat Disetujui',
                  icon: Icons.mail,
                  color: Colors.green[700]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApprovedLettersScreen()),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                ),
                _buildMenuCard(
                  context,
                  title: 'RT/RW Aktif',
                  icon: Icons.person_2,
                  color: Colors.green[800]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RTRWScreen()),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                ),
                _buildMenuCard(
                  context,
                  title: 'Riwayat RT/RW',
                  icon: Icons.history,
                  color: Colors.green[900]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatRTRWScreen()),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                ),
                _buildMenuCard(
                  context,
                  title: 'Rekrut RT/RW',
                  icon: Icons.person_add,
                  color: Colors.green[500]!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RekrutRTRWScreen()),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4,
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}