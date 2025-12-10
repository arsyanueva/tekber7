import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Butuh ini buat format tanggal
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';
import 'payment_success_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;
  // Nanti nama lapangan dilempar dari halaman sebelumnya, sementara hardcode dulu
  final String fieldName; 

  const BookingDetailScreen({
    super.key, 
    required this.booking,
    this.fieldName = "Bhaskara Futsal Arena", // Default
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  // --- LOGIC SIMULASI BAYAR ---
  Future<void> _handlePaymentSimulation() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Pura-pura loading
    try {
      // Panggil service mock payment
      await _bookingService.confirmPaymentMock(widget.booking.id);
      if (mounted) {
        // Pindah ke halaman sukses
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessScreen(booking: widget.booking)),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format Tanggal Indonesia: "Sabtu, 15 Juni 2024"
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.booking.bookingDate);

    const Color primaryBlack = Color(0xFF1E1E1E);
    const Color primaryYellow = Color(0xFFFFD700);
    const Color bgGrey = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: primaryBlack,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        iconTheme: const IconThemeData(color: primaryYellow),
        title: const Text('Konfirmasi Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryYellow))
          : Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(color: bgGrey, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // --- CARD DETAIL (SESUAI DESAIN) ---
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            clipBehavior: Clip.antiAlias, // Biar child gak keluar border radius
                            child: Column(
                              children: [
                                // 1. Header Hitam (Nama Tempat)
                                Container(
                                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                                  color: primaryBlack,
                                  child: Text(widget.fieldName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                // 2. Subheader Kuning (Detail Lapangan)
                                Container(
                                  width: double.infinity, padding: const EdgeInsets.all(16), color: primaryYellow,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sports_soccer, size: 20), // Ganti icon lapangan
                                          SizedBox(width: 8),
                                          Text('Lapangan 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('$formattedDate | ${widget.booking.startTime}', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                // 3. Body Putih (Info Bank)
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Placeholder Logo BCA & Teks
                                          const Row(children: [Icon(Icons.account_balance, color: Colors.blue), SizedBox(width: 8), Text('BCA Transfer BCA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                                          // Tombol Ubah Kuning Kecil
                                          SizedBox(height: 28, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryYellow, padding: const EdgeInsets.symmetric(horizontal: 12), elevation: 0), onPressed: (){}, child: const Text("Ubah", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))))
                                        ],
                                      ),
                                      const Divider(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('0812345678910 a.n. FieldMaster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
                                          TextButton(onPressed: (){}, child: const Text('Lihat QR Code', style: TextStyle(color: Colors.blue, fontSize: 12)))
                                        ],
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
                  ),
                ),
                
                // --- BOTTOM SECTION (Timer + Button) ---
                Container(color: bgGrey, child: Column(children: [
                  // Countdown Timer Bar (Hardcoded sesuai desain)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    color: primaryYellow.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [Icon(Icons.access_time, size: 18), SizedBox(width: 8), Text('Lakukan pembayaran dalam', style: TextStyle(fontSize: 13))]),
                        // Kotak Waktu Dummy
                        Row(children: [
                          _buildTimeBox("01"), const Text(" : "), _buildTimeBox("23"), const Text(" : "), _buildTimeBox("45"),
                        ])
                      ],
                    ),
                  ),
                  // Tombol Konfirmasi
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: _handlePaymentSimulation,
                        child: const Text('Konfirmasi Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ])),
              ],
            ),
    );
  }

  // Widget kecil buat kotak timer
  Widget _buildTimeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(4)),
      child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}