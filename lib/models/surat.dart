class Surat {
  final String id;
  final String nomor;
  final String jenis;
  final String pemohon;
  final String nik;
  final String tanggal;
  final String status;
  final String keterangan;

  Surat({
    required this.id,
    required this.nomor,
    required this.jenis,
    required this.pemohon,
    required this.nik,
    required this.tanggal,
    required this.status,
    required this.keterangan,
  });

  // Konversi dari Map (untuk membaca dari Firebase)
  factory Surat.fromMap(Map<String, dynamic> map, String documentId) {
    return Surat(
      id: documentId,
      nomor: map['nomor'] ?? '',
      jenis: map['jenis'] ?? '',
      pemohon: map['pemohon'] ?? '',
      nik: map['nik'] ?? '',
      tanggal: map['tanggal'] ?? '',
      status: map['status'] ?? 'pending',
      keterangan: map['keterangan'] ?? '',
    );
  }

  // Konversi ke Map (untuk menyimpan ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'nomor': nomor,
      'jenis': jenis,
      'pemohon': pemohon,
      'nik': nik,
      'tanggal': tanggal,
      'status': status,
      'keterangan': keterangan,
    };
  }
}
