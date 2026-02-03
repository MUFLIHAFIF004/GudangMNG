class BarangModel {
  final int id;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final String satuan;
  final int stok;
  final String status; 
  final String? deskripsi;
  final String? foto;
  final DateTime? tglKadaluarsa;

  BarangModel({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.satuan,
    required this.stok,
    required this.status, 
    this.deskripsi,
    this.foto,
    this.tglKadaluarsa,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'] ?? 0,
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? '',
      satuan: json['satuan'] ?? '',
      stok: json['stok'] ?? 0,
      status: json['status'] ?? 'MASUK', 
      deskripsi: json['deskripsi'],
      foto: json['foto'],
      tglKadaluarsa: (json['tgl_kadaluarsa'] != null && json['tgl_kadaluarsa'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tgl_kadaluarsa'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "kode_barang": kodeBarang,
      "nama_barang": namaBarang,
      "kategori": kategori,
      "satuan": satuan,
      "stok": stok,
      "status": status,
      "deskripsi": deskripsi,
      "foto": foto,
      "tgl_kadaluarsa": tglKadaluarsa?.toIso8601String(),
    };
  }
}