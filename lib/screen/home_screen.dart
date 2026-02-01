import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'input_barang_screen.dart'; // Pastikan file ini di-import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
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

                  const SizedBox(height: 20), // Spasi bawah tambahan
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BARU: AKSI CEPAT ---
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        // Tombol Barang Masuk
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Barang Masuk',
            icon: Icons.login_rounded,
            color: Colors.orange[800]!, // Merah Gelap
            isMasuk: true,
          ),
        ),
        const SizedBox(width: 16),
        // Tombol Barang Keluar
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Barang Keluar',
            icon: Icons.logout_rounded,
            color: Colors.orange[800]!, // Orange biar beda dikit tapi senada
            isMasuk: false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isMasuk,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.red.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputBarangScreen(isMasuk: isMasuk),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Tap untuk input',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[500],
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
    if (_profileImage != null) {
      currentImage = FileImage(_profileImage!);
    } else {
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
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
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
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result != null && result is File) {
                    setState(() {
                      _profileImage = result;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red[100],
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
                      style: GoogleFonts.poppins(
                        color: Colors.red[100],
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Admin Gudang',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (result != null && result is File) {
                              setState(() {
                                _profileImage = result;
                              });
                            }
                          },
                          tooltip: 'Edit Profil',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red[900],
      ),
    );
  }

  Widget _buildAppDescription() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warehouse Management System',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi ini dirancang untuk memudahkan pencatatan barang masuk dan keluar serta mengelola inventaris gudang dengan efisien.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.red[100]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.red[800]),
                    const SizedBox(width: 8),
                    Text(
                      'Manajemen Stok',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.check_circle, size: 16, color: Colors.red[800]),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Pengelolaan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTeamCard(
            name: 'Nesya Salma Ramadhani',
            npm: '714230028',
            role: 'Frontend Developer',
            imageSource: 'assets/images/frontend-dev.jpg',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTeamCard(
            name: 'Muhammad Mufhlih Afif',
            npm: '714230012',
            role: 'Backend Developer',
            imageSource: 'assets/images/backend-dev.jpeg',
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required String name,
    required String npm,
    required String role,
    required String imageSource,
  }) {
    ImageProvider imageProvider;
    if (imageSource.startsWith('http')) {
      imageProvider = NetworkImage(imageSource);
    } else {
      imageProvider = AssetImage(imageSource);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red[200]!, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red[50],
              backgroundImage: imageProvider,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.red[900],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            npm,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }
}
