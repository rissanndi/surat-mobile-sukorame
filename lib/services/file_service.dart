import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  final _uuid = const Uuid();

  // Upload image to Supabase storage
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
    String? existingUrl,
  }) async {
    try {
      // If there's an existing file, delete it first
      if (existingUrl != null) {
        await deleteFile(existingUrl);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(imageFile.path);
      final filename = '${timestamp}_${_uuid.v4()}$ext';

      // Upload file
      final response = await _supabase
          .storage
          .from('dokumen-warga')
          .upload('$folder/$filename', imageFile);

      // Get public URL
      final url = _supabase
          .storage
          .from('dokumen-warga')
          .getPublicUrl('$folder/$filename');

      return url;
    } catch (e) {
      rethrow;
    }
  }

  // Delete file from Supabase storage
  Future<void> deleteFile(String url) async {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(4).join('/'); // Skip first 4 segments (storage/v1/object/public)
      await _supabase.storage.from('dokumen-warga').remove([filePath]);
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Pick image from gallery
  Future<File?> pickImage({
    bool fromCamera = false,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      rethrow;
    }
  }

  // Pick document (PDF)
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get image dimensions
  Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(bytes);
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Check file size
  bool isFileSizeValid(File file, int maxSizeInMB) {
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeInMB;
  }
}