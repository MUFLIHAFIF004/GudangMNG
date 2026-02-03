import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_gudangmng/services/auth_service.dart';
import 'riwayat_screen.dart';
import 'login_screen.dart';
import 'list_barang.dart';
import 'edit_profile_screen.dart';
import 'input_barang_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'Admin Gudang';
  String? _base64Foto;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // PERBAIKAN UTAMA: Sinkronisasi Database
  Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  
  if (mounted) {
    setState(() {
      _username = prefs.getString('nama') ?? "Admin Gudang";
      _base64Foto = prefs.getString('foto');
    });
  }

  final profileFromServer = await AuthService().getUserProfile();
  
  if (profileFromServer != null) {
    if (mounted) {
      setState(() {
        _username = profileFromServer.nama;
        _base64Foto = profileFromServer.foto; 
      });
    }
    await prefs.setString('nama', profileFromServer.nama);
    await prefs.setString('username', profileFromServer.username);
    await prefs.setString('email', profileFromServer.email);
    await prefs.setString('id_karyawan', profileFromServer.idKaryawan);
    if (profileFromServer.foto != null) {
      await prefs.setString('foto', profileFromServer.foto!);
    }
  }
}

  // PERBAIKAN LOGOUT: Menjamin data bersih untuk akun selanjutnya
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Bersihkan cache lokal

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      extendBodyBehindAppBar: true,
      body: RefreshIndicator( // Tambahkan pull-to-refresh untuk manual sinkronisasi
        onRefresh: _loadUserData,
        color: Colors.red[800],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildAppDescription(),
                    const SizedBox(height: 30),
                    _buildQuickActions(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Tim Pengembang'),
                    const SizedBox(height: 10),
                    _buildTeamSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    ImageProvider currentImage;
    
    // PERBAIKAN LOGIKA FOTO: Utamakan Base64 dari database
    if (_base64Foto != null && _base64Foto!.isNotEmpty) {
      try {
        currentImage = MemoryImage(base64Decode(_base64Foto!));
      } catch (e) {
        currentImage = const NetworkImage('https://i.pravatar.cc/150?img=12');
      }
    } 
    else {
      currentImage = const NetworkImage('https://i.pravatar.cc/150?img=12');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard Admin',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _handleLogout,
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                  // Jika berhasil edit, result akan bernilai true dan kita load ulang
                  if (result == true) {
                    _loadUserData();
                  }
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: currentImage,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: GoogleFonts.poppins(color: Colors.red[100], fontSize: 14),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _username,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pendukung lainnya tetap menggunakan kode asli Anda
  Widget _buildTeamSection() {
    return Row(
      children: [
        Expanded(child: _buildTeamCard(name: 'Nesya Salma', npm: '714230028', role: 'Frontend', imageSource: 'assets/images/frontend-dev.jpg')),
        const SizedBox(width: 16),
        Expanded(child: _buildTeamCard(name: 'Mufhlih Afif', npm: '714230012', role: 'Backend', imageSource: 'assets/images/backend-dev.jpeg')),
      ],
    );
  }

  Widget _buildTeamCard({required String name, required String npm, required String role, required String imageSource}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30, 
            backgroundImage: AssetImage(imageSource)
          ),
          const SizedBox(height: 12),
          Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          Text(npm, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          Text(role, style: GoogleFonts.poppins(fontSize: 10, color: Colors.red[800])),
        ],
      ),
    );
  }

  Widget _buildAppDescription() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?fit=crop&w=800&q=80', height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Aplikasi ini dirancang untuk memudahkan pencatatan barang masuk dan keluar serta mengelola inventaris gudang dengan efisien.', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.justify),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCard(context, title: 'Barang Masuk', icon: Icons.login_rounded, color: Colors.green[700]!, isMasuk: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildActionCard(context, title: 'Barang Keluar', icon: Icons.logout_rounded, color: Colors.orange[800]!, isMasuk: false)),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionCardWide(context),
        const SizedBox(height: 16), 
        _buildRiwayatActionCard(context),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required bool isMasuk}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InputBarangScreen(isMasuk: isMasuk))),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Tap untuk input', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatActionCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatScreen()));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.history_rounded, color: Colors.blue[800], size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Riwayat Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Log aktivitas barang masuk dan keluar', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionCardWide(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ListBarangScreen())),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.inventory_2_rounded, color: Colors.red[800], size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data List Inventaris', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Lihat, filter, dan kelola semua stok barang', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]));
  }
}