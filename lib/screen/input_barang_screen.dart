import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tb_gudangmng/services/barang_service.dart';
import 'package:tb_gudangmng/model/barang_model.dart';

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
  DateTime? _selectedDate;
  File? _imageFile;
  String? _base64Image;

  final List<String> _listSatuan = ['Pcs', 'Box', 'Karton', 'Pack', 'Unit'];
  final List<String> _listKategori = [
    'Makanan',
    'Minuman',
    'Elektronik',
    'Alat Tulis',
    'Lainnya',
  ];

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
      _selectedDate = widget.barang!.tglKadaluarsa;
      _base64Image = widget.barang!.foto;
      _selectedSKU = widget.barang!.kodeBarang;
    }
  }

  Future<void> _loadAllBarang() async {
    final data = await _barangService.getAllBarang();
    if (!mounted) return;
    setState(() => _allBarangs = data);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? cleanDate;
      if (_selectedDate != null) {
        cleanDate = _selectedDate!
            .toIso8601String()
            .split('.')[0]
            .replaceAll('T', ' ');
      }

      bool success;
      if (widget.barang != null) {
        // EDIT MASTER DATA
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
          tglKadaluarsa: cleanDate,
        );
      } else if (widget.isMasuk) {
        // REGISTRASI BARU
        success = await _barangService.createBarang(
          kodeBarang: _kodeController.text,
          namaBarang: _namaController.text,
          kategori: _selectedKategori ?? 'Lainnya',
          satuan: _selectedSatuan ?? 'Pcs',
          stok: int.parse(_jumlahController.text),
          status: "MASUK",
          deskripsi: _ketController.text,
          foto: _base64Image,
          tglKadaluarsa: cleanDate,
        );
      } else {
        // TRANSAKSI KELUAR (MUTASI)
        try {
          final selectedItem = _allBarangs.firstWhere(
            (b) => b.kodeBarang == _selectedSKU,
          );
          success = await _barangService.updateStok(
            id: selectedItem.id,
            jumlah: int.parse(_jumlahController.text),
            tipe: 'KELUAR',
            keterangan: _ketController.text,
          );
        } catch (e) {
          success = false;
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.barang != null ? 'Data Diperbarui' : 'Data Disimpan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal: Cek stok atau koneksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.barang != null
        ? 'Edit Barang'
        : (widget.isMasuk ? 'Input Barang Masuk' : 'Input Barang Keluar');
    Color themeColor = Colors.red[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    Text(
                      widget.barang != null
                          ? 'Perbarui informasi barang.'
                          : (widget.isMasuk
                                ? 'Daftarkan stok baru.'
                                : 'Catat pengeluaran stok.'),
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    _buildInput(
                      label: 'Nama Barang',
                      controller: _namaController,
                      icon: Icons.inventory,
                      enabled: widget.isMasuk,
                    ),
                    const SizedBox(height: 16),
                    widget.isMasuk
                        ? _buildInput(
                            label: 'Kode Barang (SKU)',
                            controller: _kodeController,
                            icon: Icons.qr_code,
                            enabled: widget.barang == null,
                          )
                        : _buildDropdown(
                            'Pilih Kode Barang (SKU)',
                            _allBarangs
                                .where((b) => b.status.toUpperCase() == 'MASUK')
                                .map((e) => e.kodeBarang)
                                .toList(),
                            _selectedSKU,
                            (v) {
                              if (v != null) {
                                final selected = _allBarangs.firstWhere(
                                  (e) => e.kodeBarang == v,
                                );
                                setState(() {
                                  _selectedSKU = v;
                                  _namaController.text = selected.namaBarang;
                                  _jumlahController.text = selected.stok
                                      .toString();
                                  _ketController.text =
                                      selected.deskripsi ?? '';
                                  _selectedSatuan = selected.satuan;
                                  _selectedKategori = selected.kategori;
                                  _base64Image = selected.foto;
                                  _kodeController.text = v;
                                });
                              }
                            },
                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            label: 'Jumlah',
                            controller: _jumlahController,
                            icon: Icons.numbers,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            'Satuan',
                            _listSatuan,
                            _selectedSatuan,
                            (v) => setState(() => _selectedSatuan = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.isMasuk || widget.barang != null) ...[
                      _buildDropdown(
                        'Kategori',
                        _listKategori,
                        _selectedKategori,
                        (v) => setState(() => _selectedKategori = v),
                      ),
                      const SizedBox(height: 16),
                      _buildDatePicker(context),
                      const SizedBox(height: 16),
                    ],
                    _buildInput(
                      label: 'Keterangan / Deskripsi',
                      controller: _ketController,
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Foto Barang",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
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

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    bool enabled = true,
  }) {
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
        fillColor: enabled ? Colors.transparent : Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      menuMaxHeight: 300,
      value: (currentValue != null && items.contains(currentValue))
          ? currentValue
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category, color: Colors.red),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[800]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Wajib' : null,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tgl Kadaluarsa',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedDate == null
              ? 'Pilih Tanggal'
              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : (_base64Image != null && _base64Image!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _base64Image!.startsWith('http')
                    ? Image.network(_base64Image!, fit: BoxFit.cover)
                    : Image.memory(
                        base64Decode(_base64Image!),
                        fit: BoxFit.cover,
                      ),
              )
            : Icon(Icons.camera_alt_outlined, color: Colors.red[800], size: 40),
      ),
    );
  }

  Widget _buildSubmitButton(String title, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
