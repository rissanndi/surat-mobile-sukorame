import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadFile(File file, String docType) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$docType.jpg';
      final bucket = 'dokumen-warga'; // Nama bucket yang Anda buat

      await supabase.storage.from(bucket).upload(fileName, file);
      
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      print('Upload berhasil: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error saat upload ke Supabase: $e');
      return null;
    }
  }
}