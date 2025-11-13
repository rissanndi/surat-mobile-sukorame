// lib/models/surat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surat_mobile_sukorame/utils/firestore_date.dart';

class Surat {
  final String id;
  final String userId; // Menggunakan userId agar konsisten dengan firebase_auth
  final String kategori;
  final Map<String, dynamic> dataPemohon;
  final String keperluan;
  final String? urlSuratBerttd; // URL foto/scan surat yang sudah ditandatangani warga
  final String? urlKtp;         // URL foto KTP
  final String? urlKk;          // URL foto KK
  final String? urlSuratFinal;  // URL surat final (misal PDF) dari kelurahan
  final String status;
  final DateTime tanggalPengajuan;
  final String? catatanPenolakan; // Catatan jika ditolak (bisa dari RT/RW)
  final String? catatanRt;        // Catatan spesifik dari RT
  final String? catatanRw;        // Catatan spesifik dari RW


  Surat({
    required this.id,
    required this.userId, // Ubah dari pembuatId ke userId
    required this.kategori,
    required this.dataPemohon,
    required this.keperluan,
    this.urlSuratBerttd, // Jadikan nullable
    this.urlKtp,         // Jadikan nullable
    this.urlKk,          // Jadikan nullable
    this.urlSuratFinal,  // Jadikan nullable
    required this.status,
    required this.tanggalPengajuan,
    this.catatanPenolakan,
    this.catatanRt,      // Tambah ini
    this.catatanRw,      // Tambah ini
  });

  factory Surat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Surat(
      id: doc.id,
      userId: data['userId'] ?? data['pembuatId'] ?? '', // Kompatibilitas mundur
      kategori: data['kategori'] ?? 'Tidak Diketahui',
      keperluan: data['keperluan'] ?? 'Tidak ada keperluan',
      dataPemohon: data['dataPemohon'] ?? {},
      urlSuratBerttd: data['urlSuratBerttd'], // Ambil dari Firestore
      urlKtp: data['urlKtp'],                 // Ambil dari Firestore
      urlKk: data['urlKk'],                   // Ambil dari Firestore
      urlSuratFinal: data['urlSuratFinal'],   // Ambil dari Firestore
      status: data['status'] ?? 'diajukan',
      tanggalPengajuan: dateTimeFromFirestore(data['tanggalPengajuan']) ?? Timestamp.now().toDate(),
      catatanPenolakan: data['catatanPenolakan'],
      catatanRt: data['catatanRt'],           // Ambil dari Firestore
      catatanRw: data['catatanRw'],           // Ambil dari Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'kategori': kategori,
      'keperluan': keperluan,
      'dataPemohon': dataPemohon,
      'urlSuratBerttd': urlSuratBerttd,
      'urlKtp': urlKtp,
      'urlKk': urlKk,
      'urlSuratFinal': urlSuratFinal,
      'status': status,
      'tanggalPengajuan': Timestamp.fromDate(tanggalPengajuan),
      'catatanPenolakan': catatanPenolakan,
      'catatanRt': catatanRt,
      'catatanRw': catatanRw,
    };
  }
}