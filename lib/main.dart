import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_method_screen.dart';
import 'screens/home/home_screen.dart';
//import 'utils/app_colors.dart'; 

// --- IMPORT UNTUK TESTING FITUR BARA ---
import 'models/booking_model.dart';
import 'screens/booking/booking_detail_screen.dart'; // Sesuaikan folder kalau beda

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // Aplikasi akan mulai dari laman mana yang diinginkan
      // Kita balikin ke normal (Welcome), biar temenmu gak bingung
      initialRoute: AppRoutes.welcome,
      
      // Daftar page untuk dipanggil namanya
      routes: {
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.loginMethod: (context) => const LoginMethodScreen(),
        AppRoutes.home: (context) => HomeScreen(),

        // --- JALUR TIKUS (TESTING BARA) ---
        // Cara akses: Ubah URL di browser jadi .../#/test-payment
        '/test-payment': (context) => BookingDetailScreen(
          booking: BookingModel(
            id: 'test-booking-123',
            fieldId: 'field-001',
            renterId: 'renter-001',
            bookingDate: DateTime.now(), // Tanggal hari ini
            startTime: '18:00',
            endTime: '20:00',
            totalPrice: 250000,
            status: 'pending', // Status pending biar tombol bayar muncul
          ),
        ),
      },
    );
  }
}