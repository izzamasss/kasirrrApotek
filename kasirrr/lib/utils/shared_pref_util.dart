// ignore_for_file: type_literal_in_constant_pattern

import 'dart:convert';

import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/pengguna.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static const keyPrefix = 'apotek_';
  static const userKey = 'user';
  static const urlKey = 'url';

  Future<void> saveAuthData(Pengguna pengguna) async {
    await saveLocally(urlKey, Variable.baseUrl);
    await saveLocally(userKey, json.encode(pengguna.toJsonForLocal()));
    Variable.pengguna = pengguna;
  }

  Future<void> removeAuthData() async {
    await removeLocally(userKey);
    await removeLocally(urlKey);
  }

  Future<Pengguna?> getAuthData() async {
    final authData = await getString(userKey);

    if (authData == null) return null;
    final pengguna = Pengguna.fromJson(json.decode(authData));
    Variable.pengguna = pengguna;
    return pengguna;
  }

  Future<bool> isAuthDataExists() async => await isExist(userKey);

  // ----------------------------------------
  Future<void> saveLocally(String key, dynamic value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    switch (value.runtimeType) {
      case String:
        await pref.setString('$keyPrefix$key', value);
        break;
      case int:
        await pref.setInt('$keyPrefix$key', value);
        break;
      case double:
        await pref.setDouble('$keyPrefix$key', value);
        break;
      case bool:
        await pref.setBool('$keyPrefix$key', value);
        break;
      case List:
        await pref.setStringList('$keyPrefix$key', value);
        break;
      default:
        throw Exception('Unsupported type');
    }
  }

  Future<String?> getString(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('$keyPrefix$key');
  }

  Future<int?> getInt(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt('$keyPrefix$key');
  }

  Future<double?> getDouble(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble('$keyPrefix$key');
  }

  Future<bool?> getBool(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('$keyPrefix$key');
  }

  Future<bool> isExist(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.containsKey('$keyPrefix$key');
  }

  Future<void> removeLocally(String key) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('$keyPrefix$key');
  }
}
