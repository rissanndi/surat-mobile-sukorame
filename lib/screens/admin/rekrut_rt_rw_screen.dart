import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/rt_rw_service.dart';

class RekrutRTRWScreen extends StatefulWidget {
  const RekrutRTRWScreen({super.key});

  @override
  State<RekrutRTRWScreen> createState() => _RekrutRTRWScreenState();
}

class _RekrutRTRWScreenState extends State<RekrutRTRWScreen> {
  final RTRWService _rtrwService = RTRWService();
  bool _isLoading = false;
  String? _selectedUserId;
  bool _isRt = false;
  bool _isRw = false;
  String _nomorRt = '';
  String _nomorRw = '';
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();
  DateTime _periodeMulai = DateTime.now();
  DateTime _periodeAkhir = DateTime.now().add(const Duration(days: 365 * 5)); // 5 years

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
          // Ensure periode akhir is after periode mulai
          if (_periodeAkhir.isBefore(_periodeMulai)) {
            _periodeAkhir = _periodeMulai.add(const Duration(days: 365 * 5));
          }
        } else {
          _periodeAkhir = picked;
        }
      });
    }
  }

  Future<void> _rekrutRTRW() async {
    if (!_formKey.currentState!.validate() || _selectedUserId == null || (!_isRt && !_isRw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user data
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_selectedUserId).get();
      if (!userDoc.exists) {
        throw 'User tidak ditemukan';
      }

      final userData = userDoc.data()!;
      await _rtrwService.recruitOfficial(
        uid: _selectedUserId!,
        nama: userData['nama'],
        isRt: _isRt,
        isRw: _isRw,
        nomorRt: _isRt ? _nomorRt : null,
        nomorRw: _isRw ? _nomorRw : null,
        periodeMulai: _periodeMulai.toIso8601String(),
        periodeAkhir: _periodeAkhir.toIso8601String(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menunjuk RT/RW')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekrut RT/RW'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Role Selection
            const Text('Pilih Jabatan', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('RT'),
              value: _isRt,
              onChanged: (value) {
                setState(() {
                  _isRt = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('RW'),
              value: _isRw,
              onChanged: (value) {
                setState(() {
                  _isRw = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            if (_isRt)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nomor RT',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _nomorRt = value,
                validator: (value) {
                  if (_isRt && (value == null || value.isEmpty)) {
                    return 'Masukkan nomor RT';
                  }
                  return null;
                },
              ),
            if (_isRt)
              const SizedBox(height: 16),

            if (_isRw)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nomor RW',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _nomorRw = value,
                validator: (value) {
                  if (_isRw && (value == null || value.isEmpty)) {
                    return 'Masukkan nomor RW';
                  }
                  return null;
                },
              ),
            if (_isRw)
              const SizedBox(height: 16),
            const SizedBox(height: 16),

            // User Selection
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cari Warga (berdasarkan nama)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection('users').snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('nama', isGreaterThanOrEqualTo: _searchQuery)
                      .where('nama', isLessThan: '${_searchQuery}z')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading users');
                }

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> userItems = [];
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  userItems.add(DropdownMenuItem(
                    value: doc.id,
                    child: Text('${data['nama']} (${data['nik']})'),
                  ));
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Warga',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedUserId,
                  items: userItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Pilih warga' : null,
                );
              },
            ),
            const SizedBox(height: 16),

            // Periode Selection
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Periode Mulai',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _periodeMulai.toString().split(' ')[0],
                    ),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Periode Berakhir',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _periodeAkhir.toString().split(' ')[0],
                    ),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _rekrutRTRW,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tunjuk sebagai RT/RW'),
            ),
          ],
        ),
      ),
    );
  }
}