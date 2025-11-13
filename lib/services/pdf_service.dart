import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:surat_mobile_sukorame/models/surat_model.dart';

class PdfService {
  Future<Uint8List> generateSuratPdf(Surat surat) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(surat.kategori, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Data Pemohon:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('Nama: ${surat.dataPemohon['nama']}'),
              pw.Text('NIK: ${surat.dataPemohon['nik']}'),
              pw.Text('Alamat: ${surat.dataPemohon['alamat']}'),
              pw.SizedBox(height: 20),
              pw.Text('Keperluan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text(surat.keperluan),
              pw.SizedBox(height: 40),
              pw.Text('Hormat kami,'),
              pw.SizedBox(height: 80),
              pw.Text('(_________________________)'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}
