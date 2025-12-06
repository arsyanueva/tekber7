import 'package:flutter/material.dart';

class RescheduleSuccessScreen extends StatelessWidget {
  // Terima data tanggal dari halaman sebelumnya
  final DateTime finalDate; 
  
  const RescheduleSuccessScreen({super.key, required this.finalDate});

  // Helper format tanggal
  String _formatDate(DateTime date) {
    List<String> months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    // Contoh: Minggu, 16 Juni 2023
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header Hitam seperti di Figma
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        automaticallyImplyLeading: false, // Hilangkan tombol back
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 20),
            SizedBox(width: 10),
            Text(
              "Perubahan Jadwal Berhasil", 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            
            // 1. Ikon Centang Kuning
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.transparent, // Transparan karena iconnya udah bulat
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 80),
            ),
            
            const SizedBox(height: 20),
            
            // 2. Judul
            const Text(
              "Perubahan Jadwal\nPenyewaan Lapangan Berhasil",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 30),
            
            // 3. DETAIL DATA (Sesuai Figma)
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data Sewa Lapangan :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  
                  // Baris Tanggal
                  _buildDetailRow("Tanggal", _formatDate(finalDate)),
                  const SizedBox(height: 10),
                  // Baris Waktu
                  _buildDetailRow("Waktu", "10.00"), // Hardcode sementara
                  const SizedBox(height: 10),
                  // Baris Nomor Lapangan
                  _buildDetailRow("Nomor Lapangan", "2"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 4. KOTAK BIAYA KUNING
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.6), // Kuning agak transparan dikit sesuai figma
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Biaya", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Spacer(),
            
            // 5. TOMBOL KEMBALI
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Balik ke Home
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Kembali", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk baris detail (Kiri Label, Kanan Value)
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}