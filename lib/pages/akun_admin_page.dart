import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunAdminPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AkunAdminPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      final email = user.email;
      if (email == null) {
        throw Exception('Email not found');
      }

      await _auth.sendPasswordResetEmail(email: email);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email reset password telah dikirim')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Admin'),
        backgroundColor: const Color(0xFF1B7B3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Admin Desa Sukorame',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'admin@sukorame.id',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFF1B7B3A)),
              title: const Text('Ganti Password'),
              onTap: () => _changePassword(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF1B7B3A)),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
