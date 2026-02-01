import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tb_gudangmng/services/auth_service.dart'; // Pastikan path import ini benar
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // ganti nama variabel controller agar lebih relevan, tapi fungsinya tetap sama
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Kirim text input (bisa email atau username) ke auth service
      final user = await _authService.login(
        _identifierController.text
            .trim(), // Trim untuk menghapus spasi tidak sengaja
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (user != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Berhasil!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: const Text('Akun tidak ditemukan atau Password salah'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Merah
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warehouse_rounded,
                  size: 64,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silahkan masuk untuk melanjutkan',
                style: GoogleFonts.poppins(color: Colors.red[300]),
              ),
              const SizedBox(height: 40),

              // Card Form
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
                      // INPUT EMAIL ATAU USERNAME
                      TextFormField(
                        controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email / Username', // Label diperbarui
                          prefixIcon: Icon(Icons.person),
                        ),
                        // VALIDASI GANDA (EMAIL ATAU USERNAME)
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email atau Username wajib diisi';
                          }

                          // 1. Cek Regex Email
                          // Format: text@text.domain
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          // 2. Cek Regex Username
                          // Format: Huruf, angka, titik, underscore, min 3 karakter, TANPA @
                          final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,}$');

                          // Logic: Jika TIDAK cocok email DAN TIDAK cocok username, maka Error
                          if (!emailRegex.hasMatch(value) &&
                              !usernameRegex.hasMatch(value)) {
                            return 'Masukkan format Email atau Username yang benar';
                          }

                          return null; // Valid
                        },
                      ),
                      const SizedBox(height: 20),

                      // INPUT PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) => value!.length < 6
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // TOMBOL LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'MASUK',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tambahan Navigasi ke Register (Optional jika ingin ditampilkan)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(color: Colors.red[300]),
                    children: [
                      TextSpan(
                        text: 'Daftar Sekarang',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
