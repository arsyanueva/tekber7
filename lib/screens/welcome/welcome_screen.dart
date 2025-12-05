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
        Navigator.pushNamed(context, AppRoutes.loginMethod); //// Perintah pindah ke halaman Login Method
      },
      child: Scaffold(
        // Container pembungkus utama
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            // BACKGROUND IMAGE
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.cover, // Full screen
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), // Center

              // Logo app
              Image.asset(
                'assets/images/logo_fm.png',
                width: 500,
              ),

              const SizedBox(height: 20),

              // SLOGAN TEXT
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Pesan lapangan sesuai\nkebutuhan menjadi lebih mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // tebel dikit lah ya
                  ),
                ),
              ),

              const Spacer(), // agak button (bawah)
            ],
          ),
        ),
      ),
    );
  }
}