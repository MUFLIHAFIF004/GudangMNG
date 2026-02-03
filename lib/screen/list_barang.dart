import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/barang_service.dart';
import '../model/barang_model.dart';
import '../model/riwayat_model.dart'; // MENGGUNAKAN RIWAYAT MODEL
import 'input_barang_screen.dart';

class ListBarangScreen extends StatefulWidget {
  const ListBarangScreen({super.key});

  @override
  State<ListBarangScreen> createState() => _ListBarangScreenState();
}

class _ListBarangScreenState extends State<ListBarangScreen> {
  final BarangService _barangService = BarangService();
  List<BarangModel> _allBarang = [];
  List<BarangModel> _filteredBarang = [];
  List<RiwayatModel> _allRiwayat = []; // Menampung data riwayat untuk tanggal manual
  bool _isLoading = true;

  String _selectedFilter = 'SEMUA';
  final List<String> _filterOptions = ['SEMUA', 'MASUK', 'KELUAR'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    // Mengambil dua data sekaligus
    final dataBarang = await _barangService.getAllBarang();
    final dataRiwayat = await _barangService.getRiwayat();
    
    if (mounted) {
      setState(() {
        _allBarang = dataBarang;
        _allRiwayat = dataRiwayat; // Simpan riwayat untuk dicocokkan
        _applyFilter(_selectedFilter);
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String status) {
    setState(() {
      _selectedFilter = status;
      if (status == 'SEMUA') {
        _filteredBarang = _allBarang;
      } else {
        _filteredBarang = _allBarang
            .where((b) => b.status.toUpperCase() == status)
            .toList();
      }
    });
  }

  // Fungsi untuk memotong jam 00:00:00
  String _cleanDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    return dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
  }

  @override
  Widget build(BuildContext context) {
    int totalStokMasuk = _allBarang
        .where((b) => b.status.toUpperCase() == 'MASUK')
        .fold(0, (sum, item) => sum + item.stok);

    int totalStokKeluar = _allBarang
        .where((b) => b.status.toUpperCase() == 'KELUAR')
        .fold(0, (sum, item) => sum + item.stok);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Data Inventaris',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(),
            _buildSummaryRow(totalStokMasuk, totalStokKeluar),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: Colors.red[800],
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBarang.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredBarang.length,
                            itemBuilder: (context, index) => _buildBarangCard(_filteredBarang[index]),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarangCard(BarangModel barang) {
    bool isMasuk = barang.status.toUpperCase() == 'MASUK';
    
    // MENCARI TANGGAL MANUAL DARI RIWAYAT BERDASARKAN BARANG ID
    String tglManual = "-";
    try {
      final riwayatTerkait = _allRiwayat.firstWhere((r) => r.barangId == barang.id);
      tglManual = _cleanDate(riwayatTerkait.tanggal);
    } catch (e) {
      tglManual = _cleanDate(barang.tglKadaluarsa); // Fallback jika riwayat tidak ditemukan
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(barang.foto),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(barang.namaBarang, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14))),
                      _buildMenuButton(barang),
                    ],
                  ),
                  _buildBadge(barang.status),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.qr_code, "Kode: ${barang.kodeBarang}"),
                  _buildDetailRow(Icons.layers, "Stok: ${barang.stok} ${barang.satuan}"),
                  
                  // MENAMPILKAN TANGGAL TRANSAKSI MANUAL (DARI RIWAYATMODEL)
                  _buildDetailRow(Icons.calendar_today, 
                      "${isMasuk ? 'Tgl Masuk' : 'Tgl Keluar'}: $tglManual"),
                  
                  // MENAMPILKAN TANGGAL KADALUARSA (DARI BARANGMODEL)
                  if (isMasuk && barang.tglKadaluarsa != null)
                    _buildDetailRow(Icons.timer_outlined, 
                        "Expired: ${_cleanDate(barang.tglKadaluarsa)}", iconColor: Colors.orange[800]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pendukung (Summary, DetailRow, Badge, dll) tetap sesuai desain asli
  Widget _buildSummaryRow(int masuk, int keluar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard(title: "TOTAL MASUK", value: masuk.toString(), color: Colors.green[700]!, subtitle: "Tersedia")),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryCard(title: "TOTAL KELUAR", value: keluar.toString(), color: Colors.orange[800]!, subtitle: "Terkirim")),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required Color color, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? foto) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: (foto == null || foto.isEmpty) 
          ? Icon(Icons.inventory_2_outlined, color: Colors.grey[400])
          : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(base64Decode(foto), fit: BoxFit.cover)),
    );
  }

  Widget _buildBadge(String status) {
    bool isMasuk = status.toUpperCase() == 'MASUK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: isMasuk ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: isMasuk ? Colors.green[700] : Colors.orange[700])),
    );
  }

  Widget _buildMenuButton(BarangModel barang) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      onSelected: (v) => v == 'edit' ? _handleEdit(barang) : _showDeleteConfirmation(barang),
      itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text("Edit")), const PopupMenuItem(value: 'delete', child: Text("Hapus"))],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16), color: Colors.white,
      child: Row(
        children: [
          Text("Filter: ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedFilter,
            items: _filterOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => v != null ? _applyFilter(v) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() { return const Center(child: Text("Tidak ada data")); }
  
  void _handleEdit(BarangModel barang) async {
    // Cek jika status barang adalah KELUAR
    if (barang.status.toUpperCase() == 'KELUAR') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Data dengan status KELUAR tidak diperbolehkan untuk diubah!",
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[900], // Warna merah tegas
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return; // Berhenti di sini, jangan buka form edit
    }

    // Jika status MASUK, jalankan edit seperti biasa
    bool isStatusMasuk = barang.status.toUpperCase() == 'MASUK';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputBarangScreen(
          isMasuk: isStatusMasuk,
          barang: barang,
        ),
      ),
    );
    if (result == true) _fetchData();
  }

  void _showDeleteConfirmation(BarangModel barang) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text("Hapus?"), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")), ElevatedButton(onPressed: () async { Navigator.pop(c); await _barangService.deleteBarang(barang.id); _fetchData(); }, child: const Text("Hapus"))]));
  }
}