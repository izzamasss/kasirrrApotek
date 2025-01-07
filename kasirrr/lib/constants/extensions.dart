import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

extension ExtensionsResponse on Response {
  dynamic get data => json.decode(body)['data'];
}

extension ExtensionNum on num {
  // for edgeInsets
  EdgeInsets get edgeAll => EdgeInsets.all(toDouble());
  EdgeInsets get edgeBottom => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get edgeTop => EdgeInsets.only(top: toDouble());
  EdgeInsets get edgeRight => EdgeInsets.only(right: toDouble());
  EdgeInsets get edgeLeft => EdgeInsets.only(left: toDouble());
  EdgeInsets get edgeVer => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get edgeHor => EdgeInsets.symmetric(horizontal: toDouble());

  // for gap
  SizedBox get gapH => SizedBox(height: toDouble());
  SizedBox get gapW => SizedBox(width: toDouble());
}
