import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    this.controller,
    this.labelText,
    this.prefixText,
    this.hintText,
    this.validator,
    this.isRequired = true,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmit,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines,
  });
  final TextEditingController? controller;
  final String? labelText, prefixText, hintText;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType? keyboardType;
  final Widget? prefixIcon, suffixIcon;
  final Function(String)? onChanged, onSubmit;
  final bool obscureText, readOnly;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmit,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      validator: validator ??
          (isRequired
              ? (value) {
                  return (value == null || value.isEmpty) ? 'Data harus diisi' : null;
                }
              : null),
    );
  }
}
