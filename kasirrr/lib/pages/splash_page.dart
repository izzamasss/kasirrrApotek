import 'dart:async';

import 'package:apotek/constants/app_color.dart';
import 'package:apotek/utils/shared_pref_util.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/pages/login_page.dart';
import 'package:apotek/pages/main_screen.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SharedPrefUtil _sharedRefProvider = SharedPrefUtil();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      afterInit();
    });
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Future<void> afterInit() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    //CHECK IS ALREADY LOGIN
    final isLogin = await _sharedRefProvider.getAuthData();
    const currUrl = Variable.baseUrl;
    final orldUrl = await _sharedRefProvider.getString(SharedPrefUtil.urlKey);

    if (currUrl != orldUrl) {
      await _sharedRefProvider.removeAuthData().then((_) => goToLogin());
    } else if (isLogin == null) {
      goToLogin();
    } else {
      goToMain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.primary,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.local_pharmacy,
              size: 60,
              color: Color(0xFF009d3c),
            ),
          ),
        ),
      ),
    );
  }
}
