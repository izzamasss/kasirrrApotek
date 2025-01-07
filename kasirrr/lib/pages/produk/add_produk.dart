import 'package:apotek/models/kategori.dart';
import 'package:apotek/models/produk.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddProduk extends StatefulWidget {
  const AddProduk({super.key, required this.products, required this.categories, this.product});
  final List<Produk> products;
  final List<Kategori> categories;
  final Produk? product;

  @override
  State<AddProduk> createState() => _AddProdukState();
}

class _AddProdukState extends State<AddProduk> {
  final apiService = ApiService();
  String? selectedKategori;
  bool isLoading = false;

  Produk? get produk => widget.product;
  bool get isEdit => produk != null;

  final formKey = GlobalKey<FormState>();
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final hargaBeliController = TextEditingController();
  final hargaJualController = TextEditingController();
  final stokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final firstKategoriId = widget.categories.isNotEmpty ? widget.categories.first.id : null;
    setState(() => selectedKategori = produk?.kategoriId ?? firstKategoriId);

    if (isEdit) {
      setState(() {
        kodeController.text = produk?.kode ?? '';
        namaController.text = produk?.nama ?? '';
        deskripsiController.text = produk?.deskripsi ?? '';
        hargaBeliController.text = produk?.hargaBeli.toStringAsFixed(0) ?? '';
        hargaJualController.text = produk?.hargaJual.toStringAsFixed(0) ?? '';
        stokController.text = '${produk?.stok ?? ''}';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    kodeController.dispose();
    namaController.dispose();
    deskripsiController.dispose();
    hargaBeliController.dispose();
    hargaJualController.dispose();
    stokController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Input(
                    controller: kodeController,
                    labelText: 'Kode Produk',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _showScannerDialog(kodeController),
                  tooltip: 'Scan Barcode',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Input(
              controller: namaController,
              labelText: 'Nama Produk',
            ),
            const SizedBox(height: 16),
            Input(
              controller: deskripsiController,
              labelText: 'Deskripsi Produk',
            ),
            if (widget.categories.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori.id,
                    child: Text(kategori.nama),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedKategori = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            Input(
              controller: hargaBeliController,
              labelText: 'Harga Beli',
              prefixText: 'Rp ',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Input(
              controller: hargaJualController,
              labelText: 'Harga Jual',
              prefixText: 'Rp ',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Input(
              controller: stokController,
              labelText: 'Stok Awal',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Stok awal harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Stok harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            ActionDialog(isLoading: isLoading, onPressed: _saveProduct),
          ],
        ),
      ),
    );
  }

  void _showScannerDialog(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Stack(
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                  torchEnabled: false,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String code = barcode.rawValue ?? '';
                    if (code.isNotEmpty) {
                      // Cek apakah kode sudah ada
                      final existingProduct = widget.products.indexWhere((produk) => produk.kode == code);

                      if (existingProduct >= 0) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kode produk sudah digunakan!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        controller.text = code;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Barcode terdeteksi: $code')),
                        );
                      }
                      break;
                    }
                  }
                },
              ),
              // Overlay untuk area scan
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Tombol tutup di pojok kanan atas
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Teks panduan di bagian bawah
              const Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  'Arahkan kamera ke barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------ START API
  Future<void> _saveProduct() async {
    if (formKey.currentState!.validate()) {
      final prod = Produk(
        id: '',
        kode: kodeController.text,
        barcode: kodeController.text,
        nama: namaController.text,
        deskripsi: deskripsiController.text,
        hargaBeli: double.tryParse(hargaBeliController.text) ?? 0,
        hargaJual: double.tryParse(hargaJualController.text) ?? 0,
        stok: int.tryParse(stokController.text) ?? 0,
        kategoriId: selectedKategori ?? '',
      );
      setState(() => isLoading = true);
      final result = isEdit ? await apiService.updateProduk(produk?.id ?? '', prod) : await apiService.createProduk(prod);
      setState(() => isLoading = false);

      if (!mounted) return;

      result.fold(
        (l) {
          showToastError(context, e: l);
          Navigator.pop(context, false);
        },
        (r) {
          showToast(context, e: 'Produk berhasil  ${isEdit ? 'diubah' : 'ditambahkan'}');
          Navigator.pop(context, true);
        },
      );
    }
  }

  // ------ END API
}
