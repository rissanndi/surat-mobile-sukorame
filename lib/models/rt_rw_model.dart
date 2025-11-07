class RT {
  final String uid;
  final String nama;
  final String nomorRt;
  final String periodeMulai;
  final String periodeAkhir;
  final String createdAt;

  RT({
    required this.uid,
    required this.nama,
    required this.nomorRt,
    required this.periodeMulai,
    required this.periodeAkhir,
    required this.createdAt,
  });

  factory RT.fromMap(Map<String, dynamic> map) {
    return RT(
      uid: map['uid'] as String,
      nama: map['nama'] as String,
      nomorRt: map['nomor_rt'] as String,
      periodeMulai: map['periode_mulai'] as String,
      periodeAkhir: map['periode_akhir'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'nomor_rt': nomorRt,
      'periode_mulai': periodeMulai,
      'periode_akhir': periodeAkhir,
      'created_at': createdAt,
    };
  }
}

class RW {
  final String uid;
  final String nama;
  final String nomorRw;
  final String periodeMulai;
  final String periodeAkhir;
  final String createdAt;

  RW({
    required this.uid,
    required this.nama,
    required this.nomorRw,
    required this.periodeMulai,
    required this.periodeAkhir,
    required this.createdAt,
  });

  factory RW.fromMap(Map<String, dynamic> map) {
    return RW(
      uid: map['uid'] as String,
      nama: map['nama'] as String,
      nomorRw: map['nomor_rw'] as String,
      periodeMulai: map['periode_mulai'] as String,
      periodeAkhir: map['periode_akhir'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'nomor_rw': nomorRw,
      'periode_mulai': periodeMulai,
      'periode_akhir': periodeAkhir,
      'created_at': createdAt,
    };
  }
}

class RiwayatRTRW {
  final String uid;
  final String nama;
  final String tipe; // 'rt' atau 'rw'
  final String nomor;
  final String periodeMulai;
  final String periodeAkhir;
  final String createdAt;
  final String? masaBerakhir;
  final String? digantikanOleh;

  RiwayatRTRW({
    required this.uid,
    required this.nama,
    required this.tipe,
    required this.nomor,
    required this.periodeMulai,
    required this.periodeAkhir,
    required this.createdAt,
    this.masaBerakhir,
    this.digantikanOleh,
  });

  factory RiwayatRTRW.fromMap(Map<String, dynamic> map) {
    return RiwayatRTRW(
      uid: map['uid'] as String,
      nama: map['nama'] as String,
      tipe: map['tipe'] as String? ?? (map['nomor_rt'] != null ? 'rt' : 'rw'),
      nomor: map['nomor'] as String? ?? map['nomor_rt'] as String? ?? map['nomor_rw'] as String,
      periodeMulai: map['periode_mulai'] as String,
      periodeAkhir: map['periode_akhir'] as String,
      createdAt: map['created_at'] as String,
      masaBerakhir: map['masa_berakhir'] as String?,
      digantikanOleh: map['digantikan_oleh'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'tipe': tipe,
      'nomor': nomor,
      'periode_mulai': periodeMulai,
      'periode_akhir': periodeAkhir,
      'created_at': createdAt,
      'masa_berakhir': masaBerakhir,
      'digantikan_oleh': digantikanOleh,
    };
  }
}