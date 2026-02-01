import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red[900]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Buat Akun Baru',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            Text(
              'Lengkapi data untuk akses gudang',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.red[300]),
            ),
            const SizedBox(height: 30),

            // Menggunakan Container sbg Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. Nama Lengkap
                    _buildInput(
                      label: 'Nama Lengkap',
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 16),

                    // 2. Username (Dipisah)
                    _buildInput(
                      label: 'Username',
                      icon: Icons.person_pin_outlined,
                    ),
                    const SizedBox(height: 16),

                    // 3. Email (Dipisah)
                    _buildInput(
                      label: 'Email',
                      icon: Icons.email_rounded,
                      keyboardType:
                          TextInputType.emailAddress, // Keyboard email
                    ),
                    const SizedBox(height: 16),

                    // 4. No. Telepon (Baru)
                    _buildInput(
                      label: 'No. Telepon',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone, // Keyboard angka
                    ),
                    const SizedBox(height: 16),

                    // 5. NPM / ID Karyawan (Baru)
                    _buildInput(
                      label: 'ID Karyawan',
                      icon: Icons.badge_rounded,
                      keyboardType: TextInputType.number, // Keyboard angka
                    ),
                    const SizedBox(height: 16),

                    // 5. Password
                    _buildInput(
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    // 6. Konfirmasi Password
                    _buildInput(
                      label: 'Konfirmasi Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Registrasi Berhasil! Silahkan Login',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'DAFTAR AKUN',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label tidak boleh kosong';
        return null;
      },
    );
  }
}
