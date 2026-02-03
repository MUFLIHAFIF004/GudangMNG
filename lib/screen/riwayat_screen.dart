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

  // State untuk Filter Bulan & Tahun
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Data Statis untuk Dropdown
  final List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  List<int> _getYears() {
    int currentYear = DateTime.now().year;
    // Menampilkan tahun dari 5 tahun lalu sampai 1 tahun ke depan
    return List.generate(7, (index) => (currentYear - 5) + index);
  }

  @override
  void initState() {
    super.initState();
    // Load data pertama kali
    _riwayatFuture = _barangService.getRiwayat();
  }

  // Fungsi untuk memuat ulang data (dipanggil saat refresh atau delete)
  void _refreshData() {
    setState(() {
      _riwayatFuture = _barangService.getRiwayat();
    });
  }

  void _showDeleteConfirmation(RiwayatModel riwayat) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "Hapus Riwayat",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus catatan riwayat ${riwayat.namaBarang}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Tampilkan loading indicator kecil atau tunggu proses
              bool success = await _barangService.deleteRiwayat(riwayat.id);

              if (!mounted) return;

              if (success) {
                _refreshData(); // Refresh list agar item hilang
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Riwayat berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gagal menghapus riwayat"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              "Hapus",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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
        title: Text(
          "Log Aktivitas Gudang",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // Tombol refresh manual di AppBar
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        children: [
          // 1. BAGIAN FILTER BULAN & TAHUN
          _buildFilterSection(),

          // 2. BAGIAN LIST RIWAYAT
          Expanded(
            child: FutureBuilder<List<RiwayatModel>>(
              future: _riwayatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gagal memuat data",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${snapshot.error}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshData,
                            child: const Text("Coba Lagi"),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(
                    "Belum ada data transaksi sama sekali.",
                  );
                }

                // LOGIKA FILTERING (Client-side)
                List<RiwayatModel> filteredList = snapshot.data!.where((item) {
                  return item.createdAt.month == _selectedMonth &&
                      item.createdAt.year == _selectedYear;
                }).toList();

                // Sorting: Terbaru paling atas
                filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filteredList.isEmpty) {
                  return _buildEmptyState(
                    "Tidak ada aktivitas pada\n${_monthNames[_selectedMonth - 1]} $_selectedYear",
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final log = filteredList[index];
                      bool isMasuk = log.tipe.toUpperCase() == "MASUK";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isMasuk
                                ? Colors.green[50]
                                : Colors.orange[50],
                            child: Icon(
                              isMasuk ? Icons.download : Icons.upload,
                              color: isMasuk
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                          title: Text(
                            log.namaBarang,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.keterangan,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy • HH:mm',
                                ).format(log.createdAt),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${isMasuk ? '+' : '-'}${log.jumlah}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isMasuk
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                  size: 20,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Periode Laporan",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.red[800],
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            _monthNames[index],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMonth = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.red[800],
                      ),
                      items: _getYears().map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            year.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedYear = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Tombol refresh di state kosong agar user bisa manual refresh
          TextButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Refresh Data"),
          ),
        ],
      ),
    );
  }
}
