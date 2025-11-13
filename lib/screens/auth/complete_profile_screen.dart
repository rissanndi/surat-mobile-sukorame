import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surat_mobile_sukorame/services/supabase_service.dart';
import 'package:surat_mobile_sukorame/screens/main_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  // State
  DateTime? _selectedDate;
  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  String? _selectedStatusKeluarga;
  String? _ktpFileName;
  String? _urlKtp;
  String? _kkFileName;
  String? _urlKk;
  bool _setujuDenganSyarat = false;

  // Opsi untuk Autocomplete Pekerjaan
  static const List<String> _pekerjaanOptions = <String>[
    'Pegawai Negeri Sipil', 'Pegawai Swasta', 'Wiraswasta', 'Pelajar/Mahasiswa', 'Mengurus Rumah Tangga', 'Tidak Bekerja', 'Pensiunan', 'TNI', 'POLRI'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }
  
  // Fungsi Simpan dan Muat Draf (Lengkap)
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_nama', _namaController.text);
    await prefs.setString('draft_nik', _nikController.text);
    await prefs.setString('draft_alamat', _alamatController.text);
    await prefs.setString('draft_noHp', _noHpController.text);
    await prefs.setString('draft_tempatLahir', _tempatLahirController.text);
    await prefs.setString('draft_pekerjaan', _pekerjaanController.text);
    await prefs.setString('draft_rt', _rtController.text);
    await prefs.setString('draft_rw', _rwController.text);
    await prefs.setString('draft_jenisKelamin', _selectedJenisKelamin ?? '');
    await prefs.setString('draft_agama', _selectedAgama ?? '');
    await prefs.setString('draft_statusKawin', _selectedStatusKawin ?? '');
    await prefs.setString('draft_statusKeluarga', _selectedStatusKeluarga ?? '');
    if (_selectedDate != null) {
      await prefs.setString('draft_tanggalLahir', _selectedDate!.toIso8601String());
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('draft_nama') ?? '';
      _nikController.text = prefs.getString('draft_nik') ?? '';
      _alamatController.text = prefs.getString('draft_alamat') ?? '';
      _noHpController.text = prefs.getString('draft_noHp') ?? '';
      _tempatLahirController.text = prefs.getString('draft_tempatLahir') ?? '';
      _pekerjaanController.text = prefs.getString('draft_pekerjaan') ?? '';
      _rtController.text = prefs.getString('draft_rt') ?? '';
      _rwController.text = prefs.getString('draft_rw') ?? '';
      _selectedJenisKelamin = prefs.getString('draft_jenisKelamin');
      if (_selectedJenisKelamin == '') _selectedJenisKelamin = null;
      _selectedAgama = prefs.getString('draft_agama');
      if (_selectedAgama == '') _selectedAgama = null;
      _selectedStatusKawin = prefs.getString('draft_statusKawin');
      if (_selectedStatusKawin == '') _selectedStatusKawin = null;
      _selectedStatusKeluarga = prefs.getString('draft_statusKeluarga');
      if (_selectedStatusKeluarga == '') _selectedStatusKeluarga = null;
      final dateString = prefs.getString('draft_tanggalLahir');
      if (dateString != null && dateString.isNotEmpty) {
        _selectedDate = DateTime.parse(dateString);
      }
    });
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Fungsi Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  // Fungsi Upload File dengan Pilihan Kamera/Galeri
  Future<void> _pickAndUploadFile(String docType) async {
    final ImagePicker picker = ImagePicker();
    ImageSource? source;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Pilih dari Galeri'), onTap: () { source = ImageSource.gallery; Navigator.of(context).pop(); }),
              ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Ambil Foto dari Kamera'), onTap: () { source = ImageSource.camera; Navigator.of(context).pop(); }),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    final XFile? image = await picker.pickImage(source: source!);
    if (image == null) return;

    File file = File(image.path);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mengunggah ${file.path.split('/').last}...")));
    final publicUrl = await _supabaseService.uploadFile(file, docType);

    if (publicUrl != null) {
      setState(() {
        if (docType == 'ktp') {
          _ktpFileName = file.path.split('/').last;
          _urlKtp = publicUrl;
        } else if (docType == 'kk') {
          _kkFileName = file.path.split('/').last;
          _urlKk = publicUrl;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$docType berhasil diunggah!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengunggah $docType."), backgroundColor: Colors.red));
    }
  }
  
  // Fungsi Simpan Profil ke Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_setujuDenganSyarat) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi semua data dan centang kotak persetujuan."), backgroundColor: Colors.red));
      return;
    }
    if (_urlKtp == null || _urlKk == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon unggah KTP dan KK."), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final fullAddress = _alamatController.text.trim();
      final addressParts = fullAddress.split(',');
      final namaJalan = addressParts.isNotEmpty ? addressParts[0].trim() : '';

      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
        'uid': widget.user.uid,
        'email': widget.user.email,
        'nama': _namaController.text.trim(),
        'nik': _nikController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'agama': _selectedAgama ?? 'Tidak ada',
        'alamat': _alamatController.text.trim(),
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'jenisKelamin': _selectedJenisKelamin ?? '',
        'kecamatan': 'Mojoroto',
        'kelurahan': 'Bandar Lor',
        'kewarganegaraan': 'NKRI',
        'kota': 'Kediri',
        'namaJalan': namaJalan,
        'pekerjaan': _pekerjaanController.text.trim(),
        'provinsi': 'Jawa Timur',
        'role': 'warga',
        'rt': _rtController.text.trim(),
        'rw': _rwController.text.trim(),
        'statusDiKeluarga': _selectedStatusKeluarga ?? '',
        'statusPerkawinan': _selectedStatusKawin ?? '',
        'tanggalLahir': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
        'tempatLahir': _tempatLahirController.text.trim(),
        'urlFotoKk': _urlKk ?? '',
        'urlFotoKtp': _urlKtp ?? '',
      });
      await _clearDraft();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan profil: $e"), backgroundColor: Colors.red));
    } finally {
       if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lengkapi Profil Diri"), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _saveDraft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Silakan isi data diri Anda sesuai dokumen resmi untuk melanjutkan.", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama Lengkap (sesuai KTP)"), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _nikController, decoration: const InputDecoration(labelText: "NIK"), keyboardType: TextInputType.number, maxLength: 16, validator: (v) => v!.length != 16 ? 'NIK harus 16 digit' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _tempatLahirController, decoration: const InputDecoration(labelText: "Tempat Lahir"), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade400)),
                title: Text(_selectedDate == null ? 'Pilih Tanggal Lahir' : 'Tgl. Lahir: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text("Jenis Kelamin", style: TextStyle(fontSize: 16, color: Colors.black54)),
              Row(
                children: [
                  Expanded(child: RadioListTile<String>(title: const Text('Laki-laki'), value: 'Laki-laki', groupValue: _selectedJenisKelamin, onChanged: (value) => setState(() => _selectedJenisKelamin = value))),
                  Expanded(child: RadioListTile<String>(title: const Text('Perempuan'), value: 'Perempuan', groupValue: _selectedJenisKelamin, onChanged: (value) => setState(() => _selectedJenisKelamin = value))),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(initialValue: _selectedAgama, decoration: const InputDecoration(labelText: 'Agama', border: OutlineInputBorder()), items: ['Islam', 'Kristen Protestan', 'Kristen Katolik', 'Hindu', 'Buddha', 'Khonghucu'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedAgama = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(initialValue: _selectedStatusKawin, decoration: const InputDecoration(labelText: 'Status Perkawinan', border: OutlineInputBorder()), items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedStatusKawin = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 16),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _pekerjaanController.text),
                optionsBuilder: (TextEditingValue val) => val.text == '' ? const Iterable<String>.empty() : _pekerjaanOptions.where((o) => o.toLowerCase().contains(val.text.toLowerCase())),
                onSelected: (String sel) { _pekerjaanController.text = sel; FocusScope.of(context).unfocus(); },
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  return TextFormField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'Pekerjaan'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _alamatController, decoration: const InputDecoration(labelText: "Alamat Lengkap"), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              Row(children: [ Expanded(child: TextFormField(controller: _rtController, decoration: const InputDecoration(labelText: 'RT'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)), const SizedBox(width: 16), Expanded(child: TextFormField(controller: _rwController, decoration: const InputDecoration(labelText: 'RW'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)) ]),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(initialValue: _selectedStatusKeluarga, decoration: const InputDecoration(labelText: 'Status di Keluarga', border: OutlineInputBorder()), items: ['Kepala Keluarga', 'Istri', 'Anak', 'Famili Lain'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedStatusKeluarga = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 16),
               TextFormField(controller: _noHpController, decoration: const InputDecoration(labelText: "Nomor HP (WhatsApp)"), keyboardType: TextInputType.phone, validator: (val) => val!.isEmpty ? 'Nomor HP tidak boleh kosong' : null),
              const SizedBox(height: 24),
              const Text("Dokumen Pendukung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildUploadButton(title: 'Upload Foto KTP', fileName: _ktpFileName, onPressed: () => _pickAndUploadFile('ktp')),
              const SizedBox(height: 12),
              _buildUploadButton(title: 'Upload Foto KK', fileName: _kkFileName, onPressed: () => _pickAndUploadFile('kk')),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text("Saya menyatakan bahwa data yang saya isikan adalah benar dan dapat dipertanggungjawabkan.", style: TextStyle(fontSize: 14)),
                value: _setujuDenganSyarat,
                onChanged: (val) => setState(() => _setujuDenganSyarat = val!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoading || !_setujuDenganSyarat ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text("Simpan dan Lanjutkan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton({required String title, String? fileName, required VoidCallback onPressed}) {
    bool isUploaded = fileName != null;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(isUploaded ? Icons.check_circle : Icons.upload_file),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(fileName ?? title, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUploaded ? Colors.green : null))),
            if (isUploaded) const Icon(Icons.done, color: Colors.green)
          ],
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isUploaded ? Colors.green : Colors.black54,
        side: BorderSide(color: isUploaded ? Colors.green : Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}