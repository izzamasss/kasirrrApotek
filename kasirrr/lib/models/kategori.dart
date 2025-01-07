class Kategori {
  final String id;
  final String nama;
  final String? deskripsi;
  final bool isAktif;

  Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.isAktif = true,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      isAktif: json['is_aktif'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'nama': nama,
      if (deskripsi != null) 'deskripsi': deskripsi,
      'is_aktif': isAktif,
    };
  }
}
