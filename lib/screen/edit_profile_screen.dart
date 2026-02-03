import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_gudangmng/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  int? _userId;
  String? _existingBase64;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _idKaryawanController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userId = prefs.getInt('id');
      _existingBase64 = prefs.getString('foto');
      _namaController.text = prefs.getString('nama') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _idKaryawanController.text = prefs.getString('id_karyawan') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _teleponController.text = prefs.getString('telepon') ?? '';
    });
  }

  // OPTIMASI: Proses simpan yang lebih cepat
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? base64ToSave = _existingBase64;

      // Jika ada gambar baru, proses konversi dilakukan hanya sekali
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64ToSave = base64Encode(bytes);
      }

      // Kirim ke server (Backend)
      bool success = await _authService.updateProfile(
        id: _userId ?? 0,
        nama: _namaController.text,
        username: _usernameController.text,
        email: _emailController.text,
        telepon: _teleponController.text,
        idKaryawan: _idKaryawanController.text,
        foto: base64ToSave,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        
        // Simpan ke SharedPreferences agar HomeScreen langsung update
        await prefs.setString('nama', _namaController.text);
        await prefs.setString('username', _usernameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('telepon', _teleponController.text);
        await prefs.setString('id_karyawan', _idKaryawanController.text);
        await prefs.setString('foto', base64ToSave ?? "");

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );

        // BALIKAN TRUE: Memberitahu HomeScreen untuk refresh UI secara instan
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui ke server!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // OPTIMASI: Kompresi Gambar saat memilih file
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Gunakan imageQuality (1-100) untuk mempercepat upload & mengurangi beban memori
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // Kompresi hingga 35% agar Base64 tidak terlalu panjang
      maxWidth: 500,    // Batasi lebar gambar agar tidak terlalu besar di DB
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Fungsi build UI Anda tetap sama, sudah cukup bagus)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profil', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.red))
      : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 30),
              _buildEditField(label: 'Nama Lengkap', controller: _namaController, icon: Icons.person),
              const SizedBox(height: 16),
              _buildEditField(label: 'Username', controller: _usernameController, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditField(label: 'ID Karyawan', controller: _idKaryawanController, icon: Icons.badge, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildEditField(label: 'Email', controller: _emailController, icon: Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildEditField(label: 'No. Telepon', controller: _teleponController, icon: Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Widget _buildAvatarSection, _buildEditField, _buildSaveButton tetap sama)
  Widget _buildAvatarSection() {
    ImageProvider avatarImage;
    if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!);
    } else if (_existingBase64 != null && _existingBase64!.isNotEmpty) {
      avatarImage = MemoryImage(base64Decode(_existingBase64!));
    } else {
      avatarImage = const NetworkImage('https://i.pravatar.cc/150?img=12');
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red[100]!, width: 2),
              image: DecorationImage(fit: BoxFit.cover, image: avatarImage),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundColor: Colors.red[800],
                radius: 18,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({required String label, required TextEditingController controller, required IconData icon, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('SIMPAN PERUBAHAN', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}