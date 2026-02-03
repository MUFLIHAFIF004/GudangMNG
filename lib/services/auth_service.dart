import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_gudangmng/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://gdmnbeckend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<bool> register({
    required String nama,
    required String username,
    required String email,
    required String telepon,
    required String idKaryawan,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          "nama": nama,
          "username": username,
          "email": email,
          "telepon": telepon,
          "id_karyawan": idKaryawan,
          "password": password,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio error register: ${e.response?.statusCode} - ${e.message}');
      return false;
    }
  }

  Future<UserModel?> getUserProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('id'); // Ambil ID dari lokal

    if (userId == null) return null;

    final response = await dio.get('/profile', queryParameters: {'id': userId});
    
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data); 
    }
    return null;
  } catch (e) {
    debugPrint("Error Get Profile: $e");
    return null;
  }
}

  Future<bool> updateProfile({
    required int id,
    required String nama,
    required String username,
    required String email,
    required String telepon,
    required String idKaryawan,
    String? foto, 
  }) async {
    try {
      final response = await dio.put(
        '/profile/update',
        data: {
          "id": id,
          "nama": nama,
          "username": username,
          "email": email,
          "telepon": telepon,
          "id_karyawan": idKaryawan,
          "foto": foto, 
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error Update Profile: ${e.response?.data}');
      return false;
    }
  }

  Future<UserModel?> login(String identifier, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          "username": identifier, 
          "password": password
        },
      );

      if (response.statusCode == 200) {
        var data = response.data['user'];
        data['token'] = response.data['token'];
        return UserModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      String errorMsg = e.response?.data['message'] ?? 'Gagal login';
      debugPrint('Login Error: $errorMsg');
      return null;
    }
  }
}