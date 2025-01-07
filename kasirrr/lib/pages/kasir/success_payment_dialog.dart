import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/transaksi.dart';
import 'package:apotek/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuccessPaymentDialog extends StatelessWidget {
  const SuccessPaymentDialog({super.key, required this.transaksi});
  final Transaksi transaksi;

  @override
  Widget build(BuildContext context) {
    final formatRupiah = Variable.formatRupiah;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: Column(
              children: [
                Text('APOTEK ALIDA FARMA', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Jl. Raya Senin, Wonosari'),
                Text('Tlp : 0813 2648 3202'),
              ],
            ),
          ),
          const Divider(),
          Text('No. Transaksi: ${transaksi.noTransaksi}'),
          Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(transaksi.tanggal)}'),
          const SizedBox(height: 10),
          ...transaksi.items
              .map((item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.produk?.nama ?? ''),
                            Text('${item.jumlah}x @ ${formatRupiah.format(item.harga)}'),
                          ],
                        ),
                      ),
                      Text(formatRupiah.format(item.subtotal)),
                    ],
                  ))
              .toList(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah.format(transaksi.total), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bayar:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah.format(transaksi.bayar), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah.format(transaksi.kembalian), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Catatan:', style: TextStyle(fontStyle: FontStyle.italic)),
          const Text('Obat yang sudah dibeli tidak dapat ditukar kecuali ada perjanjian', style: TextStyle(fontSize: 12)),
          Button(label: 'Selesai', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
