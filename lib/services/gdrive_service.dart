import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

// Kelas helper untuk menambahkan header autentikasi ke setiap request
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService {
  final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  // Fungsi ini sekarang akan mengembalikan http.Client yang sudah diautentikasi
  Future<http.Client?> _getAuthClient() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final headers = await googleUser.authHeaders;
    return GoogleAuthClient(headers); // Menggunakan kelas helper kita
  }

  Future<String?> uploadFile(File file) async {
    try {
      final client = await _getAuthClient();
      if (client == null) {
        print("Autentikasi Google dibatalkan.");
        return null;
      }

      final driveApi = drive.DriveApi(client);
      final driveFile = drive.File();
      // Membuat nama file unik berdasarkan waktu upload
      driveFile.name = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";

      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      print("File berhasil diupload. File ID: ${response.id}");
      return response.id;
    } catch (e) {
      print("Error saat upload ke Google Drive: $e");
      return null;
    }
  }
}