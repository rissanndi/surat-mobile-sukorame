import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:surat_mobile_sukorame/services/supabase_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final String userUid;
  const AddFamilyMemberScreen({super.key, required this.userUid});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  String? _selectedStatusKeluarga;
  bool _isLoading = false;

  Future<void> _saveFamilyMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('family_members').add({
        'nama': _namaController.text,
        'nik': _nikController.text,
        'tempatLahir': _tempatLahirController.text,
        'tanggalLahir': _selectedDate,
        'jenisKelamin': _selectedJenisKelamin,
        'agama': _selectedAgama,
        'statusPerkawinan': _selectedStatusKawin,
        'pekerjaan': _pekerjaanController.text,
        'statusDiKeluarga': _selectedStatusKeluarga,
        'kepalaKeluargaId': widget.userUid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggota keluarga berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan anggota keluarga: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anggota Keluarga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK'),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK tidak boleh kosong';
                  }
                  if (value.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempatLahirController,
                decoration: const InputDecoration(labelText: 'Tempat Lahir'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tempat lahir tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                title: Text(_selectedDate == null
                    ? 'Pilih Tanggal Lahir'
                    : 'Tgl. Lahir: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenisKelamin,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                items: ['Laki-laki', 'Perempuan']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJenisKelamin = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Jenis kelamin harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedAgama,
                decoration: const InputDecoration(labelText: 'Agama'),
                items: ['Islam', 'Kristen Protestan', 'Kristen Katolik', 'Hindu', 'Buddha', 'Khonghucu']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgama = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Agama harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatusKawin,
                decoration: const InputDecoration(labelText: 'Status Perkawinan'),
                items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatusKawin = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Status perkawinan harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pekerjaanController,
                decoration: const InputDecoration(labelText: 'Pekerjaan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pekerjaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatusKeluarga,
                decoration: const InputDecoration(labelText: 'Status di Keluarga'),
                items: ['Istri', 'Anak', 'Famili Lain']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatusKeluarga = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Status di keluarga harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveFamilyMember,
                      child: const Text('Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
