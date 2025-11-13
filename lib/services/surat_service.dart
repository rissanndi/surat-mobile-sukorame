import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuratService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new letter request
  Future<String> createSurat({
    required Map<String, dynamic> dataPemohon,
    required String kategori,
    required String keperluan,
    String? urlTtd,
  }) async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');

      // Create new letter document
      DocumentReference docRef = await _firestore.collection('surat').add({
        'dataPemohon': dataPemohon,
        'kategori': kategori,
        'keperluan': keperluan,
        'pembuatId': user.uid,
        'status': urlTtd != null ? 'menunggu_rt' : 'menunggu_upload_ttd',
        'tanggalPengajuan': DateTime.now(),
        'urlTtd': urlTtd,
        'riwayatStatus': [
          {
            'status': 'dibuat',
            'timestamp': DateTime.now(),
            'oleh': user.uid,
          }
        ]
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update letter status
  Future<void> updateStatus({
    required String suratId,
    required String status,
    required String olehUid,
    String? catatan,
  }) async {
    try {
      await _firestore.collection('surat').doc(suratId).update({
        'status': status,
        'riwayatStatus': FieldValue.arrayUnion([
          {
            'status': status,
            'timestamp': DateTime.now(),
            'oleh': olehUid,
            if (catatan != null) 'catatan': catatan,
          }
        ]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get letters for RT
  Stream<QuerySnapshot> getLettersForRT(String rt, String rw) {
    return _firestore
        .collection('surat')
        .where('dataPemohon.rt', isEqualTo: rt)
        .where('dataPemohon.rw', isEqualTo: rw)
        .where('status', isEqualTo: 'menunggu_rt')
        .snapshots();
  }

  // Get letters for RW
  Stream<QuerySnapshot> getLettersForRW(String rw) {
    return _firestore
        .collection('surat')
        .where('dataPemohon.rw', isEqualTo: rw)
        .where('status', isEqualTo: 'menunggu_rw')
        .snapshots();
  }

  // Get letters for Kelurahan
  Stream<QuerySnapshot> getLettersForKelurahan() {
    return _firestore
        .collection('surat')
        .where('status', isEqualTo: 'menunggu_kelurahan')
        .snapshots();
  }

  // Get user's letters
  Stream<QuerySnapshot> getUserLetters(String userId) {
    return _firestore
        .collection('surat')
        .where('pembuatId', isEqualTo: userId)
        .orderBy('tanggalPengajuan', descending: true)
        .snapshots();
  }

  // Get letter details
  Future<Map<String, dynamic>?> getLetterDetails(String suratId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('surat').doc(suratId).get();
      if (doc.exists) {
        return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get letter status history
  Future<List<Map<String, dynamic>>> getLetterHistory(String suratId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('surat').doc(suratId).get();
      if (doc.exists) {
        List<dynamic> history = doc.get('riwayatStatus');
        return List<Map<String, dynamic>>.from(history);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Upload signed letter
  Future<void> uploadSignedLetter(String suratId, String urlTtd) async {
    try {
      await _firestore.collection('surat').doc(suratId).update({
        'urlTtd': urlTtd,
        'status': 'menunggu_rt',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get letter statistics
  Future<Map<String, int>> getLetterStatistics(String rt, String rw) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('surat')
          .where('dataPemohon.rt', isEqualTo: rt)
          .where('dataPemohon.rw', isEqualTo: rw)
          .get();

      Map<String, int> stats = {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        stats['total'] = (stats['total'] ?? 0) + 1;
        String status = doc.get('status');
        if (status.contains('menunggu')) {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        } else if (status == 'selesai') {
          stats['approved'] = (stats['approved'] ?? 0) + 1;
        } else if (status == 'ditolak') {
          stats['rejected'] = (stats['rejected'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      rethrow;
    }
  }

  // Get statistics for admin dashboard
  Future<Map<String, int>> getStatistik() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('surat').get();

      Map<String, int> stats = {
        'total': snapshot.docs.length,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        String status = doc.get('status');
        if (status.contains('menunggu')) {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        } else if (status == 'selesai') {
          stats['approved'] = (stats['approved'] ?? 0) + 1;
        } else if (status == 'ditolak') {
          stats['rejected'] = (stats['rejected'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      rethrow;
    }
  }

  // Get surat by ID
  Future<Map<String, dynamic>?> getSuratById(String suratId) async {
    return await getLetterDetails(suratId);
  }

  // Get surat stream for real-time updates
  Stream<QuerySnapshot> getSuratStream({String? status}) {
    Query query = _firestore.collection('surat');
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('tanggalPengajuan', descending: true).snapshots();
  }

  // Get riwayat surat stream
  Stream<QuerySnapshot> getRiwayatSuratStream(String userId) {
    return _firestore
        .collection('surat')
        .where('pembuatId', isEqualTo: userId)
        .orderBy('tanggalPengajuan', descending: true)
        .snapshots();
  }

  // Search surat
  Future<List<Map<String, dynamic>>> cariSurat(String keyword) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('surat').get();

      return snapshot.docs
          .where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String kategori = data['kategori']?.toString().toLowerCase() ?? '';
            String keperluan =
                data['keperluan']?.toString().toLowerCase() ?? '';
            String status = data['status']?.toString().toLowerCase() ?? '';
            String searchTerm = keyword.toLowerCase();

            return kategori.contains(searchTerm) ||
                keperluan.contains(searchTerm) ||
                status.contains(searchTerm);
          })
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
