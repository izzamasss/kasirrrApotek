import 'package:apotek/constants/app_color.dart';
import 'package:apotek/widgets/button.dart';
import 'package:flutter/material.dart';

void showConfirmDelete(BuildContext context, {String data = 'data', required VoidCallback onDelete}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Apakah Anda yakin ingin menghapus $data?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(label: 'Batal', onPressed: () => Navigator.pop(context), color: AppColor.grey),
              const SizedBox(width: 10),
              Button(label: 'Hapus', onPressed: onDelete, color: AppColor.red),
            ],
          ),
        ],
      ),
    ),
  );
}
