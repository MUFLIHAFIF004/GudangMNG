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

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  List<int> _getYears() {
    int currentYear = DateTime.now().year;
    return List.generate(7, (index) => (currentYear - 5) + index);
  }

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _barangService.getRiwayat();
  }

  void _refreshData() {
    setState(() {
      _riwayatFuture = _barangService.getRiwayat();
    });
  }

  void _showDeleteConfirmation(RiwayatModel riwayat) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Hapus Riwayat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Hapus catatan riwayat ${riwayat.namaBarang}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () async {
              Navigator.pop(dialogContext);
              bool success = await _barangService.deleteRiwayat(riwayat.id);
              if (success) _refreshData();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
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
        title: Text("Log Aktivitas Gudang", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder<List<RiwayatModel>>(
              future: _riwayatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Gagal memuat data"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState("Belum ada data transaksi.");
                }

                // FILTERING BERDASARKAN TANGGAL YANG DIINPUT USER (log.tanggal)
                List<RiwayatModel> filteredList = snapshot.data!.where((item) {
                  DateTime dateToCompare = item.tanggal != null 
                      ? DateTime.tryParse(item.tanggal!) ?? item.createdAt 
                      : item.createdAt;
                  return dateToCompare.month == _selectedMonth && dateToCompare.year == _selectedYear;
                }).toList();

                if (filteredList.isEmpty) {
                  return _buildEmptyState("Tidak ada aktivitas pada periode ini.");
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final log = filteredList[index];
                    bool isMasuk = log.tipe.toUpperCase() == "MASUK";

                    // FORMAT TANGGAL DARI FIELD 'tanggal' (RiwayatModel)
                    String displayDate = log.tanggal != null && log.tanggal!.isNotEmpty
                        ? DateFormat('dd MMM yyyy').format(DateTime.parse(log.tanggal!))
                        : DateFormat('dd MMM yyyy').format(log.createdAt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMasuk ? Colors.green[50] : Colors.orange[50],
                          child: Icon(isMasuk ? Icons.download : Icons.upload, color: isMasuk ? Colors.green[700] : Colors.orange[700]),
                        ),
                        title: Text(log.namaBarang, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KETERANGAN GABUNGAN DARI BACKEND
                            Text(log.keterangan, style: GoogleFonts.poppins(fontSize: 12)),
                            const SizedBox(height: 4),
                            // TANGGAL TRANSAKSI USER
                            Text("Tgl Transaksi: $displayDate", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${isMasuk ? '+' : '-'}${log.jumlah}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isMasuk ? Colors.green : Colors.red)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _showDeleteConfirmation(log)),
                          ],
                        ),
                      ),
                    );
                  },
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
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_monthNames[i]))),
                  onChanged: (v) => setState(() => _selectedMonth = v!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  isExpanded: true,
                  items: _getYears().map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (v) => setState(() => _selectedYear = v!),
                ),
              ),
            ),
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
          const Icon(Icons.calendar_month_outlined, size: 60, color: Colors.black12),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}