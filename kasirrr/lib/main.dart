import 'package:apotek/pages/splash_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      primarySwatch: Colors.green,
      useMaterial3: true,
    ),
    home: const SplashPage(),
  ));
}
