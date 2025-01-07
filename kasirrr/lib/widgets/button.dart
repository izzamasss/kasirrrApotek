import 'package:apotek/constants/app_color.dart';
import 'package:apotek/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.prefix,
    this.isLoading = false,
    this.color = AppColor.primary,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? prefix;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColor.white,
      ),
      child: isLoading
          ? Transform.scale(scale: 0.5, child: const LoadingWidget())
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefix != null) Icon(prefix),
                Text(label),
              ],
            ),
    );
  }
}
