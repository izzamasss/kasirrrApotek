import 'package:apotek/constants/extensions.dart';
import 'package:apotek/models/pengguna.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/input.dart';
import 'package:flutter/material.dart';

class AddPengguna extends StatefulWidget {
  const AddPengguna({super.key, this.pengguna, this.hasAccount, this.isProfile = false});
  final Pengguna? pengguna;
  final VoidCallback? hasAccount;
  final bool isProfile;

  @override
  State<AddPengguna> createState() => _AddPenggunaState();
}

class _AddPenggunaState extends State<AddPengguna> {
  bool get isRegistPage => widget.hasAccount != null;

  final apiService = ApiService();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Pengguna? get pengguna => widget.pengguna;
  bool get isEdit => widget.pengguna != null;

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final teleponController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? selectedRole = 'kasir';

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      setState(() {
        usernameController.text = pengguna?.username ?? '';
        namaController.text = pengguna?.nama ?? '';
        emailController.text = pengguna?.email ?? '';
        teleponController.text = pengguna?.telepon ?? '';
        selectedRole = pengguna?.role ?? 'kasir';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    namaController.dispose();
    emailController.dispose();
    teleponController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              controller: usernameController,
              labelText: 'Username',
              prefixIcon: const Icon(Icons.account_circle),
            ),
            const SizedBox(height: 16),
            Input(
              controller: namaController,
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              items: ['admin', 'kasir'].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                selectedRole = value;
              },
            ),
            const SizedBox(height: 16),
            Input(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email harus diisi';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Input(
              controller: teleponController,
              labelText: 'Telepon',
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
              isRequired: false,
            ),
            if (!isEdit) ...[
              const SizedBox(height: 16),
              Input(
                controller: passwordController,
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password harus diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Input(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
            ],
            16.gapH,
            !isRegistPage
                ? ActionDialog(isLoading: isLoading, onPressed: () => _savePengguna())
                : Button(
                    onPressed: isLoading ? null : _savePengguna,
                    label: 'DAFTAR',
                  ),
            if (isRegistPage)
              TextButton(
                onPressed: widget.hasAccount,
                child: const Text('Sudah punya akun? Login'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePengguna() async {
    if (formKey.currentState!.validate()) {
      final data = Pengguna(
        id: '',
        username: usernameController.text,
        nama: namaController.text,
        role: selectedRole ?? 'kasir',
        email: emailController.text,
        telepon: teleponController.text,
        password: passwordController.text,
        createdAt: DateTime.now(),
      );
      final result =
          isEdit ? await apiService.updatePengguna(widget.pengguna?.id ?? '', data) : await apiService.createPengguna(data);
      if (!mounted) return;
      result.fold(
        (l) {
          showToastError(context, e: l);
          Navigator.pop(context, false);
        },
        (r) {
          showToast(context, e: 'Pengguna berhasil  ${isEdit ? 'diubah' : 'ditambahkan'}');
          Navigator.pop(context, true);
        },
      );
    }
  }
}
