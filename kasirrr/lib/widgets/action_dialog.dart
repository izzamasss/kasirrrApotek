import 'package:apotek/constants/app_color.dart';
import 'package:apotek/widgets/button.dart';
import 'package:flutter/material.dart';

class ActionDialog extends StatelessWidget {
  const ActionDialog({super.key, required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Button(
          color: AppColor.transparent,
          onPressed: () => Navigator.pop(context),
          label: 'Batal',
        ),
        const SizedBox(width: 10),
        Button(
          isLoading: isLoading,
          onPressed: onPressed,
          label: 'Simpan',
        ),
      ],
    );
  }
}
