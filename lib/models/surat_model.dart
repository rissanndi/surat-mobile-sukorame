import 'package:cloud_firestore/cloud_firestore.dart';

class Surat {
  final String id;
  final String pembuatId;
  final String kategori;
  final Map<String, dynamic> dataPemohon;
  final String keperluan;
  final String urlTtdPemohon;
  final String urlKtp;
  final String urlKk;
  final String status;
  final Timestamp tanggalPengajuan;
  final String? catatanPenolakan;

  Surat({
    required this.id,
    required this.pembuatId,
    required this.kategori,
    required this.dataPemohon,
    required this.keperluan,
    required this.urlTtdPemohon,
    required this.urlKtp,
    required this.urlKk,
    required this.status,
    required this.tanggalPengajuan,
    this.catatanPenolakan,
  });

  factory Surat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Surat(
      id: doc.id,
      pembuatId: data['pembuatId'] ?? '',
      kategori: data['kategori'] ?? '',
      dataPemohon: data['dataPemohon'] ?? {},
      keperluan: data['keperluan'] ?? '',
      urlTtdPemohon: data['urlTtdPemohon'] ?? '',
      urlKtp: data['urlKtp'] ?? '',
      urlKk: data['urlKk'] ?? '',
      status: data['status'] ?? 'diajukan',
      tanggalPengajuan: data['tanggalPengajuan'] ?? Timestamp.now(),
      catatanPenolakan: data['catatanPenolakan'],
    );
  }
}