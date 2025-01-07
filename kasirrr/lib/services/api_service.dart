import 'dart:convert';
import 'package:apotek/constants/extensions.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/kategori.dart';
import 'package:apotek/models/laporan_keuangan_response.dart';
import 'package:apotek/models/log_stok.dart';
import 'package:apotek/models/summary.dart';
import 'package:apotek/models/transaksi.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/produk.dart';
import '../models/pengguna.dart';

class ApiService {
  final baseUrl = Variable.baseUrl;
  final headers = Variable.headers;

  // API Produk
  Future<Either<String, List<Produk>>> getProdukList({String search = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/produk?search=$search'));
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(result.map<Produk>((data) => Produk.fromJson(data)).toList());
    } else {
      return const Left('Failed to load produk');
    }
  }

  Future<Either<String, bool>> createProduk(Produk produk) async {
    final response = await http.post(
      Uri.parse('$baseUrl/produk'),
      headers: headers,
      body: json.encode(produk.toJson()),
    );
    if (response.statusCode == 201) {
      return const Right(true);
    } else {
      return const Left('Failed to create produk');
    }
  }

  Future<Either<String, bool>> updateProduk(String id, Produk produk) async {
    final response = await http.put(
      Uri.parse('$baseUrl/produk/$id'),
      headers: headers,
      body: json.encode(produk.toJson()),
    );
    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      throw Exception('Failed to update produk');
    }
  }

  Future<bool> deleteProduk(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/produk/$id'));
    return response.statusCode == 200;
  }

  // API Kategori
  Future<Either<String, List<Kategori>>> getKategoriList({String search = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/kategori?search=$search'));
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(result.map<Kategori>((data) => Kategori.fromJson(data)).toList());
    } else {
      return const Left('Failed to load Kategori');
    }
  }

  Future<Either<String, bool>> createKategori(Kategori kategori) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kategori'),
      headers: headers,
      body: json.encode(kategori.toJson()),
    );
    if (response.statusCode == 201) {
      return const Right(true);
    } else {
      return const Left('Failed to create kategori');
    }
  }

  Future<Either<String, bool>> updateKategori(String id, Kategori kategori) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kategori/$id'),
      headers: headers,
      body: json.encode(kategori.toJson()),
    );
    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      throw Exception('Failed to update kategori');
    }
  }

  Future<bool> deleteKategori(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kategori/$id'));
    return response.statusCode == 200;
  }

  // API Transaksi
  Future<Either<String, String>> createTransaksi(Transaksi transaksi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transaksi'),
      headers: headers,
      body: json.encode(transaksi.toJson()),
    );
    if (response.statusCode == 201) {
      return const Right('Success to create transaksi');
    } else {
      return const Left('Failed to create transaksi');
    }
  }

  Future<List<Map<String, dynamic>>> getLaporanPenjualan({
    required String periode,
    String? tanggalMulai,
    String? tanggalAkhir,
  }) async {
    final queryParams = {
      'periode': periode,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (tanggalAkhir != null) 'tanggal_akhir': tanggalAkhir,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/laporan/penjualan').replace(queryParameters: queryParams),
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse);
    } else {
      throw Exception('Failed to load laporan');
    }
  }

  // API Pengguna
  Future<Either<String, Pengguna>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return Right(Pengguna.fromJson(response.data));
      } else {
        return Left(json.decode(response.body)['message']);
      }
    } catch (_) {
      return const Left('Login gagal');
    }
  }

  Future<Either<String, List<Pengguna>>> getPenggunaList({String search = ''}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengguna?search=$search'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(result.map<Pengguna>((data) => Pengguna.fromJson(data)).toList());
    } else {
      throw Exception('Failed to load pengguna');
    }
  }

  Future<Either<String, bool>> createPengguna(Pengguna pengguna) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pengguna'),
      headers: headers,
      body: json.encode(pengguna.toJson()),
    );
    if (response.statusCode == 201) {
      return const Right(true);
    } else {
      return const Left('Failed to create pengguna');
    }
  }

  Future<Either<String, bool>> updatePengguna(String id, Pengguna pengguna) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pengguna/$id'),
      headers: headers,
      body: json.encode(pengguna.toJson()),
    );

    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      return const Left('Failed to update pengguna');
    }
  }

  Future<bool> updatePenggunaStatus(String id, bool isAktif) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pengguna/change-status/$id'),
      headers: headers,
      body: json.encode({'is_aktif': isAktif}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updatePenggunaPassword(String id, String password) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pengguna/reset-password/$id'),
      headers: headers,
      body: json.encode({'password': password}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deletePengguna(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pengguna/$id'));
    return response.statusCode == 200;
  }

  // Helper methods untuk authentication
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    // Implementasi untuk mengambil token dari secure storage
    // Gunakan package flutter_secure_storage
    return null;
  }

  // TODO: updateProfile API
  Future<bool> updateProfile({
    required String id,
    required String nama,
    required String email,
    required String telepon,
    String? fotoProfile,
  }) async {
    //  'username' => 'required',
    // 'nama' => 'required',
    // 'role' => 'required',
    // 'email' => 'required',
    // 'telepon' => 'nullable',
    // 'foto_profile' => 'nullable|image',
    final user = Variable.pengguna;
    final pengguna = Pengguna(
      id: user?.id,
      username: user?.username,
      nama: nama,
      role: user?.role,
      email: email,
      telepon: telepon,
    );
    final response = await http.put(
      Uri.parse('$baseUrl/pengguna/$id'),
      headers: headers,
      body: json.encode(pengguna.toJson()),
    );

    return response.statusCode == 200;
    // var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/pengguna/$id'))
    //   // ..fields.addAll({
    //   //   'nama': nama,
    //   //   'email': email,
    //   //   'telepon': telepon,
    //   // })
    //   ..headers.addAll({'Content-Type': 'multipart/form-data'});
    // if (fotoProfile != null) {
    //   request.files.add(await http.MultipartFile.fromPath('foto_profile', fotoProfile));
    // }
    // final response = await request.send();
    // print(['------- update profile', response.statusCode]);
    // return response.statusCode == 200;

    // final response = await http.put(
    //   Uri.parse('$baseUrl/pengguna/$id'),
    //   headers: await _getHeaders(),
    //   body: jsonEncode({
    //     'nama': nama,
    //     'email': email,
    //     'telepon': telepon,
    //     'foto_profile': fotoProfile,
    //   }),
    // );

    // if (response.statusCode != 200) {
    //   throw Exception('Gagal memperbarui profil');
    // }

    // final response = await http.put(
    //   Uri.parse('$baseUrl/pengguna/$id'),
    //   headers: headers,
    //   body: json.encode({
    //     'foto_profile': http.MultipartFile(File(fotoProfile!), filename: 'foto_profile'),
    //     'nama': nama,
    //     'email': email,
    //     'telepon': telepon,
    //   }),
    // );
    // var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/pengguna/$id'));
    // ..fields.addAll({
    //   'nama': nama,
    //   'email': email,
    //   'telepon': telepon,
    // });
    // final File file = File(fotoProfile ?? '');
    // request.headers.addAll({'Content-Type': 'multipart/form-data'});
    // request.files.add(http.MultipartFile('foto_profile', file.readAsBytes().asStream(), file.lengthSync()));
    // final response = await request.send();
    // print(['------- update profile', response.statusCode]);
    // return response.statusCode == 200;
    // if (response.statusCode == 200) {
    //   return const Right(true);
    // } else {
    //   return const Left('Failed to update pengguna');
    // }
  }

  // Tambahkan method untuk export laporan
  Future<List<int>> exportLaporanPDF({
    required String periode,
    String? tanggalMulai,
    String? tanggalAkhir,
  }) async {
    final queryParams = {
      'periode': periode,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (tanggalAkhir != null) 'tanggal_akhir': tanggalAkhir,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/laporan/export-pdf').replace(queryParameters: queryParams),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Gagal mengekspor PDF');
    }
  }

  Future<List<int>> exportLaporanExcel({
    required String periode,
    String? tanggalMulai,
    String? tanggalAkhir,
  }) async {
    final queryParams = {
      'periode': periode,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (tanggalAkhir != null) 'tanggal_akhir': tanggalAkhir,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/laporan/export-excel').replace(queryParameters: queryParams),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Gagal mengekspor Excel');
    }
  }

  // API Log Stok
  Future<Either<String, List<LogStok>>> getLogStokList() async {
    final response = await http.get(Uri.parse('$baseUrl/logStok'));
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(result.map<LogStok>((data) => LogStok.fromMap(data)).toList());
    } else {
      return const Left('Failed to load log stok');
    }
  }

  Future<Either<String, bool>> createLogStok(LogStok logStok) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logStok'),
      headers: headers,
      body: json.encode(logStok.toJson()),
    );
    if (response.statusCode == 201) {
      return const Right(true);
    } else {
      return const Left('Failed to create log stok');
    }
  }

  // API Dashboard
  Future<Either<String, SummaryDashboard>> getSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(SummaryDashboard.fromMap(result));
    } else {
      return const Left('Failed to load Summary');
    }
  }

  Future<Either<String, LaporanKeuanganResponse>> getLaporan({required String periode, required String date}) async {
    final response = await http.get(Uri.parse('$baseUrl/laporan?date=$date&periode=$periode'));
    if (response.statusCode == 200) {
      final result = response.data;
      return Right(LaporanKeuanganResponse.fromMap(result));
    } else {
      return const Left('Failed to load laporan');
    }
  }
}
