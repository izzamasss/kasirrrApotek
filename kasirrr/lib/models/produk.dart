import 'package:apotek/models/kategori.dart';

class Produk {
  final String id;
  final String kode;
  final String barcode;
  final String nama;
  final String deskripsi;
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final String kategoriId;
  final Kategori? kategori;

  Produk({
    required this.id,
    required this.kode,
    required this.barcode,
    required this.nama,
    required this.deskripsi,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.kategoriId,
    this.kategori,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      kode: json['kode'],
      barcode: json['barcode'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      hargaBeli: double.parse(json['harga_beli']),
      hargaJual: double.parse(json['harga_jual']),
      stok: json['stok'],
      kategoriId: json['kategori_id'],
      kategori: Kategori.fromJson(json['kategori']),
    );
  }

  factory Produk.fromJsonFromLog(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      kode: json['kode'],
      barcode: json['barcode'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      hargaBeli: double.parse(json['harga_beli']),
      hargaJual: double.parse(json['harga_jual']),
      stok: json['stok'],
      kategoriId: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, => without id for update
      'kode': kode,
      'barcode': barcode,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'kategori_id': kategoriId,
    };
  }
}
