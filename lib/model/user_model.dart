class UserModel {
  final String username;
  final String token; // Persiapan untuk token autentikasi API

  UserModel({required this.username, required this.token});

  // Factory untuk parsing JSON dari API Railway nanti
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      token: json['token'],
    );
  }
}