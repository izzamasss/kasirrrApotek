import 'dart:convert';

class SummaryDashboard {
  final int saldoHarian;
  final int saldoHarianKemarin;
  final double presentasiSaldo;
  final int totalQty;
  final int totalTransaksi;
  final List<Coordinate> harian;
  final List<Coordinate> bulanan;

  const SummaryDashboard({
    required this.saldoHarian,
    required this.saldoHarianKemarin,
    required this.presentasiSaldo,
    required this.totalQty,
    required this.totalTransaksi,
    required this.harian,
    required this.bulanan,
  });

  static SummaryDashboard init = const SummaryDashboard(
      saldoHarian: 0, saldoHarianKemarin: 0, presentasiSaldo: 0, totalQty: 0, totalTransaksi: 0, harian: [], bulanan: []);

  factory SummaryDashboard.fromJson(String str) => SummaryDashboard.fromMap(json.decode(str));

  factory SummaryDashboard.fromMap(Map<String, dynamic> json) => SummaryDashboard(
        saldoHarian: json["saldo_harian"] ?? 0,
        saldoHarianKemarin: json["saldo_harian_kemarin"] ?? 0,
        presentasiSaldo: json["presentasi_saldo"].toDouble() ?? 0,
        totalQty: json["total_qty"] ?? 0,
        totalTransaksi: json["total_transaksi"] ?? 0,
        harian: json["harian"] == null ? [] : List<Coordinate>.from(json["harian"].map((x) => Coordinate.fromMap(x))),
        bulanan: json["bulanan"] == null ? [] : List<Coordinate>.from(json["bulanan"].map((x) => Coordinate.fromMap(x))),
      );
}

class Coordinate {
  final String label;
  final int value;

  const Coordinate({
    required this.label,
    required this.value,
  });

  factory Coordinate.fromJson(String str) => Coordinate.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Coordinate.fromMap(Map<String, dynamic> json) => Coordinate(
        label: json["label"],
        value: json["value"],
      );

  Map<String, dynamic> toMap() => {
        "label": label,
        "value": value,
      };
}
