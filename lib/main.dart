import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import 'routes/app_routes.dart';
import 'models/booking_model.dart';
import 'screens/booking/booking_summary_screen.dart'; // File Ke-2

import 'package:tekber7/screens/password/change_password_screen.dart';
import 'package:tekber7/screens/profile/profile_screen.dart';

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

  runApp(const MyApp());
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

      // Mulai dari halaman Welcome (Punya teman)
      initialRoute: '/profile',
      
      // --- TEKNIK PENGGABUNGAN RUTE (FUSION!) ---
      routes: {
        // 1. Ambil semua rute punya temen (Welcome, Login, Home, dll)
        ...AppRoutes.getRoutes(),

        // 2. Tambahin rute "Jalur Tikus" punya Bara (buat testing Pembayaran)
        // '/test-payment': (context) => BookingSummaryScreen( // <--- PASTIKAN INI SUMMARY
        //  fieldName: "Lapangan 2 (Futsal)",
        //  draftBooking: BookingModel(
         //   id: 'test-123',
        //    fieldId: 'f1',
        //    renterId: 'r1',
        //    bookingDate: DateTime.now(),
        //    startTime: '18:00',
        //    endTime: '20:00',
        //    totalPrice: 250000,
        //    status: 'draft',
         // ),
        //),
        '/test-change-password': (context) => const ChangePasswordScreen(),
        
        '/profile': (context) => const ProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),

        '/reset-password': (context) => const ResetPasswordFlow(),
      },
    );
  }
}