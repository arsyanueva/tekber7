import 'package:flutter/material.dart';
import 'booking_cancel_success_screen.dart';

class ConfirmCancelScreen extends StatefulWidget {
  final String reason; // Menerima data alasan dari halaman sebelumnya

  const ConfirmCancelScreen({super.key, required this.reason});

  @override
  State<ConfirmCancelScreen> createState() => _ConfirmCancelScreenState();
}

class _ConfirmCancelScreenState extends State<ConfirmCancelScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Konfirmasi Pembatalan Pesanan",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU DETAIL (Hitam Header + Putih Body)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  // Header Kartu (Hitam)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Bhaskara Futsal Arena", // Nama Tempat Dummy
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // Isi Kartu
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kotak Kuning (Info Lapangan)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107), // Kuning
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sports_soccer, size: 40),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Lapangan 2", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Sabtu, 15 Juni 2024 | 18:00"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Alasan user
                        const Text("Alasan Anda:", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(
                          widget.reason, // Menampilkan alasan yang diketik tadi
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // TOMBOL KONFIRMASI FINAL
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E), // Hitam
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            
            // Simulasi Loading ke Database
            await Future.delayed(const Duration(seconds: 2));
            
            if (mounted) {
              setState(() => _isLoading = false);
              // Pindah ke Halaman Sukses
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookingCancelSuccessScreen()),
              );
            }
          },
          child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Konfirmasi Pembatalan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}