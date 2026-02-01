import 'dart:async';
import 'package:tb_gudangmng/model/user_model.dart';

class AuthService {
  // Simulasi delay koneksi ke server
  Future<UserModel?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading

    // Logika dummy (Nanti diganti request ke Railway)
    if (username == "admin" && password == "123456") {
      return UserModel(username: username, token: "dummy_token_123");
    } else {
      return null; // Login gagal
    }
  }

  Future<bool> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulasi register berhasil
    return true;
  }
}
