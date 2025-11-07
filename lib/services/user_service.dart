import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Add family member
  Future<void> addFamilyMember(String userId, Map<String, dynamic> memberData) async {
    try {
      // First check if member with same NIK already exists
      var existingMember = await _firestore
          .collection('users')
          .where('nik', isEqualTo: memberData['nik'])
          .get();

      if (existingMember.docs.isNotEmpty) {
        throw Exception('Anggota keluarga dengan NIK tersebut sudah terdaftar');
      }

      // Get user's current data for reference
      var userData = await getUserProfile(userId);
      if (userData == null) {
        throw Exception('Data pengguna tidak ditemukan');
      }

      // Create new user document for family member
      await _firestore.collection('users').add({
        ...memberData,
        'createdAt': DateTime.now().toString(),
        'kepalaKeluargaId': userId,
        'role': 'warga',
        'rt': userData['rt'],
        'rw': userData['rw'],
        'kelurahan': userData['kelurahan'],
        'kecamatan': userData['kecamatan'],
        'kota': userData['kota'],
        'provinsi': userData['provinsi'],
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get family members
  Future<List<Map<String, dynamic>>> getFamilyMembers(String userId) async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('kepalaKeluargaId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update family member
  Future<void> updateFamilyMember(String memberId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(memberId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete family member
  Future<void> deleteFamilyMember(String memberId) async {
    try {
      await _firestore.collection('users').doc(memberId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get RT/RW information
  Future<Map<String, dynamic>?> getRTRWInfo(String rt, String rw) async {
    try {
      var rtDoc = await _firestore
          .collection('rt')
          .where('nomor_rt', isEqualTo: rt)
          .where('nomor_rw', isEqualTo: rw)
          .get();

      var rwDoc = await _firestore
          .collection('rw')
          .where('nomor_rw', isEqualTo: rw)
          .get();

      Map<String, dynamic> result = {};
      
      if (rtDoc.docs.isNotEmpty) {
        result['rt'] = rtDoc.docs.first.data();
      }
      
      if (rwDoc.docs.isNotEmpty) {
        result['rw'] = rwDoc.docs.first.data();
      }

      return result.isEmpty ? null : result;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is RT/RW
  Future<bool> isUserRTRW(String userId) async {
    try {
      var rtDoc = await _firestore
          .collection('rt')
          .where('uid', isEqualTo: userId)
          .get();

      var rwDoc = await _firestore
          .collection('rw')
          .where('uid', isEqualTo: userId)
          .get();

      return rtDoc.docs.isNotEmpty || rwDoc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}