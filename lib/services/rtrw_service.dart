import 'package:cloud_firestore/cloud_firestore.dart';

class RTRWService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Assign RT role
  Future<void> assignRT({
    required String userId,
    required String nama,
    required String nomorRt,
    required String nomorRw,
    required DateTime periodeMulai,
    required DateTime periodeAkhir,
  }) async {
    try {
      // Check if RT position is already filled
      var existingRT = await _firestore
          .collection('rt')
          .where('nomor_rt', isEqualTo: nomorRt)
          .where('nomor_rw', isEqualTo: nomorRw)
          .get();

      if (existingRT.docs.isNotEmpty) {
        // Move current RT to history
        var currentRT = existingRT.docs.first;
        await addToHistory(
          nama: currentRT.get('nama'),
          nomorRt: nomorRt,
          nomorRw: nomorRw,
          periodeMulai: currentRT.get('periode_mulai'),
          periodeAkhir: DateTime.now(),
          uid: currentRT.get('uid'),
          digantikanOleh: nama,
          jabatan: 'RT',
        );
        
        // Delete current RT
        await currentRT.reference.delete();
      }

      // Create new RT
      await _firestore.collection('rt').add({
        'uid': userId,
        'nama': nama,
        'nomor_rt': nomorRt,
        'nomor_rw': nomorRw,
        'periode_mulai': periodeMulai.toString().split(' ')[0],
        'periode_akhir': periodeAkhir.toString().split(' ')[0],
        'created_at': DateTime.now().toString(),
      });

      // Update user role
      await _firestore.collection('users').doc(userId).update({
        'role': 'rt',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Assign RW role
  Future<void> assignRW({
    required String userId,
    required String nama,
    required String nomorRw,
    required DateTime periodeMulai,
    required DateTime periodeAkhir,
  }) async {
    try {
      // Check if RW position is already filled
      var existingRW = await _firestore
          .collection('rw')
          .where('nomor_rw', isEqualTo: nomorRw)
          .get();

      if (existingRW.docs.isNotEmpty) {
        // Move current RW to history
        var currentRW = existingRW.docs.first;
        await addToHistory(
          nama: currentRW.get('nama'),
          nomorRw: nomorRw,
          periodeMulai: currentRW.get('periode_mulai'),
          periodeAkhir: DateTime.now(),
          uid: currentRW.get('uid'),
          digantikanOleh: nama,
          jabatan: 'RW',
        );
        
        // Delete current RW
        await currentRW.reference.delete();
      }

      // Create new RW
      await _firestore.collection('rw').add({
        'uid': userId,
        'nama': nama,
        'nomor_rw': nomorRw,
        'periode_mulai': periodeMulai.toString().split(' ')[0],
        'periode_akhir': periodeAkhir.toString().split(' ')[0],
        'created_at': DateTime.now().toString(),
      });

      // Update user role
      await _firestore.collection('users').doc(userId).update({
        'role': 'rw',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add to history
  Future<void> addToHistory({
    required String nama,
    String? nomorRt,
    required String nomorRw,
    required String periodeMulai,
    required DateTime periodeAkhir,
    required String uid,
    required String digantikanOleh,
    required String jabatan,
  }) async {
    try {
      await _firestore.collection('riwayatRTRW').add({
        'nama': nama,
        if (nomorRt != null) 'nomor_rt': nomorRt,
        'nomor_rw': nomorRw,
        'periode_mulai': periodeMulai,
        'periode_akhir': periodeAkhir.toString().split(' ')[0],
        'masa_berakhir': periodeAkhir.toString().split(' ')[0],
        'uid': uid,
        'digantikan_oleh': digantikanOleh,
        'jabatan': jabatan,
        'created_at': DateTime.now().toString(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get RT list
  Future<List<Map<String, dynamic>>> getRTList() async {
    try {
      var snapshot = await _firestore.collection('rt').get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get RW list
  Future<List<Map<String, dynamic>>> getRWList() async {
    try {
      var snapshot = await _firestore.collection('rw').get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get RT/RW history
  Future<List<Map<String, dynamic>>> getRTRWHistory() async {
    try {
      var snapshot = await _firestore
          .collection('riwayatRTRW')
          .orderBy('created_at', descending: true)
          .limit(50) // Limit to last 50 records
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Remove RT role
  Future<void> removeRT(String rtId, String userId) async {
    try {
      await _firestore.collection('rt').doc(rtId).delete();
      await _firestore.collection('users').doc(userId).update({
        'role': 'warga',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove RW role
  Future<void> removeRW(String rwId, String userId) async {
    try {
      await _firestore.collection('rw').doc(rwId).delete();
      await _firestore.collection('users').doc(userId).update({
        'role': 'warga',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Check RT/RW term expiry
  Future<List<Map<String, dynamic>>> checkExpiredTerms() async {
    try {
      final now = DateTime.now();
      List<Map<String, dynamic>> expiredTerms = [];

      // Check RT terms
      var rtSnapshot = await _firestore.collection('rt').get();
      for (var doc in rtSnapshot.docs) {
        DateTime periodeAkhir = DateTime.parse(doc.get('periode_akhir'));
        if (periodeAkhir.isBefore(now)) {
          expiredTerms.add({
            'id': doc.id,
            'type': 'RT',
            'nama': doc.get('nama'),
            'nomor_rt': doc.get('nomor_rt'),
            'nomor_rw': doc.get('nomor_rw'),
            'periode_akhir': periodeAkhir,
          });
        }
      }

      // Check RW terms
      var rwSnapshot = await _firestore.collection('rw').get();
      for (var doc in rwSnapshot.docs) {
        DateTime periodeAkhir = DateTime.parse(doc.get('periode_akhir'));
        if (periodeAkhir.isBefore(now)) {
          expiredTerms.add({
            'id': doc.id,
            'type': 'RW',
            'nama': doc.get('nama'),
            'nomor_rw': doc.get('nomor_rw'),
            'periode_akhir': periodeAkhir,
          });
        }
      }

      return expiredTerms;
    } catch (e) {
      rethrow;
    }
  }
}