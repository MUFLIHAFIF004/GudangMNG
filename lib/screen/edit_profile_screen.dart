import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller untuk form input
  final TextEditingController _nameController = TextEditingController(
    text: "Admin Gudang",
  );
  final TextEditingController _usernameController = TextEditingController(
    text: "admingudang",
  );
  final TextEditingController _npmController = TextEditingController(
    text: "12345678",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "admin@gudang.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "081234567890",
  );

  // Variable untuk menyimpan file foto yang dipilih
  File? _selectedImage;

  // Fungsi untuk mengambil gambar dari Galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Membuka galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Simpan path gambar ke state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Bagian Foto Profil
            Center(
              child: Stack(
                children: [
                  // LOGIKA TAMPILAN GAMBAR:
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _selectedImage != null
                            ? FileImage(
                                _selectedImage!,
                              ) // Tampilkan foto dari galeri
                            : const NetworkImage(
                                    'https://i.pravatar.cc/150?img=12',
                                  )
                                  as ImageProvider, // Default
                      ),
                    ),
                  ),

                  // Tombol Kamera Kecil
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap:
                          _pickImage, // Panggil fungsi ambil gambar saat diklik
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Edit Data
            _buildEditField('Nama Lengkap', _nameController, Icons.person),
            const SizedBox(height: 16),
            _buildEditField('Username', _usernameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildEditField('ID Karyawan', _npmController, Icons.badge),
            const SizedBox(height: 16),
            _buildEditField('Email', _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildEditField('No. Telepon', _phoneController, Icons.phone_android_rounded),


            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Di sini nanti logika simpan ke Database/API
                  Navigator.pop(context, _selectedImage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SIMPAN PERUBAHAN',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[800]!, width: 2),
        ),
      ),
    );
  }
}
