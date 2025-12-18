import 'package:flutter/material.dart';
import 'package:tekber7/routes/app_routes.dart'; // Import AppRoutes

class BookingCancelSuccessScreen extends StatelessWidget {
  const BookingCancelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Centang Hitam sesuai Figma
              const Icon(Icons.check_circle, size: 120, color: Color(0xFF1E1E1E)),
              const SizedBox(height: 30),
              const Text(
                "Pesanan Berhasil\nDibatalkan", 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC700),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // PERBAIKAN NAVIGASI: Menghapus semua stack dan kembali ke Home
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.home, 
                    (route) => false
                  ),
                  child: const Text(
                    "Kembali ke Halaman Utama", 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}