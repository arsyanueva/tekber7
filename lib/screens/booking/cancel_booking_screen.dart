import 'package:flutter/material.dart';
// PENTING: Import halaman tujuan agar tidak error
import 'confirm_cancel_screen.dart'; 

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna sesuai desain
    final Color primaryBlack = const Color(0xFF1E1E1E); 
    final Color accentYellow = const Color(0xFFFFC107); 
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Abu-abu muda
      
      // HEADER (APPBAR)
      appBar: AppBar(
        backgroundColor: primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment, color: accentYellow, size: 20),
            const SizedBox(width: 10),
            const Text(
              "Batalkan Pesanan",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Data Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text("Ringkasan pesanan lapangan anda", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 15),
                  
                  // Detail Lapangan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sabtu, 15 Juni 2024", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Lapangan 2", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Pemesan
                  const Text("Pemesan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 20,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daniel", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("+62812345678", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Alasan
                  const Text("Alasan Pembatalan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    "Berikan alasan perubahan jadwal anda untuk evaluasi kami selanjutnya",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  
                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Masukkan alasan anda",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // TOMBOL NAVIGASI LANGSUNG KE HALAMAN KONFIRMASI
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // 1. Validasi dulu, alasan gak boleh kosong
              if (_reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Harap isi alasan pembatalan")),
                );
                return;
              }

              // 2. Langsung Pindah ke Halaman ConfirmCancelScreen
              // (Tidak pakai Pop-up lagi sesuai permintaan alur baru)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmCancelScreen(
                    reason: _reasonController.text, // Bawa teks alasannya
                  ),
                ),
              );
            },
            child: const Text(
              "Konfirmasi Pembatalan",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}