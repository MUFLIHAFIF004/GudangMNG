import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tb_gudangmng/screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Gudang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red[800]!, 
          secondary: Colors.redAccent,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade800, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
          prefixIconColor: Colors.red[800],
        ),
      ),
      home: const LoginScreen(),
    );
  }
}