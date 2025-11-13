import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  // Send WhatsApp message
  Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Format phone number (remove '+' and any spaces)
      final formattedNumber = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      
      // Create WhatsApp URL
      final whatsappUrl = Uri.parse(
        'https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}',
      );

      // Check if WhatsApp is installed
      if (await canLaunchUrl(whatsappUrl)) {
        return await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Generate message for letter status update
  String generateStatusUpdateMessage({
    required String namaPemohon,
    required String kategoriSurat,
    required String status,
    String? catatan,
  }) {
    String message = '''
Yth. $namaPemohon,

Pengajuan surat Anda:
Kategori: $kategoriSurat
Status: $status
''';

    if (catatan != null && catatan.isNotEmpty) {
      message += '\nCatatan: $catatan';
    }

    message += '\n\nSilakan cek aplikasi untuk informasi lebih lanjut.';

    return message;
  }

  // Generate message for new letter notification
  String generateNewLetterMessage({
    required String namaPemohon,
    required String kategoriSurat,
    required String nomorSurat,
  }) {
    return '''
Ada pengajuan surat baru:
Dari: $namaPemohon
Kategori: $kategoriSurat
Nomor: $nomorSurat

Silakan buka aplikasi untuk melihat detail dan memproses surat.
''';
  }

  // Generate message for letter approval
  String generateApprovalMessage({
    required String namaPemohon,
    required String kategoriSurat,
    required String nomorSurat,
    required String approver,
    String? catatan,
  }) {
    String message = '''
Yth. $namaPemohon,

Surat pengajuan Anda telah disetujui:
Kategori: $kategoriSurat
Nomor: $nomorSurat
Disetujui oleh: $approver
''';

    if (catatan != null && catatan.isNotEmpty) {
      message += '\nCatatan: $catatan';
    }

    message += '\n\nSilakan buka aplikasi untuk mengunduh surat yang telah disetujui.';

    return message;
  }

  // Generate message for letter rejection
  String generateRejectionMessage({
    required String namaPemohon,
    required String kategoriSurat,
    required String nomorSurat,
    required String rejectedBy,
    required String alasan,
  }) {
    return '''
Yth. $namaPemohon,

Mohon maaf, pengajuan surat Anda tidak dapat disetujui:
Kategori: $kategoriSurat
Nomor: $nomorSurat
Ditolak oleh: $rejectedBy
Alasan: $alasan

Silakan perbaiki pengajuan sesuai catatan di atas dan ajukan kembali.
Untuk informasi lebih lanjut, silakan hubungi petugas terkait.
''';
  }

  // Generate message for document requirement
  String generateDocumentRequestMessage({
    required String namaPemohon,
    required String kategoriSurat,
    required String nomorSurat,
    required List<String> dokumenDiperlukan,
  }) {
    String documents = dokumenDiperlukan.map((doc) => '- $doc').join('\n');

    return '''
Yth. $namaPemohon,

Untuk melengkapi pengajuan surat Anda:
Kategori: $kategoriSurat
Nomor: $nomorSurat

Mohon lampirkan dokumen berikut:
$documents

Silakan unggah dokumen tersebut melalui aplikasi.
''';
  }
}