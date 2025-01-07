import 'package:apotek/models/produk.dart';
import 'dart:convert';

class LogStok {
  final String id;
  final String produkId;
  final String jenisPerubahan;
  final int jumlah;
  final int stokSebelum;
  final int stokSesudah;
  final String keterangan;
  final String petugasId;
  final DateTime createdAt;
  final Produk produk;

  LogStok({
    required this.id,
    required this.produkId,
    required this.jenisPerubahan,
    required this.jumlah,
    required this.stokSebelum,
    required this.stokSesudah,
    required this.keterangan,
    required this.petugasId,
    required this.createdAt,
    required this.produk,
  });

  factory LogStok.fromJson(String str) => LogStok.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());
  static const test = {
    "id": "9527f150-0d34-4efc-9e02-3de4d27d4943",
    "kode": "12345",
    "barcode": "12345",
    "nama": "jejraejnra",
    "deskripsi": "knwlksndas",
    "kategori_id": "1",
    "harga_beli": "500.00",
    "harga_jual": "1000.00",
    "stok": 34,
    "min_stok": 0,
    "is_aktif": 1
  };
  factory LogStok.fromMap(Map<String, dynamic> json) => LogStok(
        id: json["id"],
        produkId: json["produk_id"],
        jenisPerubahan: json["jenis_perubahan"],
        jumlah: json["jumlah"],
        stokSebelum: json["stok_sebelum"],
        stokSesudah: json["stok_sesudah"],
        keterangan: json["keterangan"],
        petugasId: json["petugas_id"],
        createdAt: DateTime.parse(json["created_at"]),
        produk: Produk.fromJsonFromLog(json["produk"]),
      );

  Map<String, dynamic> toMap() => {
        "produk_id": produkId,
        "jenis_perubahan": jenisPerubahan,
        "jumlah": jumlah,
        "stok_sebelum": stokSebelum,
        "stok_sesudah": stokSesudah,
        "keterangan": keterangan,
        "petugas_id": petugasId,
        "created_at": createdAt.toIso8601String(),
      };
}
