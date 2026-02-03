import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tb_gudangmng/services/barang_service.dart';
import 'package:tb_gudangmng/model/barang_model.dart';
import 'package:tb_gudangmng/model/riwayat_model.dart'; 

class InputBarangScreen extends StatefulWidget {
  final bool isMasuk;
  final BarangModel? barang;

  const InputBarangScreen({super.key, required this.isMasuk, this.barang});

  @override
  State<InputBarangScreen> createState() => _InputBarangScreenState();
}

class _InputBarangScreenState extends State<InputBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final BarangService _barangService = BarangService();
  bool _isLoading = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();

  List<BarangModel> _allBarangs = [];
  String? _selectedSKU;
  String? _selectedSatuan;
  String? _selectedKategori;
  
  DateTime? _selectedTransDate; 
  DateTime? _selectedExpDate;   
  
  File? _imageFile;
  String? _base64Image;

  final List<String> _listSatuan = ['Pcs', 'Box', 'Karton', 'Pack', 'Unit'];
  final List<String> _listKategori = ['Makanan', 'Minuman', 'Elektronik', 'Alat Tulis', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _loadAllBarang();
    
    if (widget.barang != null) {
      _namaController.text = widget.barang!.namaBarang;
      _kodeController.text = widget.barang!.kodeBarang;
      _jumlahController.text = widget.barang!.stok.toString();
      _ketController.text = widget.barang!.deskripsi ?? '';
      _selectedSatuan = widget.barang!.satuan;
      _selectedKategori = widget.barang!.kategori;
      _base64Image = widget.barang!.foto;
      _selectedSKU = widget.barang!.kodeBarang;
      
      if (widget.barang!.tglKadaluarsa != null) {
        _selectedExpDate = DateTime.tryParse(widget.barang!.tglKadaluarsa!);
      }
      _selectedTransDate = DateTime.now();
    } else {
      _selectedTransDate = DateTime.now();
    }
  }

  Future<void> _loadAllBarang() async {
    final data = await _barangService.getAllBarang();
    if (!mounted) return;
    setState(() => _allBarangs = data);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      List<int> imageBytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageFile = file;
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isExpired) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpired 
          ? (_selectedExpDate ?? DateTime.now().add(const Duration(days: 365)))
          : (_selectedTransDate ?? DateTime.now()),
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpired) _selectedExpDate = picked;
        else _selectedTransDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTransDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal transaksi wajib dipilih!'), backgroundColor: Colors.red));
        return;
      }

      setState(() => _isLoading = true);
      
      String transDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedTransDate!);
      String expDateStr = _selectedExpDate != null 
          ? DateFormat('yyyy-MM-dd HH:info MM:ss').format(_selectedExpDate!) 
          : transDateStr;

      final riwayatEntry = RiwayatModel(
        id: 0,
        barangId: widget.barang?.id ?? 0,
        namaBarang: _namaController.text,
        tipe: widget.isMasuk ? "MASUK" : "KELUAR",
        jumlah: int.parse(_jumlahController.text),
        keterangan: _ketController.text,
        tanggal: transDateStr, 
        createdAt: DateTime.now(),
      );

      bool success;
      if (widget.barang != null) {
        success = await _barangService.updateBarang(
          id: widget.barang!.id,
          kodeBarang: _kodeController.text,
          namaBarang: _namaController.text,
          kategori: _selectedKategori ?? 'Lainnya',
          satuan: _selectedSatuan ?? 'Pcs',
          stok: int.parse(_jumlahController.text),
          status: widget.barang!.status,
          deskripsi: _ketController.text,
          foto: _base64Image,
          tglKadaluarsa: expDateStr,
        );
      } else if (widget.isMasuk) {
        success = await _barangService.createBarang(
          kodeBarang: _kodeController.text,
          namaBarang: riwayatEntry.namaBarang,
          kategori: _selectedKategori ?? 'Lainnya',
          satuan: _selectedSatuan ?? 'Pcs',
          stok: riwayatEntry.jumlah,
          status: riwayatEntry.tipe,
          deskripsi: riwayatEntry.keterangan,
          foto: _base64Image,
          tglKadaluarsa: riwayatEntry.tanggal!, 
        );
      } else {
        try {
          final selectedItem = _allBarangs.firstWhere((b) => b.kodeBarang == _selectedSKU);
          success = await _barangService.updateStok(
            id: selectedItem.id,
            jumlah: riwayatEntry.jumlah,
            tipe: riwayatEntry.tipe,
            keterangan: riwayatEntry.keterangan,
            tanggal: riwayatEntry.tanggal, 
          );
        } catch (e) { success = false; }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.barang != null ? 'Data Berhasil Diperbarui' : 'Data Berhasil Disimpan'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.barang != null ? 'Edit Barang' : (widget.isMasuk ? 'Input Barang Masuk' : 'Input Barang Keluar');
    Color themeColor = widget.isMasuk ? Colors.red[800]! : Colors.orange[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInput(label: 'Nama Barang', controller: _namaController, icon: Icons.inventory, enabled: widget.isMasuk),
                    const SizedBox(height: 16),
                    widget.isMasuk
                        ? _buildInput(label: 'Kode Barang (SKU)', controller: _kodeController, icon: Icons.qr_code)
                        : _buildDropdown(
                            'Pilih Kode Barang (SKU)',
                            _allBarangs.where((b) => b.status.toUpperCase() == 'MASUK').map((e) => e.kodeBarang).toList(),
                            _selectedSKU,
                            (v) {
                              if (v != null) {
                                final selected = _allBarangs.firstWhere((e) => e.kodeBarang == v);
                                setState(() {
                                  _selectedSKU = v;
                                  _namaController.text = selected.namaBarang;
                                  _kodeController.text = v;
                                  // Memasukkan stok langsung ke dalam field jumlah
                                  _jumlahController.text = selected.stok.toString();
                                  _selectedSatuan = selected.satuan; 
                                  _selectedKategori = selected.kategori;
                                  _base64Image = selected.foto;
                                });
                              }
                            },
                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInput(label: 'Jumlah', controller: _jumlahController, icon: Icons.numbers, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('Satuan', _listSatuan, _selectedSatuan, (v) => setState(() => _selectedSatuan = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown('Kategori', _listKategori, _selectedKategori, (v) => setState(() => _selectedKategori = v)),
                    const SizedBox(height: 16),
                    _buildDatePicker(context: context, label: widget.isMasuk ? 'Tanggal Masuk' : 'Tanggal Keluar', selectedDate: _selectedTransDate, onTap: () => _selectDate(context, false)),
                    const SizedBox(height: 16),
                    if (widget.isMasuk) ...[
                      _buildDatePicker(context: context, label: 'Tanggal Kadaluarsa (Expired)', selectedDate: _selectedExpDate, onTap: () => _selectDate(context, true)),
                      const SizedBox(height: 16),
                    ],
                    _buildInput(label: 'Keterangan', controller: _ketController, icon: Icons.note, maxLines: 3),
                    const SizedBox(height: 20),
                    Text("Foto Barang", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    _buildImagePicker(),
                    const SizedBox(height: 40),
                    _buildSubmitButton('SIMPAN DATA', themeColor),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInput({required String label, required TextEditingController controller, required IconData icon, bool isNumber = false, int maxLines = 1, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: (currentValue != null && items.contains(currentValue)) ? currentValue : null,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: const Icon(Icons.category, color: Colors.red), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Wajib' : null,
    );
  }

  Widget _buildDatePicker({required BuildContext context, required String label, required DateTime? selectedDate, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(selectedDate == null ? 'Pilih Tanggal...' : DateFormat('dd MMM yyyy').format(selectedDate), style: GoogleFonts.poppins(fontSize: 15, color: selectedDate == null ? Colors.grey[600] : Colors.black)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: widget.isMasuk ? _pickImage : null, 
      child: Container(
        height: 150, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: _imageFile != null 
            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover)) 
            : (_base64Image != null && _base64Image!.isNotEmpty) 
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(_base64Image!), fit: BoxFit.cover)) 
                : const Icon(Icons.camera_alt_outlined, color: Colors.red, size: 40),
      ),
    );
  }

  Widget _buildSubmitButton(String title, Color color) {
    return SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: _isLoading ? null : _handleSave, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }
}