import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/routes/app_routes.dart'; // Sesuaikan nama package

class TempLoadingScreen extends StatefulWidget {
  const TempLoadingScreen({super.key});

  @override
  State<TempLoadingScreen> createState() => _TempLoadingScreenState();
}

class _TempLoadingScreenState extends State<TempLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    final supabase = Supabase.instance.client;

    // 1. Cek sesi yang sudah ada
    if (supabase.auth.currentUser != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
      return;
    }

    // 2. Coba Login
    try {
      await supabase.auth.signInWithPassword(
        email: 'achavolunvibes@gmail.com', 
        password: 'acha123',
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      // 3. Tampilkan error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Sedang Login Otomatis...'),
          ],
        ),
      ),
    );
  }
}