import 'package:apotek/constants/extensions.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/produk.dart';
import 'package:apotek/models/transaksi.dart';
import 'package:apotek/pages/kasir/success_payment_dialog.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final apiService = ApiService();
  bool isLoading = false;
  List<Produk> products = [];
  late DateTime tanggal;
  @override
  void initState() {
    super.initState();
    setState(() {
      status = 'pending';
    });
  }

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bayarController = TextEditingController();
  bool isScanning = false;
  List<CartItem> cartItems = [];
  double totalHarga = 0;
  String noTransaksi = '';

  double jumlahBayar = 0;
  double kembalian = 0;
  String status = 'pending';

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _generateNoTransaksi() {
    // Format: TRX-YYYYMMDD-XXX
    final now = DateTime.now();

    String date = DateFormat('yyyyMMdd').format(now);
    String time = DateFormat('hhmmss').format(now);
    // Dalam implementasi nyata, XXX sebaiknya dari database
    noTransaksi = 'TRX-$date-$time';
    tanggal = now;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kasir', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pencarian Produk - Dipindah ke atas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pencarian Produk',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Input(
                                  controller: _searchController,
                                  hintText: 'Cari produk...',
                                  prefixIcon: const Icon(Icons.search),
                                  onSubmit: _searchProduct,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Button(
                                onPressed: () => _showScannerDialog(),
                                prefix: Icons.qr_code_scanner,
                                label: 'Scan',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Keranjang Belanja - Sekarang di bawah pencarian
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keranjang Belanja',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          SizedBox(
                            height: 200,
                            child: cartItems.isEmpty
                                ? const Center(child: Text('Keranjang kosong'))
                                : ListView.builder(
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(cartItems[index].produk.nama),
                                        subtitle: Text(
                                            '${cartItems[index].jumlah}x @ ${formatRupiah.format(cartItems[index].produk.hargaJual)}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _removeFromCart(index),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 18)),
                              Text(
                                formatRupiah.format(totalHarga),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Input(
                            controller: _bayarController,
                            labelText: 'Jumlah Bayar',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Button(
                              label: 'Bayar',
                              onPressed: _prosesTransaksi,
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScannerDialog() {
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
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String code = barcode.rawValue ?? '';
                    if (code.isNotEmpty) {
                      Navigator.pop(context);
                      await _searchProduct(code);
                      break;
                    }
                  }
                },
              ),
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
              const Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  'Arahkan kamera ke barcode produk',
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

  void _addToCart(Produk produk, int jumlah) {
    setState(() {
      // check is exist
      final index = cartItems.indexWhere((e) => e.produk.id == produk.id);
      if (index >= 0) {
        final cart = cartItems[index];
        cartItems[index] = cart.copyWith(jumlah: cart.jumlah + jumlah);
      } else {
        cartItems.add(CartItem(produk: produk, jumlah: jumlah));
      }

      _hitungTotal();
    });

    _searchController.text = '';
  }

  void _removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
      _hitungTotal();
    });
  }

  void _hitungTotal() {
    totalHarga = cartItems.fold(0, (sum, item) => sum + (item.produk.hargaJual * item.jumlah));
  }

  void _prosesTransaksi() {
    jumlahBayar = double.tryParse(_bayarController.text.replaceAll('.', '')) ?? 0;
    kembalian = jumlahBayar - totalHarga;

    if (jumlahBayar < totalHarga) {
      showToastError(context, e: 'Jumlah bayar kurang!');
      return;
    }

    // execute hit endpoint
    _createTransaksi();
  }

  Future<void> _searchProduct(String keyword) async {
    if (keyword.isNotEmpty) {
      await _getProducts(keyword);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hasil Pencarian'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Produk tidak ditemukan'),
                    )
                  else
                    ...List.generate(products.length, (i) {
                      final produk = products[i];
                      return ListTile(
                        title: Text(produk.nama),
                        subtitle: Text(formatRupiah.format(produk.hargaJual)),
                        leading: Text(produk.kode),
                        onTap: () {
                          Navigator.pop(context);
                          _showJumlahDialog(produk);
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showJumlahDialog(Produk produk) {
    int jumlah = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(produk.nama),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Harga: ${formatRupiah.format(produk.hargaJual)}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (jumlah > 1) {
                        setState(() => jumlah--);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    jumlah.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => jumlah++),
                  ),
                ],
              ),
              16.gapH,
              ActionDialog(
                isLoading: false,
                onPressed: () {
                  Navigator.pop(context);
                  _addToCart(produk, jumlah);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------ START API
  Future<void> _getProducts(String search) async {
    setState(() => products = []);
    final result = await apiService.getProdukList(search: search);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => products = r),
    );
  }

  Future<void> _createTransaksi() async {
    setState(() => isLoading = true);
    _generateNoTransaksi(); // Generate nomor transaksi baru
    final transaksi = Transaksi(
      noTransaksi: noTransaksi,
      tanggal: tanggal,
      items: cartItems
          .map((cart) => TransaksiItem(
                produk: cart.produk,
                produkId: cart.produk.id,
                jumlah: cart.jumlah,
                harga: cart.produk.hargaJual,
                diskon: 0,
                subtotal: cart.produk.hargaJual * cart.jumlah,
              ))
          .toList(),
      total: totalHarga,
      bayar: jumlahBayar,
      kembalian: kembalian,
      kasirId: Variable.pengguna?.id ?? '',
      status: 'completed',
    );
    final result = await apiService.createTransaksi(transaksi);
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) {
        setState(() {
          cartItems.clear();
          _hitungTotal();
          _bayarController.clear();
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Center(child: Text('Struk Pembelian')),
            content: SuccessPaymentDialog(transaksi: transaksi),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       // Implementasi cetak struk
            //       Navigator.pop(context);
            //     },
            //     child: const Text('Cetak'),
            //   ),

            // ],
          ),
        );
      },
    );
  }

  // ------ END API
}

class CartItem {
  final Produk produk;
  final int jumlah;

  const CartItem({
    required this.produk,
    this.jumlah = 1,
  });

  // Copy with method untuk update instance
  CartItem copyWith({Produk? produk, int? jumlah}) {
    return CartItem(
      produk: produk ?? this.produk,
      jumlah: jumlah ?? this.jumlah,
    );
  }
}
