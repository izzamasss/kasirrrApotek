import 'package:apotek/constants/variable.dart';

class Pengguna {
  final String? id;
  final String? username;
  final String? nama;
  final String? role; // 'kasir' atau 'admin'
  final String? password; // Opsional, hanya untuk create/update
  final String? telepon;
  final String? email;
  final String? token;
  final String? fotoProfile;
  final bool isAktif;
  final DateTime? createdAt;

  Pengguna({
    this.id,
    this.username,
    this.nama,
    this.role,
    this.password,
    this.telepon,
    this.email,
    this.isAktif = true,
    this.token,
    this.fotoProfile,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  String? get foto => (fotoProfile ?? '').contains('http') ? fotoProfile : '${Variable.serverUrl}/uploads/$fotoProfile';

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'],
      username: json['username'],
      nama: json['nama'],
      role: json['role'],
      telepon: json['telepon'],
      email: json['email'],
      isAktif: json['is_aktif'] == 1 ? true : false,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at']),
      token: json['token'],
      fotoProfile: json['foto_profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nama': nama,
      'role': role,
      'telepon': telepon,
      'email': email,
      if (password != null) 'password': password,
      'is_aktif': isAktif,
      'created_at': createdAt?.toIso8601String(),
      'foto_profile': fotoProfile,
      'token': token,
    };
  }

  Map<String, dynamic> toJsonForLocal() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'role': role,
      'telepon': telepon,
      'email': email,
      if (password != null) 'password': password,
      'is_aktif': isAktif,
      'created_at': createdAt?.toIso8601String(),
      'foto_profile': fotoProfile,
      'token': token,
    };
  }

  // Copy with method untuk update instance
  Pengguna copyWith({bool? isAktif}) {
    return Pengguna(
      isAktif: isAktif ?? this.isAktif,
      id: id,
      username: username,
      nama: nama,
      role: role,
      password: password,
      telepon: telepon,
      email: email,
      createdAt: createdAt,
      token: token,
    );
  }
}
