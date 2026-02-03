class RiwayatModel {
  final int id;
  final int barangId;
  final String namaBarang;
  final String tipe;
  final int jumlah;
  final String keterangan;
  final String? tanggal;
  final DateTime createdAt;

  RiwayatModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.tipe,
    required this.jumlah,
    required this.keterangan,
    this.tanggal,
    required this.createdAt,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
  return RiwayatModel(
    id: json['id'] ?? 0,
    barangId: json['barang_id'] ?? 0, // Sesuai kolom DB
    namaBarang: json['nama_barang'] ?? '',
    tipe: json['tipe'] ?? '',
    jumlah: json['jumlah'] ?? 0,
    keterangan: json['keterangan'] ?? '',
    tanggal: json['tanggal'],
    createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}
}