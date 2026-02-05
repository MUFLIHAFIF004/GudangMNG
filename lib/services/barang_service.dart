import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_gudangmng/model/barang_model.dart';
import 'package:tb_gudangmng/model/riwayat_model.dart';

class BarangService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://gdmnbeckend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<List<BarangModel>> getAllBarang() async {
    try {
      final response = await dio.get('/barang/all');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => BarangModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
        'Dio Error Get Barang: ${e.response?.statusCode} - ${e.message}',
      );
      return [];
    }
  }

  Future<bool> createBarang({
    required String kodeBarang,
    required String namaBarang,
    required String kategori,
    required String satuan,
    required int stok,
    required String status,
    String? deskripsi,
    String? foto,
    required String tglCatatan,
    required String tglKadaluarsa,
  }) async {
    try {
      // 1. Bersihkan format tanggal Kadaluarsa
      String finalExpDate = tglKadaluarsa;
      if (finalExpDate.contains('T')) {
        finalExpDate = finalExpDate.replaceAll('T', ' ').split('.')[0];
      }

      String finalNoteDate = tglCatatan;
      if (finalNoteDate.contains('T')) {
        finalNoteDate = finalNoteDate.replaceAll('T', ' ').split('.')[0];
      }

      final response = await dio.post(
        '/barang/create',
        data: {
          "kode_barang": kodeBarang,
          "nama_barang": namaBarang,
          "kategori": kategori,
          "satuan": satuan,
          "stok": stok,
          "status": status,
          "deskripsi": deskripsi,
          "foto": foto,
          "tanggal": finalNoteDate, 
          "tgl_kadaluarsa": finalExpDate, 
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio Error Create: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> updateBarang({
    required int id,
    required String kodeBarang,
    required String namaBarang,
    required String kategori,
    required String satuan,
    required String status,
    required int stok,
    String? deskripsi,
    String? foto,
    required String tglCatatan,
    required String tglKadaluarsa,
  }) async {
    try {
      String finalDate = tglKadaluarsa;
      if (finalDate.contains('T')) {
        finalDate = finalDate.replaceAll('T', ' ').split('.')[0];
      }

      String finalNoteDate = tglCatatan;
      if (finalNoteDate.contains('T')) {
        finalNoteDate = finalNoteDate.replaceAll('T', ' ').split('.')[0];
      }

      final response = await dio.put(
        '/barang/update',
        data: {
          "id": id,
          "kode_barang": kodeBarang,
          "nama_barang": namaBarang,
          "kategori": kategori,
          "satuan": satuan,
          "stok": stok,
          "status": status,
          "deskripsi": deskripsi,
          "foto": foto,
          "tanggal": finalNoteDate,
          "tgl_kadaluarsa": finalDate,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio Error Update: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> deleteBarang(int id) async {
    try {
      final response = await dio.delete(
        '/barang/delete',
        queryParameters: {'id': id},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio Error Delete: ${e.response?.data}');
      return false;
    }
  }

  // --- BAGIAN INI YANG PALING PENTING UNTUK RIWAYAT KELUAR ---
  Future<bool> updateStok({
    required int id,
    required int jumlah,
    required String tipe,
    required String keterangan,
    String? tanggal,
  }) async {
    try {
      
      String? finalDate = tanggal;
      if (finalDate != null && finalDate.contains('T')) {
        finalDate = finalDate.replaceAll('T', ' ').split('.')[0];
      }

      final response = await dio.post(
        '/stok/update',
        data: {
          "id": id,
          "jumlah": jumlah,
          "tipe": tipe,
          "keterangan": keterangan,
          "tanggal": tanggal,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Dio Error Stok Update: ${e.response?.data}');
      return false;
    }
  }

  Future<List<RiwayatModel>> getRiwayat() async {
    try {
      final response = await dio.get('/riwayat/all');

      if (response.statusCode == 200 && response.data is List) {
        List data = response.data;
        return data.map((e) => RiwayatModel.fromJson(e)).toList();
      } else {
        debugPrint('Respon server bukan list: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.response?.data ?? e.message}');
      return [];
    } catch (e) {
      debugPrint('General Error: $e');
      return [];
    }
  }

  Future<bool> deleteRiwayat(int id) async {
    try {
      final response = await dio.delete(
        '/riwayat/delete',
        queryParameters: {'id': id},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error Delete Riwayat: ${e.message}');
      return false;
    }
  }
}
