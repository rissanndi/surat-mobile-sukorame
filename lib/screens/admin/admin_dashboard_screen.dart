import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Kelurahan Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            _buildMenuGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      {
        'title': 'Lihat Penduduk',
        'icon': Icons.people,
        'route': '/admin/penduduk',
        'color': Colors.green[600],
      },
      {
        'title': 'Surat Disetujui',
        'icon': Icons.mail,
        'route': '/admin/surat',
        'color': Colors.green[700],
      },
      {
        'title': 'RT/RW Aktif',
        'icon': Icons.person_2,
        'route': '/admin/rtrw',
        'color': Colors.green[800],
      },
      {
        'title': 'Riwayat RT/RW',
        'icon': Icons.history,
        'route': '/admin/riwayat',
        'color': Colors.green[900],
      },
      {
        'title': 'Rekrut RT/RW',
        'icon': Icons.person_add,
        'route': '/admin/rekrut',
        'color': Colors.green[500],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          elevation: 4,
          color: item['color'] as Color?,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, item['route'] as String),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'] as String,
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
        );
      },
    );
  }
}