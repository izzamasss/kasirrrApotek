import 'dart:convert';

class LaporanKeuangan {
  final String id;
  final DateTime tanggal;
  final String jenis;
  final String kategori;
  final double jumlah;
  final String? keterangan;
  final String? buktiTransaksi;
  final String? createdBy;
  final DateTime createdAt;
  final String petugas;

  const LaporanKeuangan({
    required this.id,
    required this.tanggal,
    required this.jenis,
    required this.kategori,
    required this.jumlah,
    required this.keterangan,
    required this.buktiTransaksi,
    required this.createdBy,
    required this.createdAt,
    required this.petugas,
  });

  bool get isDebit => jenis == 'pemasukan';
  double get debit => isDebit ? jumlah : 0.0;
  double get kredit => !isDebit ? jumlah : 0.0;

  factory LaporanKeuangan.fromJson(String str) => LaporanKeuangan.fromMap(json.decode(str));

  factory LaporanKeuangan.fromMap(Map<String, dynamic> json) => LaporanKeuangan(
        id: json["id"],
        tanggal: DateTime.parse(json["tanggal"]),
        jenis: json["jenis"],
        kategori: json["kategori"],
        jumlah: double.parse(json["jumlah"]),
        keterangan: json["keterangan"],
        buktiTransaksi: json["bukti_transaksi"],
        createdBy: json["created_by"],
        createdAt: DateTime.parse(json["created_at"]),
        petugas: json["petugas"],
      );
}
