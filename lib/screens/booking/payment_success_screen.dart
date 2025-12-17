import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final BookingModel booking;
  const PaymentSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Format Tanggal & Duit
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(booking.bookingDate);
    final String formattedPrice = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(booking.totalPrice);
    
    const Color primaryBlack = Color(0xFF1E1E1E);
    const Color primaryYellow = Color(0xFFFFD700);
    // const Color bgGrey = Color(0xFFF5F5F5); // Unused, boleh dihapus

    return Scaffold(
      backgroundColor: primaryBlack,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        elevation: 0,
        centerTitle: true,
        title: const Text("Pembayaran Berhasil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              // Card Putih Besar Rounded Top
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    // Icon Centang Kuning
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryYellow, width: 3)),
                      child: const Icon(Icons.check, color: primaryYellow, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text("Penyewaan Lapangan Berhasil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    
                    // Detail Sewa
                    const Align(alignment: Alignment.centerLeft, child: Text("Data Sewa Lapangan :", style: TextStyle(fontSize: 14, color: Colors.grey))),
                    const SizedBox(height: 15),
                    _buildDetailRow("Tanggal", formattedDate),
                    _buildDetailRow("Waktu", "${booking.startTime} - ${booking.endTime}"),
                    _buildDetailRow("Nomor Lapangan", "2"), // Hardcode sementara (nanti ambil dari API lapangan)
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                    
                    // [UPDATE] Ambil Metode Pembayaran dari Booking Model biar Dinamis
                    _buildDetailRow(
                      "Metode Pembayaran", 
                      booking.paymentMethod ?? "Transfer Bank", // Fallback kalau null
                      valueBold: true
                    ),
                    const SizedBox(height: 20),

                    // Total Biaya Highlight Kuning
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(color: primaryYellow.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Biaya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tombol Kembali (Putih/Outlined)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryBlack),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                // --- [FIX: LOGIC TOMBOL KEMBALI] ---
                onPressed: () {
                   // Hapus semua history page sebelumnya & balik ke Home
                   // Pastikan di main.dart rutenya '/home' ya!
                   Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: const Text("Kembali", style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: valueBold ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}