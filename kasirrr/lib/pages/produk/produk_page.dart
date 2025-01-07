import 'package:apotek/models/kategori.dart';
import 'package:apotek/models/produk.dart';
import 'package:apotek/pages/produk/add_produk.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final apiService = ApiService();
  bool isLoading = false;
  List<Kategori> categories = [];
  List<Produk> products = [];
  @override
  void initState() {
    super.initState();
    _getCategories();
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Tombol Tambah Produk
          Button(label: 'Tambah', onPressed: _showAddProductDialog, prefix: Icons.add),

          const SizedBox(height: 10),
          // Tabel Produk
          Expanded(
            child: Card(
              child: isLoading
                  ? const LoadingWidget()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Kode')),
                          DataColumn(label: Text('Nama Produk')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Stok')),
                          DataColumn(label: Text('Harga Beli')),
                          DataColumn(label: Text('Harga Jual')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: List.generate(products.length, (i) {
                          final produk = products[i];
                          return DataRow(
                            cells: [
                              DataCell(Text(produk.kode)),
                              DataCell(Text(produk.nama)),
                              DataCell(Text(produk.kategori?.nama ?? '-')),
                              DataCell(Text(produk.stok.toString())),
                              DataCell(Text('Rp ${NumberFormat('#,###').format(produk.hargaBeli)}')),
                              DataCell(Text('Rp ${NumberFormat('#,###').format(produk.hargaJual)}')),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF009d3c)),
                                    onPressed: () => _showAddProductDialog(produk: produk),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteProducts(produk.id),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ------ START API
  Future<void> _getProducts() async {
    setState(() {
      isLoading = true;
      products = [];
    });
    final result = await apiService.getProdukList();
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => products = r),
    );
  }

  Future<void> _deleteProducts(String id) async {
    final result = await apiService.deleteProduk(id);
    if (!mounted) return;
    if (result) {
      showToast(context, e: 'Success to delete product');
      _getProducts();
    } else {
      showToastError(context, e: 'Failed to delete product');
    }
  }

  Future<void> _getCategories() async {
    setState(() => categories = []);
    final result = await apiService.getKategoriList();

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => categories = r),
    );
  }
  // ------ END API

  void _showAddProductDialog({Produk? produk}) async {
    bool? val = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${produk == null ? 'Tambah' : 'Edit'} Produk'),
        content: AddProduk(products: products, categories: categories, product: produk),
      ),
    );
    if (val == true) _getProducts();
  }
}
