import 'package:apotek/constants/app_color.dart';
import 'package:flutter/material.dart';

void showToastError(BuildContext context, {required Object e}) {
  showToast(context, e: e as String, isSuccess: false);
}

void showToast(BuildContext context, {required String e, bool isSuccess = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e),
      backgroundColor: isSuccess ? AppColor.primary : AppColor.red,
    ),
  );
}
