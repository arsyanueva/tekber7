import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- [PENTING] Import Paket Provider
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; 

// Import Provider kamu (Pastikan path folder-nya bener ya)
import 'package:tekber7/providers/review_provider.dart'; 

import 'routes/app_routes.dart';

import 'package:tekber7/screens/password/change_password_screen.dart';
import 'package:tekber7/screens/home/profile_screen.dart';
import 'package:tekber7/screens/home/change_profile_screen.dart';

import 'package:tekber7/screens/password/forget_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Format Tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://znbplgycjvlffahwehhz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuYnBsZ3ljanZsZmZhaHdlaGh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODAzNjQsImV4cCI6MjA3OTY1NjM2NH0.xXIlTmuxm6boAPsgJxK3xkrTsoYnkt3RCEbhkTrRAzM',
  );

  // --- [UPDATE] BUNGKUS APLIKASI DENGAN PROVIDER ---
  runApp(
    MultiProvider(
      providers: [
        // Daftarkan ReviewProvider di sini biar Global (Bisa diakses dari mana aja)
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Field Master',
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700)),
        useMaterial3: true,
      ),

      // --- PENGATURAN NAVIGASI ---
      // Mulai dari halaman Welcome (Punya teman)
      initialRoute: AppRoutes.welcome,
      
      // --- TEKNIK PENGGABUNGAN RUTE (FUSION!) ---
      routes: {
        // 1. Ambil semua rute punya temen (Welcome, Login, Home, dll)
        ...AppRoutes.getRoutes(),

        // Daftarkan TempLoadingScreen di sini sebagai route tambahan
        '/temp-login': (context) => const TempLoadingScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forget-password': (context) => const ResetPasswordFlow(),
        '/change-profile': (context) => const ChangeProfileScreen(),
      },
    );
  }
}