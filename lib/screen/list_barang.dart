import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import '../services/barang_service.dart';
import '../model/barang_model.dart';
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
    final data = await _barangService.getAllBarang();
    if (mounted) {
      setState(() {
        _allBarang = data;
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

  // --- LOGIKA EDIT YANG DIPERBAIKI ---
  void _handleEdit(BarangModel barang) async {
    // Tentukan mode berdasarkan status barang yang dipilih
    // Jika statusnya 'MASUK', buka form mode Masuk.
    // Jika 'KELUAR', buka form mode Keluar.
    bool isStatusMasuk = barang.status.toUpperCase() == 'MASUK';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputBarangScreen(
          isMasuk: isStatusMasuk, // Kirim status yang benar
          barang: barang,
        ),
      ),
    );
    if (result == true) _fetchData();
  }

  void _showDeleteConfirmation(BarangModel barang) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Hapus Barang",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus ${barang.namaBarang}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);

              bool success = await _barangService.deleteBarang(barang.id);

              if (!mounted) return;

              if (success) {
                _fetchData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Barang berhasil dihapus"),
                      backgroundColor: Colors.green),
                );
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Gagal menghapus barang"),
                      backgroundColor: Colors.red),
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
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "TOTAL MASUK",
                      value: totalStokMasuk.toString(),
                      color: Colors.green[700]!,
                      subtitle: "Stok Tersedia",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "TOTAL KELUAR",
                      value: totalStokKeluar.toString(),
                      color: Colors.orange[800]!,
                      subtitle: "Stok Terkirim",
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: Colors.red[800],
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBarang.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            itemCount: _filteredBarang.length,
                            itemBuilder: (context, index) =>
                                _buildBarangCard(_filteredBarang[index]),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5))
      ]),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.red[800], size: 20),
          const SizedBox(width: 10),
          Text("Filter Status:",
              style:
                  GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
                items: _filterOptions
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) => val != null ? _applyFilter(val) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD DIPERBARUI LABELNYA ---
  Widget _buildBarangCard(BarangModel barang) {
    bool isMasuk = barang.status.toUpperCase() == 'MASUK';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: _buildImageWidget(barang.foto),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(barang.namaBarang,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      _buildMenuButton(barang),
                    ],
                  ),
                  _buildBadge(barang.status),
                  const SizedBox(height: 8),
                  
                  // INFORMASI LENGKAP
                  _buildDetailRow(Icons.qr_code, "Kode: ${barang.kodeBarang}"),
                  _buildDetailRow(Icons.layers, "Stok: ${barang.stok} ${barang.satuan}"),
                  _buildDetailRow(Icons.category, "Kategori: ${barang.kategori}"),
                  
                  // Label Tanggal Dinamis (Masuk/Keluar)
                  if (barang.tglKadaluarsa != null)
                    _buildDetailRow(Icons.calendar_today, 
                        "${isMasuk ? 'Tgl Masuk' : 'Tgl Keluar'}: ${DateFormat('dd MMM yyyy').format(barang.tglKadaluarsa!)}"),
                  
                  if (barang.deskripsi != null && barang.deskripsi!.isNotEmpty)
                    _buildDetailRow(Icons.notes, "Ket: ${barang.deskripsi}", isMultiLine: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              maxLines: isMultiLine ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BarangModel barang) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      onSelected: (val) =>
          val == 'edit' ? _handleEdit(barang) : _showDeleteConfirmation(barang),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              SizedBox(width: 10),
              Text("Edit")
            ])),
        const PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text("Hapus")
            ])),
      ],
    );
  }

  Widget _buildImageWidget(String? foto) {
    if (foto == null || foto.isEmpty) {
      return Icon(Icons.inventory_2_outlined, color: Colors.grey[400]);
    }
    try {
      if (foto.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(foto,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(base64Decode(foto),
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
      );
    } catch (e) {
      return const Icon(Icons.broken_image, color: Colors.red);
    }
  }

  Widget _buildBadge(String status) {
    bool isMasuk = status.toUpperCase() == 'MASUK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: isMasuk ? Colors.green[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isMasuk ? Colors.green[200]! : Colors.orange[200]!)),
      child: Text(status.toUpperCase(),
          style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMasuk ? Colors.green[700] : Colors.orange[700])),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.layers_clear_outlined,
                    size: 70, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Tidak ada data $_selectedFilter",
                    style: GoogleFonts.poppins(color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}