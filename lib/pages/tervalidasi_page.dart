import 'package:flutter/material.dart';
import '../models/surat.dart';
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
              child: StreamBuilder<List<Surat>>(
                stream: _suratService.getSuratStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allSurat = snapshot.data ?? [];
                  final suratList = allSurat
                      .where((s) => s.status == 'selesai')
                      .where(
                        (s) =>
                            _searchQuery.isEmpty ||
                            s.pemohon.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            s.nomor.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();

                  if (suratList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada surat tervalidasi'),
                    );
                  }

                  return ListView.builder(
                    itemCount: suratList.length,
                    itemBuilder: (context, index) {
                      final surat = suratList[index];
                      return _TervalidasiItem(
                        title: surat.pemohon,
                        date: surat.tanggal,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/lihat-surat',
                            arguments: surat.id,
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
