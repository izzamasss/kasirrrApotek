import 'package:apotek/constants/extensions.dart';
import 'package:apotek/widgets/action_dialog.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:apotek/widgets/input.dart';
import 'package:flutter/material.dart';

class ResetPasswordPengguna extends StatefulWidget {
  const ResetPasswordPengguna({super.key, required this.nama, required this.onSubmit});
  final String? nama;
  final Function(String) onSubmit;

  @override
  State<ResetPasswordPengguna> createState() => _ResetPasswordPenggunaState();
}

class _ResetPasswordPenggunaState extends State<ResetPasswordPengguna> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Reset password untuk pengguna ${widget.nama ?? ''}'),
          16.gapH,
          Input(
            controller: passwordController,
            labelText: 'Password Baru',
            obscureText: true,
          ),
          16.gapH,
          Input(
            controller: confirmPasswordController,
            labelText: 'Konfirmasi Password',
            obscureText: true,
          ),
          16.gapH,
          ActionDialog(
            isLoading: false,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (passwordController.text == confirmPasswordController.text) {
                  // Implementasi reset password
                  Navigator.pop(context);
                  widget.onSubmit.call(passwordController.text);
                } else {
                  showToastError(context, e: 'Password tidak cocok');
                }
              }
            },
          )
        ],
      ),
    );
  }
}
