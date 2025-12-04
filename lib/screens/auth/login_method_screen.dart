import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class LoginMethodScreen extends StatelessWidget {
  const LoginMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Tempat Ilustrasi (Orang main bola)
              // Nanti ganti Icon ini dengan Image.asset('assets/images/illustration.png')
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Icon(Icons.sports_soccer, size: 100, color: Colors.grey), 
              ),
              
              const SizedBox(height: 30),

              const Text(
                'Selamat datang di Field Master!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBackground,
                ),
              ),
              
              const SizedBox(height: 10),

              const Text(
                'Pilih dan pesan lapangan olahraga sesuai kebutuhan kamu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyText,
                ),
              ),

              const Spacer(), // Dorong tombol ke bawah

              // Tombol Masuk HP
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Nanti arahkan ke form login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Masuk dengan nomor handphone',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              // ... Kode tombol Google bisa ditambahkan disini nanti
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}