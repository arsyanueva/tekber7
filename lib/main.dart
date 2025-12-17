import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tekber7/providers/review_provider.dart';
import 'routes/app_routes.dart';
import 'screens/temp_loading_screen.dart';
import 'models/booking_model.dart';
import 'screens/booking/booking_summary_screen.dart';
import 'package:tekber7/screens/password/change_password_screen.dart';
import 'package:tekber7/screens/home/profile_screen.dart';
import 'package:tekber7/screens/home/change_profile_screen.dart';
import 'package:tekber7/screens/password/forget_password_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_method_screen.dart';
import 'screens/home/home_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://znbplgycjvlffahwehhz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuYnBsZ3ljanZsZmZhaHdlaGh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODAzNjQsImV4cCI6MjA3OTY1NjM2NH0.xXIlTmuxm6boAPsgJxK3xkrTsoYnkt3RCEbhkTrRAzM',
  );

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

      initialRoute: '/',
      
      routes: {
        ...AppRoutes.getRoutes(),

        // 2. Rute Tambahan dari Main (Tetap dipertahankan)
        '/temp-login': (context) => const TempLoadingScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forget-password': (context) => const ResetPasswordFlow(),
        '/change-profile': (context) => const ChangeProfileScreen(),
      },
    );
  }
}