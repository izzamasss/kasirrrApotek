import 'package:apotek/constants/extensions.dart';
import 'package:apotek/models/kategori.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/confirm_delete.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/empty_widget.dart';
import 'package:apotek/widgets/input.dart';
import 'package:apotek/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final apiService = ApiService();
  bool isLoading = false;
  List<Kategori> categories = [];

  final formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Search and Add Button
          Row(
            children: [
              Expanded(
                child: Input(
                  controller: _searchController,
                  hintText: 'Cari kategori...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => _getCategories(),
                ),
              ),
              const SizedBox(width: 10),
              Button(
                onPressed: () => _showAddKategoriDialog(),
                prefix: Icons.add,
                label: 'Tambah',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Kategori List
          Expanded(
            child: Builder(builder: (context) {
              if (isLoading) return const LoadingWidget();
              if (categories.isEmpty) return EmptyWidget(onAction: _getCategories);

              return Card(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final kategori = categories[index];
                    return ListTile(
                      title: Text(kategori.nama),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF009d3c)),
                            onPressed: () => _showAddKategoriDialog(kategori: kategori),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteKategoriDialog(kategori),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddKategoriDialog({Kategori? kategori}) {
    if (kategori != null) {
      _kategoriController.text = kategori.nama;
      _deskripsiController.text = kategori.deskripsi ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${kategori == null ? 'Tambah' : 'Edit'} Kategori'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Input(
                controller: _kategoriController,
                labelText: 'Nama Kategori',
              ),
              16.gapH,
              Input(
                controller: _deskripsiController,
                labelText: 'Deskripsi Kategori',
              ),
              20.gapH,
              ActionDialog(isLoading: isLoading, onPressed: () => _saveCategory(kategori: kategori)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteKategoriDialog(Kategori kategori) {
    showConfirmDelete(
      context,
      data: 'kategori "${kategori.nama}"',
      onDelete: () => _deleteCategory(kategori.id),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  // ------ START API
  Future<void> _getCategories() async {
    setState(() {
      isLoading = true;
      categories = [];
    });
    final result = await apiService.getKategoriList(search: _searchController.text);
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => categories = r),
    );
  }

  Future<void> _saveCategory({Kategori? kategori}) async {
    final isEdit = kategori != null;
    if (formKey.currentState!.validate()) {
      final data = Kategori(
        id: '',
        nama: _kategoriController.text,
        deskripsi: _deskripsiController.text,
      );
      final result = isEdit ? await apiService.updateKategori(kategori.id, data) : await apiService.createKategori(data);
      if (!mounted) return;
      Navigator.pop(context);
      _getCategories();
      result.fold(
        (l) => showToastError(context, e: l),
        (r) => showToast(context, e: 'Kategori berhasil  ${isEdit ? 'diubah' : 'ditambahkan'}'),
      );
    }
  }

  Future<void> _deleteCategory(String id) async {
    final result = await apiService.deleteKategori(id);
    if (!mounted) return;
    Navigator.pop(context);
    if (result) {
      showToast(context, e: 'Success to delete category');
      _getCategories();
    } else {
      showToastError(context, e: 'Failed to delete category');
    }
  }
  // ------ END API
}
