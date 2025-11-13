import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/surat_service.dart';

class TervalidasiPage extends StatefulWidget {
  const TervalidasiPage({super.key});

  @override
  State<TervalidasiPage> createState() => _TervalidasiPageState();
}

class _TervalidasiPageState extends State<TervalidasiPage> {
  final SuratService _suratService = SuratService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tervalidasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _suratService.getSuratStream(status: 'selesai'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final suratList = allDocs.where((doc) {
                    if (_searchQuery.isEmpty) return true;

                    final data = doc.data() as Map<String, dynamic>;
                    final nama = data['dataPemohon']?['nama']
                            ?.toString()
                            .toLowerCase() ??
                        '';
                    final kategori =
                        data['kategori']?.toString().toLowerCase() ?? '';
                    final searchLower = _searchQuery.toLowerCase();

                    return nama.contains(searchLower) ||
                        kategori.contains(searchLower);
                  }).toList();

                  if (suratList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada surat tervalidasi'),
                    );
                  }

                  return ListView.builder(
                    itemCount: suratList.length,
                    itemBuilder: (context, index) {
                      final doc = suratList[index];
                      final surat = doc.data() as Map<String, dynamic>;
                      return _TervalidasiItem(
                        title: surat['dataPemohon']?['nama'] ?? '-',
                        date: surat['tanggalPengajuan']?.toDate()?.toString() ??
                            '-',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/lihat-surat',
                            arguments: doc.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TervalidasiItem extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onTap;

  const _TervalidasiItem({
    required this.title,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(date),
        trailing: ElevatedButton(onPressed: onTap, child: const Text('Lihat')),
      ),
    );
  }
}
