import 'package:apotek/constants/extensions.dart';
import 'package:apotek/widgets/button.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.onAction});
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum Ada Data',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          if (onAction != null) ...[
            10.gapH,
            Button(
              onPressed: () => onAction!.call(),
              label: 'Load',
            ),
          ],
        ],
      ),
    );
  }
}
