// lib/models/family_member_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surat_mobile_sukorame/utils/firestore_date.dart';

class FamilyMember {
  final String id;
  // NOTE: ownerId tidak disimpan langsung di dokumen anggotaKeluarga
  // karena dokumen itu sendiri sudah ada di bawah path `users/{ownerId}/anggotaKeluarga/{memberId}`.
  // Tapi untuk kemudahan, kita bisa anggap ID parent user sebagai ownerId jika dibutuhkan.
  // Untuk saat ini, kita akan dapatkan ownerId dari path dokumen jika diperlukan,
  // atau langsung dari currentUser.uid saat melakukan operasi.
  // final String ownerId; // Komentari atau hapus ini jika Anda tidak menyimpannya di dokumen
  final String namaLengkap;
  final String nik;
  final String jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String agama;
  final String statusPerkawinan;
  final String statusDiKeluarga;
  final String pekerjaan; // Tambahkan ini
  final String kewarganegaraan; // Tambahkan ini
  final String? urlFotoKtp; // Tambahkan ini, jadikan nullable
  final String? urlFotoKk;  // Tambahkan ini, jadikan nullable

  FamilyMember({
    required this.id,
    // this.ownerId, // Sesuaikan jika Anda tetap ingin properti ini
    required this.namaLengkap,
    required this.nik,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.agama,
    required this.statusPerkawinan,
    required this.statusDiKeluarga,
    required this.pekerjaan,
    required this.kewarganegaraan,
    this.urlFotoKtp,
    this.urlFotoKk,
  });

  factory FamilyMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FamilyMember(
      id: doc.id,
      // ownerId: doc.reference.parent.parent?.id, // Bisa didapatkan dari path parent
      namaLengkap: data['nama'] ?? 'Tidak Diketahui', // 'nama' di Firestore
      nik: data['nik'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? '-',
      tempatLahir: data['tempatLahir'] ?? '-',
      tanggalLahir: dateTimeFromFirestore(data['tanggalLahir']) ?? Timestamp.now().toDate(),
      agama: data['agama'] ?? '-',
      statusPerkawinan: data['statusPerkawinan'] ?? '-',
      statusDiKeluarga: data['statusDiKeluarga'] ?? '-',
      pekerjaan: data['pekerjaan'] ?? '-', // Ambil 'pekerjaan'
      kewarganegaraan: data['kewarganegaraan'] ?? 'WNI', // Ambil 'kewarganegaraan'
      urlFotoKtp: data['urlFotoKtp'], // Ambil 'urlFotoKtp'
      urlFotoKk: data['urlFotoKk'],   // Ambil 'urlFotoKk'
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // 'ownerId': ownerId, // Tidak perlu disimpan jika ini sub-koleksi
      'nama': namaLengkap, // Disimpan sebagai 'nama'
      'nik': nik,
      'jenisKelamin': jenisKelamin,
      'tempatLahir': tempatLahir,
      'tanggalLahir': Timestamp.fromDate(tanggalLahir),
      'agama': agama,
      'statusPerkawinan': statusPerkawinan,
      'statusDiKeluarga': statusDiKeluarga,
      'pekerjaan': pekerjaan,
      'kewarganegaraan': kewarganegaraan,
      'urlFotoKtp': urlFotoKtp,
      'urlFotoKk': urlFotoKk,
    };
  }
}