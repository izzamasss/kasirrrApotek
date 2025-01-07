import 'package:apotek/models/produk.dart';

class Transaksi {
  final String? id;
  final String noTransaksi;
  final DateTime tanggal;
  final List<TransaksiItem> items;
  final double total;
  final double bayar;
  final double kembalian;
  final String kasirId;
  final String status;

  Transaksi({
    this.id,
    required this.noTransaksi,
    required this.tanggal,
    required this.items,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.kasirId,
    required this.status,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'] ?? '',
      noTransaksi: json['no_transaksi'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      items: (json['items'] as List).map((item) => TransaksiItem.fromJson(item)).toList(),
      total: json['total'].toDouble(),
      bayar: json['bayar'].toDouble(),
      kembalian: json['kembalian'].toDouble(),
      kasirId: json['kasir_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'no_transaksi': noTransaksi,
      'tanggal': tanggal.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'bayar': bayar,
      'kembalian': kembalian,
      'kasir_id': kasirId,
      'status': status,
    };
  }
}

class TransaksiItem {
  final String produkId;
  final Produk? produk;
  final int jumlah;
  final double harga;
  final double diskon;
  final double subtotal;

  TransaksiItem({
    required this.produkId,
    this.produk,
    required this.jumlah,
    required this.harga,
    required this.diskon,
    required this.subtotal,
  });

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    return TransaksiItem(
      produkId: json['produk_id'],
      jumlah: json['jumlah'],
      harga: json['harga'].toDouble(),
      diskon: json['diskon'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produk_id': produkId,
      'jumlah': jumlah,
      'harga': harga,
      'diskon': diskon,
      'subtotal': subtotal,
    };
  }
}
