// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/services/auth_service.dart';
import 'package:tekber7/utils/app_colors.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // 1. Proses Login ke Supabase Auth
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Ambil Data Profile untuk Cek Role
      final userProfile = await _authService.getUserProfile();
      
      // Ambil role, default ke 'renter' jika null
      final role = userProfile?['role'] ?? 'renter'; 

      if (mounted) {
        // 3. Navigasi Berdasarkan Role
        if (role == 'owner') {
          // Jika Owner, ke Home Owner
          Navigator.pushNamedAndRemoveUntil(context, '/home-owner', (route) => false);
        } else {
          // Jika Renter (atau lainnya), ke Home Biasa
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Gagal, periksa koneksi anda"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan Email dan Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Input Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "cth: yuksehat@email.com",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Input Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                hintText: "**********",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                   // Pastikan route '/forget-password' sudah ada atau hapus baris ini jika belum
                   Navigator.pushNamed(context, '/forget-password');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Lupa Password?", style: TextStyle(color: Colors.grey)),
              ),
            ),

            const Spacer(),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBackground,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading 
                   ? const CircularProgressIndicator(color: Colors.white)
                   : const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}