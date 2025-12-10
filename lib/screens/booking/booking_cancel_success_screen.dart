import 'package:flutter/material.dart';

class BookingCancelSuccessScreen extends StatelessWidget {
  const BookingCancelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Putih Bersih
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(), // Dorong konten ke tengah
            
            // 1. IKON CENTANG BESAR
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E), // Warna Hitam/Gelap
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 2. TEKS JUDUL
            const Text(
              "Pesanan Berhasil\nDibatalkan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const Spacer(), // Dorong tombol ke bawah

            // 3. TOMBOL KEMBALI (KUNING)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107), // Kuning
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Kembali ke halaman Home (Hapus semua history navigasi biar gak bisa back)
                  // Asumsi nama route home kamu '/home' atau gunakan AppRoutes.home nanti
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  "Kembali ke Halaman Utama",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}