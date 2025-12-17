import 'package:flutter/material.dart';
import 'package:tekber7/utils/app_colors.dart';

class LoginMethodScreen extends StatelessWidget {
  const LoginMethodScreen({super.key});

  void _goToIdentityInput(BuildContext context, String method) {
    Navigator.pushNamed(
      context,
      AppRoutes.identityInput,
      arguments: {
        'flowType': 'login',
        'method': method,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // 1. ILUSTRASI GAMBAR (Pemain Bola)
              Image.asset(
                'assets/images/loginmethod.png', 
                height: 250, 
              ),

              const SizedBox(height: 30),

              // 2. JUDUL BESAR
              const Text(
                'Selamat datang di Field Master!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2930), // Warna gelap text
                ),
              ),

              const SizedBox(height: 12),

              // 3. SUBTITLE
              const Text(
                'Pilih metode login untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // 4. TOMBOL DAFTAR DENGAN EMAIL (Ganti Handphone jadi Email)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Arahkan ke screen Register yang tadi kita buat
                    Navigator.pushNamed(context, '/role-selection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground, // Warna tombol hitam/gelap
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Daftar dengan Email", // Disesuaikan dengan backend
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. TOMBOL DAFTAR DENGAN GOOGLE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika Google Sign In (Nanti diimplementasikan)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Google Sign In Segera Hadir")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFEFEF), // Warna abu-abu muda
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Google (Pastikan punya iconnya, atau pakai Icon default sementara)
                      Image.asset('assets/images/google.png', height: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "Daftar dengan Google",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 6. TEKS LOGIN (Sudah punya akun? Masuk disini)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      // Arahkan ke screen Login yang tadi kita buat
                      Navigator.pushNamed(context, '/login-email');
                    },
                    child: const Text(
                      "Masuk disini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2930),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
