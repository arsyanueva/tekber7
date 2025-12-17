import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tetap ada buat tanggal
import 'routes/app_routes.dart';
<<<<<<< Updated upstream

// Import screen tidak perlu ditulis disini lagi karena sudah diurus oleh app_routes.dart
=======
import 'screens/temp_loading_screen.dart'; 
import 'models/booking_model.dart';
import 'screens/booking/booking_summary_screen.dart'; // File Ke-2

import 'package:tekber7/screens/password/change_password_screen.dart';
import 'package:tekber7/screens/home/profile_screen.dart';

import 'package:tekber7/screens/password/forget_password_screen.dart';
>>>>>>> Stashed changes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Format Tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://znbplgycjvlffahwehhz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuYnBsZ3ljanZsZmZhaHdlaGh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODAzNjQsImV4cCI6MjA3OTY1NjM2NH0.xXIlTmuxm6boAPsgJxK3xkrTsoYnkt3RCEbhkTrRAzM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Field Master',
      
      // Tema dasar aplikasi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700)),
        useMaterial3: true,
      ),

      // --- PENGATURAN NAVIGASI ---
      // Mulai dari halaman Welcome (Punya teman)
      initialRoute: AppRoutes.welcome,
      
<<<<<<< Updated upstream
      // Ambil daftar rute dari file app_routes.dart yang baru kita perbaiki
      routes: AppRoutes.getRoutes(),
=======
      // --- TEKNIK PENGGABUNGAN RUTE (FUSION!) ---
      routes: {
        // 1. Ambil semua rute punya temen (Welcome, Login, Home, dll)
        ...AppRoutes.getRoutes(),

        // Daftarkan TempLoadingScreen di sini sebagai route tambahan
        '/temp-login': (context) => const TempLoadingScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forget-password': (context) => const ResetPasswordFlow(),
      },
>>>>>>> Stashed changes
    );
  }
}