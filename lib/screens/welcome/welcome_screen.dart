import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GestureDetector: Agar seluruh layar bisa diklik
    return GestureDetector(
      onTap: () {
        // Perintah pindah ke halaman Login Method
        Navigator.pushNamed(context, AppRoutes.loginMethod);
      },
      child: Scaffold(
        // Container pembungkus utama
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            // 1. SETTING BACKGROUND IMAGE
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.cover, // Gambar memenuhi layar
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), // Pendorong ke tengah

              // 2. LOGO IMAGE
              Image.asset(
                'assets/images/logo_fm.png',
                width: 180, // Sesuaikan ukuran logomu di sini
              ),

              const SizedBox(height: 20),

              // 3. SLOGAN TEXT
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Pesan lapangan sesuai\nkebutuhan menjadi lebih mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Agak tebal sedikit
                  ),
                ),
              ),

              const Spacer(), // Pendorong bawah agar seimbang
            ],
          ),
        ),
      ),
    );
  }
}