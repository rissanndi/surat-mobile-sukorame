import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/surat.dart';

class SuratService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'surat';

  // Tambah surat baru
  Future<String> tambahSurat(Surat surat) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collection)
          .add(surat.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan surat: $e');
    }
  }

  // Ambil surat yang masih dalam proses
  Stream<List<Surat>> getSuratStream() {
    return _firestore
        .collection(collection)
        .where('status', whereIn: ['pending', 'diproses'])
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Surat.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Ambil surat berdasarkan ID
  Future<Surat?> getSuratById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(id)
          .get();
      if (doc.exists) {
        return Surat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil surat: $e');
    }
  }

  // Update status surat
  Future<void> updateStatus(
    String id,
    String status, {
    String? keterangan,
  }) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      if (keterangan != null) {
        updateData['keterangan'] = keterangan;
      }
      await _firestore.collection(collection).doc(id).update(updateData);
    } catch (e) {
      throw Exception('Gagal mengupdate status surat: $e');
    }
  }

  // Cari surat berdasarkan nomor, pemohon, atau jenis
  Stream<List<Surat>> cariSurat(String keyword, {String status = 'active'}) {
    // Convert keyword to lowercase for case-insensitive search
    keyword = keyword.toLowerCase();

    Query query = _firestore.collection(collection);

    // Filter berdasarkan status
    if (status == 'active') {
      query = query.where('status', whereIn: ['pending', 'diproses']);
    } else if (status == 'history') {
      query = query.where('status', whereIn: ['selesai', 'ditolak']);
    }

    return query.orderBy('tanggal', descending: true).snapshots().map((
      snapshot,
    ) {
      // Filter hasil berdasarkan keyword di pemohon, nomor, atau jenis
      return snapshot.docs
          .map(
            (doc) => Surat.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .where((surat) {
            return surat.pemohon.toLowerCase().contains(keyword) ||
                surat.nomor.toLowerCase().contains(keyword) ||
                surat.jenis.toLowerCase().contains(keyword);
          })
          .toList();
    });
  }

  // Hapus surat
  Future<void> hapusSurat(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus surat: $e');
    }
  }

  // Ambil riwayat surat (yang sudah selesai atau ditolak)
  Stream<List<Surat>> getRiwayatSuratStream() {
    return _firestore
        .collection(collection)
        .where('status', whereIn: ['selesai', 'ditolak'])
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Surat.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Ambil statistik surat
  Future<Map<String, int>> getStatistik() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collection).get();

      int totalSurat = snapshot.size;
      int pending = 0;
      int diproses = 0;
      int selesai = 0;

      for (var doc in snapshot.docs) {
        String status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'diproses':
            diproses++;
            break;
          case 'selesai':
            selesai++;
            break;
        }
      }

      return {
        'total': totalSurat,
        'pending': pending,
        'diproses': diproses,
        'selesai': selesai,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik: $e');
    }
  }
}
