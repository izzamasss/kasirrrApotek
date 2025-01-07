import 'package:apotek/constants/extensions.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/log_stok.dart';
import 'package:apotek/models/produk.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/input.dart';
import 'package:flutter/material.dart';

class AddManajemenStok extends StatefulWidget {
  const AddManajemenStok({super.key, required this.produk});
  final Produk produk;

  @override
  State<AddManajemenStok> createState() => _AddManajemenStokState();
}

class _AddManajemenStokState extends State<AddManajemenStok> {
  bool isLoading = false;
  Produk get produk => widget.produk;

  final formKey = GlobalKey<FormState>();
  final kodeProdukController = TextEditingController();

  final namaProdukController = TextEditingController();
  final stokAwalController = TextEditingController();
  final stokAkhirController = TextEditingController();
  final catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    kodeProdukController.text = produk.kode;
    namaProdukController.text = produk.nama;
    stokAwalController.text = produk.stok.toString();
  }

  @override
  void dispose() {
    super.dispose();
    kodeProdukController.dispose();
    namaProdukController.dispose();
    stokAwalController.dispose();
    stokAkhirController.dispose();
    catatanController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Input(
              controller: kodeProdukController,
              labelText: 'Kode Produk',
              readOnly: true,
            ),
            const SizedBox(height: 10),
            Input(
              controller: namaProdukController,
              labelText: 'Nama Produk',
              readOnly: true,
            ),
            const SizedBox(height: 10),
            Input(
              controller: stokAwalController,
              labelText: 'Stok Awal',
              readOnly: true,
            ),
            const SizedBox(height: 10),
            Input(
              controller: stokAkhirController,
              labelText: 'Stok Akhir',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Input(
              controller: catatanController,
              labelText: 'Catatan',
              maxLines: 3,
            ),
            16.gapH,
            ActionDialog(isLoading: isLoading, onPressed: _save),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (formKey.currentState!.validate()) {
      final stokSebelum = produk.stok;
      final stokSesudah = int.tryParse(stokAkhirController.text) ?? stokSebelum;
      final data = LogStok(
        id: '',
        produkId: produk.id,
        jenisPerubahan: 'opname',
        jumlah: stokSesudah - stokSebelum,
        stokSebelum: stokSebelum,
        stokSesudah: stokSesudah,
        keterangan: catatanController.text,
        petugasId: Variable.pengguna?.id ?? '',
        createdAt: DateTime.now(),
        produk: produk,
      );
      final result = await ApiService().createLogStok(data);
      if (!mounted) return;
      result.fold(
        (l) {
          showToastError(context, e: l);
          Navigator.pop(context, false);
        },
        (r) {
          showToast(context, e: 'Stok opname berhasil ditambahkan');
          Navigator.pop(context, true);
        },
      );
    }
  }
}
