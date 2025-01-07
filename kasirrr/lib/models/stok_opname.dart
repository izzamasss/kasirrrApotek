import 'package:apotek/models/produk.dart';

class StokOpname {
  final int id;
  final String produkId;
  final String jenisPerubahan;
  final int jumlah;
  final int stokSebelum;
  final int stokSesudah;
  final String keterangan;
  final String petugasId;
  final DateTime createdAt;
  final Produk? produk;

  StokOpname({
    required this.id,
    required this.produkId,
    required this.jenisPerubahan,
    required this.jumlah,
    required this.stokSebelum,
    required this.stokSesudah,
    required this.keterangan,
    required this.petugasId,
    required this.createdAt,
    this.produk,
  });
}
