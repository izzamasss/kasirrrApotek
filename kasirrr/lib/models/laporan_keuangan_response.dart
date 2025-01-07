import 'dart:convert';

import 'package:apotek/models/laporan_keuangan.dart';

class LaporanKeuanganResponse {
  final int totalPemasukan;
  final int totalPengeluaran;
  final List<LaporanKeuangan> laporanKeuangan;

  const LaporanKeuanganResponse({
    this.totalPemasukan = 0,
    this.totalPengeluaran = 0,
    this.laporanKeuangan = const [],
  });

  factory LaporanKeuanganResponse.fromJson(String str) => LaporanKeuanganResponse.fromMap(json.decode(str));

  factory LaporanKeuanganResponse.fromMap(Map<String, dynamic> json) => LaporanKeuanganResponse(
        totalPemasukan: json["total_pemasukan"],
        totalPengeluaran: json["total_pengeluaran"],
        laporanKeuangan: List<LaporanKeuangan>.from(json["laporan_keuangan"].map((x) => LaporanKeuangan.fromMap(x))),
      );
}
