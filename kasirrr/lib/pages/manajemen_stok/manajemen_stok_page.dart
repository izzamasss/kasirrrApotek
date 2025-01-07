import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/log_stok.dart';
import 'package:apotek/models/produk.dart';
import 'package:apotek/pages/manajemen_stok/add_manajemen_stok.dart';
import 'package:apotek/pages/manajemen_stok/card_manajemen_stok.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/empty_widget.dart';
import 'package:apotek/widgets/input.dart';
import 'package:apotek/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ManajemenStokPage extends StatefulWidget {
  const ManajemenStokPage({super.key});

  @override
  State createState() => _ManajemenStokPageState();
}

class _ManajemenStokPageState extends State<ManajemenStokPage> {
  final apiService = ApiService();
  bool isLoading = false;
  List<LogStok> logs = [];
  List<Produk> products = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLogStoks();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Stok',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Input(
            controller: _searchController,
            hintText: 'Cari produk...',
            prefixIcon: const Icon(Icons.search),
            onSubmit: _searchProduct,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) return const LoadingWidget();
                if (logs.isEmpty) return EmptyWidget(onAction: _getLogStoks);
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return CardManajemenStok(logStok: logs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStokOpnameDialog(Produk produk) async {
    final res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Stok Opname'),
        content: AddManajemenStok(produk: produk),
      ),
    );
    if (res == true) _getLogStoks();
  }

  void _searchProduct(String keyword) async {
    if (keyword.isNotEmpty) {
      await _getProducts();

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
                        subtitle: Text(Variable.formatRupiah.format(produk.hargaJual)),
                        leading: Text(produk.kode),
                        onTap: () {
                          Navigator.pop(context);
                          _showAddStokOpnameDialog(produk);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getLogStoks() async {
    setState(() {
      isLoading = true;
      logs = [];
    });
    final result = await apiService.getLogStokList();
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => logs = r),
    );
  }

  Future<void> _getProducts() async {
    setState(() => products = []);
    final result = await apiService.getProdukList(search: _searchController.text);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => products = r),
    );
  }
}
