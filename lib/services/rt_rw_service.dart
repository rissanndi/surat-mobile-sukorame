import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rt_rw_model.dart';

class RTRWService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch active RT
  Stream<List<RT>> getActiveRT() {
    return _firestore
        .collection('rt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RT.fromMap(doc.data())).toList());
  }

  // Fetch active RW
  Stream<List<RW>> getActiveRW() {
    return _firestore
        .collection('rw')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RW.fromMap(doc.data())).toList());
  }

  // Fetch RT/RW history
  Stream<List<RiwayatRTRW>> getRiwayatRTRW() {
    return _firestore
        .collection('riwayatRTRW')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RiwayatRTRW.fromMap(doc.data())).toList());
  }

  // Appoint new RT/RW
  Future<void> recruitOfficial({
    required String uid,
    required String nama,
    required bool isRt,
    required bool isRw,
    String? nomorRt,
    String? nomorRw,
    required String periodeMulai,
    required String periodeAkhir,
  }) async {
    final batch = _firestore.batch();

    // 1. Determine new role
    String newRole = 'warga';
    if (isRt && isRw) {
      newRole = 'rt_rw';
    } else if (isRt) {
      newRole = 'rt';
    } else if (isRw) {
      newRole = 'rw';
    }

    // 2. Update user's role
    final userRef = _firestore.collection('users').doc(uid);
    batch.update(userRef, {'role': newRole});

    final now = DateTime.now().toString();

    // 3. Create RT record and history
    if (isRt && nomorRt != null) {
      final rtRef = _firestore.collection('rt').doc(uid);
      final rtData = RT(
        uid: uid,
        nama: nama,
        nomorRt: nomorRt,
        periodeMulai: periodeMulai,
        periodeAkhir: periodeAkhir,
        createdAt: now,
      );
      batch.set(rtRef, rtData.toMap());

      final riwayatRtRef = _firestore.collection('riwayatRTRW').doc();
      final riwayatRt = RiwayatRTRW(
        uid: uid,
        nama: nama,
        tipe: 'rt',
        nomor: nomorRt,
        periodeMulai: periodeMulai,
        periodeAkhir: periodeAkhir,
        createdAt: now,
      );
      batch.set(riwayatRtRef, riwayatRt.toMap());
    }

    // 4. Create RW record and history
    if (isRw && nomorRw != null) {
      final rwRef = _firestore.collection('rw').doc(uid);
      final rwData = RW(
        uid: uid,
        nama: nama,
        nomorRw: nomorRw,
        periodeMulai: periodeMulai,
        periodeAkhir: periodeAkhir,
        createdAt: now,
      );
      batch.set(rwRef, rwData.toMap());

      final riwayatRwRef = _firestore.collection('riwayatRTRW').doc();
      final riwayatRw = RiwayatRTRW(
        uid: uid,
        nama: nama,
        tipe: 'rw',
        nomor: nomorRw,
        periodeMulai: periodeMulai,
        periodeAkhir: periodeAkhir,
        createdAt: now,
      );
      batch.set(riwayatRwRef, riwayatRw.toMap());
    }

    // Commit all operations
    await batch.commit();
  }

  // End RT/RW term
  Future<void> endTerm(String uid, String nama, String digantikanOleh) async {
    // Find in RT collection
    final rtDoc = await _firestore.collection('rt').doc(uid).get();
    if (rtDoc.exists) {
      // Remove from active RT
      await rtDoc.reference.delete();
      
      // Update history
      await _firestore.collection('riwayatRTRW').where('uid', isEqualTo: uid).get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({
            'masa_berakhir': DateTime.now().toString(),
            'digantikan_oleh': digantikanOleh,
          });
        }
      });
      return;
    }

    // Find in RW collection
    final rwDoc = await _firestore.collection('rw').doc(uid).get();
    if (rwDoc.exists) {
      // Remove from active RW
      await rwDoc.reference.delete();
      
      // Update history
      await _firestore.collection('riwayatRTRW').where('uid', isEqualTo: uid).get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({
            'masa_berakhir': DateTime.now().toString(),
            'digantikan_oleh': digantikanOleh,
          });
        }
      });
    }
  }
}