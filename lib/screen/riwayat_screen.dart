import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/barang_service.dart';
import '../model/riwayat_model.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final BarangService _barangService = BarangService();
  late Future<List<RiwayatModel>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _barangService.getRiwayat();
  }

  // FUNGSI UNTUK REFRESH DATA
  void _refreshData() {
    setState(() {
      _riwayatFuture = _barangService.getRiwayat();
    });
  }

  // FUNGSI KONFIRMASI HAPUS
  void _showDeleteConfirmation(RiwayatModel riwayat) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Hapus Riwayat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus catatan riwayat ${riwayat.namaBarang}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog
              
              // Memanggil fungsi delete dari service (Pastikan fungsi ini sudah ada di BarangService)
              bool success = await _barangService.deleteRiwayat(riwayat.id);
              
              if (!mounted) return;
              
              if (success) {
                _refreshData(); // Refresh list setelah hapus
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Riwayat berhasil dihapus"), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal menghapus riwayat"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Log Aktivitas Gudang", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<RiwayatModel>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada riwayat transaksi", 
                    style: GoogleFonts.poppins(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final log = snapshot.data![index];
                bool isMasuk = log.tipe.toUpperCase() == "MASUK";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isMasuk ? Colors.green[50] : Colors.orange[50],
                      child: Icon(
                        isMasuk ? Icons.download : Icons.upload,
                        color: isMasuk ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    title: Text(log.namaBarang, 
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.keterangan, style: GoogleFonts.poppins(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy • HH:mm').format(log.createdAt),
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    // TOMBOL HAPUS DENGAN ICON TRASH
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${isMasuk ? '+' : '-'}${log.jumlah}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isMasuk ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          onPressed: () => _showDeleteConfirmation(log),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}