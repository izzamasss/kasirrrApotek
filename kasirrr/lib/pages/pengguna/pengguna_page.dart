import 'package:apotek/models/pengguna.dart';
import 'package:apotek/pages/pengguna/add_pengguna.dart';
import 'package:apotek/pages/pengguna/card_pengguna.dart';
import 'package:apotek/pages/pengguna/reset_password_pengguna.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/confirm_delete.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/empty_widget.dart';
import 'package:apotek/widgets/input.dart';
import 'package:apotek/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  final apiService = ApiService();
  bool isLoading = false;
  List<Pengguna> daftarPengguna = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPengguna();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengguna',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Input(
                  controller: _searchController,
                  hintText: 'Cari pengguna...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => _getPengguna(),
                ),
              ),
              const SizedBox(width: 10),
              Button(
                onPressed: _showAddUserDialog,
                prefix: Icons.add,
                label: 'Tambah',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) return const LoadingWidget();
                if (daftarPengguna.isEmpty) return EmptyWidget(onAction: _getPengguna);

                return ListView.builder(
                  itemCount: daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final pengguna = daftarPengguna[index];
                    return CardPengguna(
                      pengguna: pengguna,
                      onUpdateStatus: (val) => _onChangeStatus(pengguna.id ?? '', val),
                      onResetPassword: () => _showResetPasswordDialog(pengguna),
                      onEdit: () => _showAddUserDialog(pengguna: pengguna),
                      onDelete: () => showConfirmDelete(
                        context,
                        data: pengguna.nama ?? 'data',
                        onDelete: () => _deletePengguna(pengguna.id ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onChangeStatus(String id, bool val) async {
    final result = await apiService.updatePenggunaStatus(id, val);
    if (!mounted) return;

    if (result) {
      final index = daftarPengguna.indexWhere((e) => e.id == id);
      if (index >= 0) {
        final user = daftarPengguna[index];
        setState(() {
          daftarPengguna[index] = user.copyWith(isAktif: val);
        });
        showToast(context, e: 'Success to change pengguna');
      } else {
        showToastError(context, e: 'Failed to change pengguna');
      }
    }
  }

  void _onResetPassword(String id, String newPassword) async {
    final result = await apiService.updatePenggunaPassword(id, newPassword);
    if (!mounted) return;
    if (result) {
      showToast(context, e: 'Success to reset password pengguna');
    } else {
      showToastError(context, e: 'Failed to reset password pengguna');
    }
  }

  void _showAddUserDialog({Pengguna? pengguna}) async {
    final isEdit = pengguna != null;

    bool? res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isEdit ? 'Edit' : 'Tambah'} Pengguna'),
        content: AddPengguna(pengguna: pengguna),
      ),
    );

    if (res == true) _getPengguna();
  }

  void _showResetPasswordDialog(Pengguna pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: ResetPasswordPengguna(
          nama: pengguna.nama,
          onSubmit: (newPassword) => _onResetPassword(pengguna.id ?? '', newPassword),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text('Batal'),
        //   ),
        //   ElevatedButton(
        //     onPressed: () {
        //       if (passwordController.text == confirmPasswordController.text) {
        //         // Implementasi reset password
        //         Navigator.pop(context);
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Password berhasil direset')),
        //         );
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Password tidak cocok')),
        //         );
        //       }
        //     },
        //     child: const Text('Reset'),
        //   ),
        // ],
      ),
    );
  }

  // ------ START API
  Future<void> _getPengguna() async {
    setState(() {
      isLoading = true;
      daftarPengguna = [];
    });
    final result = await apiService.getPenggunaList(search: _searchController.text);
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => daftarPengguna = r),
    );
  }

  Future<void> _deletePengguna(String id) async {
    final result = await apiService.deletePengguna(id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (result) {
      showToast(context, e: 'Success to delete pengguna');
      _getPengguna();
    } else {
      showToastError(context, e: 'Failed to delete pengguna');
    }
  }

  // ------ END API
}
