import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/services/rt_rw_service.dart';

class PendudukScreen extends StatefulWidget {
  const PendudukScreen({super.key});

  @override
  State<PendudukScreen> createState() => _PendudukScreenState();
}

class _PendudukScreenState extends State<PendudukScreen> {
  final RTRWService _rtrwService = RTRWService();

  // State for the recruitment form
  final _formKey = GlobalKey<FormState>();
  bool _isRt = false;
  bool _isRw = false;
  String _nomorRt = '';
  String _nomorRw = '';
  DateTime _periodeMulai = DateTime.now();
  DateTime _periodeAkhir = DateTime.now().add(const Duration(days: 365 * 5)); // 5 years
  bool _isLoading = false;

  void _resetForm() {
    setState(() {
      _isRt = false;
      _isRw = false;
      _nomorRt = '';
      _nomorRw = '';
      _periodeMulai = DateTime.now();
      _periodeAkhir = DateTime.now().add(const Duration(days: 365 * 5));
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _periodeMulai : _periodeAkhir,
      firstDate: isStart ? DateTime.now() : _periodeMulai,
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _periodeMulai = picked;
          if (_periodeAkhir.isBefore(_periodeMulai)) {
            _periodeAkhir = _periodeMulai.add(const Duration(days: 365 * 5));
          }
        } else {
          _periodeAkhir = picked;
        }
      });
    }
  }

  void _showRecruitmentDialog(BuildContext context, String uid, String nama) {
    _resetForm();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Rekrut: $nama'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pilih Jabatan', style: TextStyle(fontWeight: FontWeight.bold)),
                      CheckboxListTile(
                        title: const Text('RT'),
                        value: _isRt,
                        onChanged: (value) => setDialogState(() => _isRt = value!),
                      ),
                      if (_isRt)
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nomor RT'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _nomorRt = value,
                          validator: (value) => (_isRt && value!.isEmpty) ? 'Wajib diisi' : null,
                        ),
                      CheckboxListTile(
                        title: const Text('RW'),
                        value: _isRw,
                        onChanged: (value) => setDialogState(() => _isRw = value!),
                      ),
                      if (_isRw)
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nomor RW'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _nomorRw = value,
                          validator: (value) => (_isRw && value!.isEmpty) ? 'Wajib diisi' : null,
                        ),
                      const SizedBox(height: 16),
                      const Text('Periode Jabatan', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await _selectDate(context, true);
                                setDialogState(() {});
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Mulai'),
                                child: Text(_periodeMulai.toString().split(' ')[0]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await _selectDate(context, false);
                                setDialogState(() {});
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Berakhir'),
                                child: Text(_periodeAkhir.toString().split(' ')[0]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && (_isRt || _isRw)) {
                            setDialogState(() => _isLoading = true);
                            try {
                              await _rtrwService.recruitOfficial(
                                uid: uid,
                                nama: nama,
                                isRt: _isRt,
                                isRw: _isRw,
                                nomorRt: _isRt ? _nomorRt : null,
                                nomorRw: _isRw ? _nomorRw : null,
                                periodeMulai: _periodeMulai.toIso8601String(),
                                periodeAkhir: _periodeAkhir.toIso8601String(),
                              );
                              Navigator.of(dialogContext).pop(); // Close recruitment dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$nama berhasil direkrut!'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                              );
                            } finally {
                              setDialogState(() => _isLoading = false);
                            }
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih minimal satu jabatan dan isi semua field.'), backgroundColor: Colors.orange),
                              );
                          }
                        },
                        child: const Text('Simpan'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, String uid, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Penduduk'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: data.entries
                .where((e) => e.value != null && e.key != 'id')
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: '${e.key.toUpperCase()}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${e.value}'),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close detail dialog
              _showRecruitmentDialog(context, uid, data['nama'] ?? 'Tanpa Nama');
            },
            child: const Text('Rekrut Jadi Pengurus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Penduduk'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'warga').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Tidak ada data warga untuk direkrut'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(userData['nama'] ?? 'Nama tidak tersedia'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NIK: ${userData['nik'] ?? '-'}'),
                      Text('Alamat: ${userData['alamat'] ?? '-'}'),
                    ],
                  ),
                  onTap: () => _showDetailDialog(context, userDoc.id, userData),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
