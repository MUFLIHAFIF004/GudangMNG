import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputBarangScreen extends StatefulWidget {
  final bool isMasuk; // True = Barang Masuk, False = Barang Keluar

  const InputBarangScreen({super.key, required this.isMasuk});

  @override
  State<InputBarangScreen> createState() => _InputBarangScreenState();
}

class _InputBarangScreenState extends State<InputBarangScreen> {
  final _formKey = GlobalKey<FormState>(); // Validasi data [cite: 11]

  @override
  Widget build(BuildContext context) {
    String title = widget.isMasuk ? 'Input Barang Masuk' : 'Input Barang Keluar';
    Color themeColor = widget.isMasuk ? Colors.red[800]! : Colors.red[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isMasuk 
                  ? 'Catat barang yang baru tiba di gudang.' 
                  : 'Catat barang yang akan dikirim keluar.',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Form Input [cite: 4]
              _buildInput(label: 'Nama Barang', icon: Icons.inventory),
              const SizedBox(height: 16),
              _buildInput(label: 'Kode Barang (SKU)', icon: Icons.qr_code),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Jumlah', icon: Icons.numbers, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput(label: 'Satuan (Pcs/Box)', icon: Icons.category)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(label: 'Keterangan / Catatan', icon: Icons.note, maxLines: 3),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Panggil API Create/Update 
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data $title Berhasil Disimpan!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('SIMPAN DATA', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required IconData icon, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null, // Validasi [cite: 11]
    );
  }
}