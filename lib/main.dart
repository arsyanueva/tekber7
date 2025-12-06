import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import file-file aplikasi Field Master yang sudah kita buat
import 'routes/app_routes.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_method_screen.dart';
//import 'utils/app_colors.dart'; 

import 'models/booking_model.dart';
import 'screens/booking/booking_detail_screen.dart'; // Sesuaikan path-nya

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase dengan kredensial milikmu
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
      debugShowCheckedModeBanner: false, // Menghilangkan label 'Debug' di pojok kanan atas
      title: 'Field Master',
      
      // Mengatur tema dasar aplikasi
      theme: ThemeData(
        // Saya set warna dasar ke Kuning sesuai desainmu (dari AppColors.primaryYellow)
        // Pastikan AppColors sudah dibuat, atau bisa ganti manual jadi Color(0xFFFFD700)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700)),
        useMaterial3: true,
      ),

      // --- PENGATURAN NAVIGASI ---
      // Aplikasi akan mulai dari halaman Welcome
      initialRoute: AppRoutes.welcome,
      
      // Mendaftarkan halaman-halaman agar bisa dipanggil namanya
      routes: {
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.loginMethod: (context) => const LoginMethodScreen(),
      },
    );
  }
}