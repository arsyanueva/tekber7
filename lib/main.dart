import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // Biarkan ini (PENTING buat tanggal)
import 'routes/app_routes.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_method_screen.dart';
import 'screens/home/home_screen.dart';
// Import screen kamu sudah dihapus biar bersih

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NYALAKAN INI (Hapus tanda //) supaya tanggal Indonesia gak error
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

      // --- PENGATURAN NAVIGASI DIKEMBALIKAN ---
      initialRoute: AppRoutes.welcome, // Kembali ke Welcome Screen
      
      // Daftar page (Hapus rute test kamu)
      routes: {
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.loginMethod: (context) => const LoginMethodScreen(),
        AppRoutes.home: (context) => HomeScreen(),
      },
    );
  }
}