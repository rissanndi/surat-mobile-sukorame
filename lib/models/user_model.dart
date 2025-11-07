import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/encryption.dart';

class UserModel {
  final String id;
  final String nama;
  final String nik;
  final String alamat;
  final String noHp;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? pekerjaan;
  final String? statusPerkawinan;
  final String? statusDiKeluarga;
  final String rt;
  final String rw;
  final String? urlKtp;
  final String? urlKk;
  final String role;

  UserModel({
    required this.id,
    required this.nama,
    required this.nik,
    required this.alamat,
    required this.noHp,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.pekerjaan,
    this.statusPerkawinan,
    this.statusDiKeluarga,
    required this.rt,
    required this.rw,
    this.urlKtp,
    this.urlKk,
    required this.role,
  });

  // Create encrypted map for Firestore
  static Future<Map<String, dynamic>> encryptForFirestore(Map<String, dynamic> data) async {
    return {
      'nama': await encryptField(data['nama']),
      'nik': await encryptField(data['nik']),
      'alamat': await encryptField(data['alamat']),
      'noHp': await encryptField(data['noHp']),
      'tempatLahir': data['tempatLahir'] != null ? await encryptField(data['tempatLahir']) : null,
      'tanggalLahir': data['tanggalLahir'],
      'jenisKelamin': data['jenisKelamin'],
      'agama': data['agama'],
      'pekerjaan': await encryptField(data['pekerjaan']),
      'statusPerkawinan': data['statusPerkawinan'],
      'statusDiKeluarga': data['statusDiKeluarga'],
      'rt': data['rt'],
      'rw': data['rw'],
      'urlKtp': await encryptField(data['urlKtp']),
      'urlKk': await encryptField(data['urlKk']),
      'role': data['role'],
    };
  }

  // Create from Firestore document with decryption
  static Future<UserModel> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      nama: await decryptField(data['nama']),
      nik: await decryptField(data['nik']),
      alamat: await decryptField(data['alamat']),
      noHp: await decryptField(data['noHp']),
      tempatLahir: await decryptField(data['tempatLahir']),
      tanggalLahir: data['tanggalLahir'] != null 
          ? (data['tanggalLahir'] as Timestamp).toDate() 
          : null,
      jenisKelamin: data['jenisKelamin'],
      agama: data['agama'],
      pekerjaan: await decryptField(data['pekerjaan']),
      statusPerkawinan: data['statusPerkawinan'],
      statusDiKeluarga: data['statusDiKeluarga'],
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      urlKtp: await decryptField(data['urlKtp']),
      urlKk: await decryptField(data['urlKk']),
      role: data['role'] ?? 'warga',
    );
  }
}