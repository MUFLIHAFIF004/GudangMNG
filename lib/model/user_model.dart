class UserModel {
  final int id;
  final String nama;
  final String username;
  final String email;
  final String telepon;
  final String idKaryawan;
  final String? foto;
  final String? token;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.telepon,
    required this.idKaryawan,
    this.foto,
    this.token,
  });

  // Fungsi untuk konversi JSON dari Backend Go ke Objek Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      telepon: json['telepon'] ?? '',
      idKaryawan: json['id_karyawan'] ?? '',
      foto: json['foto'], 
      token: json['token'],
    );
  }

  // Untuk keperluan update profile nanti
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "username": username,
      "email": email,
      "telepon": telepon,
      "id_karyawan": idKaryawan,
      "foto": foto,
    };
  }
}