import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';

class RegisterMethodScreen extends StatelessWidget {
  const RegisterMethodScreen({super.key});

  void _goToOtp(BuildContext context, String method) {
    Navigator.pushNamed(
      context,
      AppRoutes.roleSelection,
      arguments: {
        'flowType': 'register',
        'method': method, // 'phone' | 'email'
      },
    );
  }

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

              // Ilustrasi
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.sports_soccer,
                  size: 100,
                  color: Colors.grey,
                ),
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
                'Pilih metode pendaftaran untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyText,
                ),
              ),

              const Spacer(),

              // REGISTER VIA PHONE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _goToOtp(context, 'phone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Daftar dengan nomor handphone',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // REGISTER VIA EMAIL
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _goToOtp(context, 'email'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkBackground),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Daftar dengan Gmail',
                    style: TextStyle(
                      color: AppColors.darkBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KE LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.loginMethod,
                  );
                },
                child: const Text(
                  'Sudah punya akun? Masuk di sini',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
