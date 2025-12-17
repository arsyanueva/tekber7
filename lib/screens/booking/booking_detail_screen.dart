import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart'; // Gak pake 's'
import 'payment_success_screen.dart';
import 'payment_gateway_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;
  final String fieldName;
  final String selectedMethod; // <--- BARANG BARU DARI SEBELAH

  const BookingDetailScreen({
    super.key, 
    required this.booking,
    this.fieldName = "Bhaskara Futsal Arena",
    required this.selectedMethod, // <--- WAJIB DIISI
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  void _handlePaymentSimulation() {
    // Ambil info warna & logo lagi
    final info = _getPaymentInfo(); 
    
    // Pindah ke Halaman Gateway (PIN)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          booking: widget.booking,
          paymentMethod: widget.selectedMethod, // misal "E-Wallet Dana"
          imagePath: info['imagePath'],         // Logo Dana
          themeColor: info['color'] ?? Colors.blue, // Warna Biru Dana
        ),
      ),
    );
  }

  // --- HELPER LOGO & DATA DINAMIS (VERSION 2.0 LENGKAP) ---
  Map<String, dynamic> _getPaymentInfo() {
    String method = widget.selectedMethod;
    
    // Default Data
    String title = method;
    String account = "Menunggu Pembayaran...";
    String action = "Instruksi";
    String logoPath = "assets/images/bca.png"; // Default fallback
    Color color = Colors.blue;

    // LOGIC PEMETAAN ASSETS
    // Pastikan nama file di folder assets/images/ kamu sesuai ya!
    if (method.contains("BCA")) {
      logoPath = "assets/images/bca.png";
      account = "0812-3456-7890 (BCA)";
      action = "Salin No. Rekening";
    } else if (method.contains("BRI")) {
      logoPath = "assets/images/bri.png";
      account = "1234-5678-9000 (BRI)";
      action = "Salin No. BRIVA";
      color = Colors.blue.shade900;
    } else if (method.contains("Mandiri")) {
      logoPath = "assets/images/mandiri.png";
      account = "900-00-123123-4 (Mandiri)";
      color = Colors.indigo;
    } else if (method.contains("Jatim")) {
      logoPath = "assets/images/jatim.png";
      account = "001-234-567 (Jatim)";
      color = Colors.red;
    } else if (method.contains("Dana")) {
      logoPath = "assets/images/dana.png";
      account = "0812-3456-7890 (Bara)";
      action = "Buka Aplikasi Dana";
    } else if (method.contains("Gopay")) {
      logoPath = "assets/images/gopay.png";
      account = "0812-3456-7890 (Gopay)";
      action = "Buka Gojek";
    } else if (method.contains("OVO")) {
      logoPath = "assets/images/ovo.png";
      account = "0812-3456-7890 (OVO)";
      action = "Buka OVO";
      color = Colors.purple;
    } else if (method.contains("Shopee")) {
      logoPath = "assets/images/shopeepay.png";
      account = "0812-3456-7890 (Shopee)";
      action = "Buka Shopee";
      color = Colors.orange;
    } else if (method.contains("QRIS")) {
      logoPath = "assets/images/qris.png";
      title = "QRIS";
      account = "Scan QR Code di bawah";
      action = "Download QR";
      color = Colors.black;
    }

    // Return Data Lengkap termasuk Path Image
    return {
      "imagePath": logoPath, // Kita pake image sekarang, bukan icon
      "color": color, 
      "title": title,
      "account": account,
      "action": action
    };
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.booking.bookingDate);
    final paymentInfo = _getPaymentInfo(); // Ambil info dinamis

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
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                // Header & Subheader (Sama kayak sebelumnya)
                                Container(
                                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                                  color: primaryBlack,
                                  child: Text(widget.fieldName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Container(
                                  width: double.infinity, padding: const EdgeInsets.all(16), color: primaryYellow,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(children: [Icon(Icons.sports_soccer, size: 20), SizedBox(width: 8), Text('Lapangan 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                                      const SizedBox(height: 8),
                                      Text('$formattedDate | ${widget.booking.startTime}', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                
                                // --- INFO PEMBAYARAN DINAMIS ---
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // 1. Container Logo (Biar rapi ada kotaknya)
                                          Container(
                                            width: 50, 
                                            height: 35,
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white, 
                                              borderRadius: BorderRadius.circular(4), 
                                              border: Border.all(color: Colors.grey.shade200)
                                            ),
                                            // 2. Panggil Gambar dari Assets (imagePath dari _getPaymentInfo)
                                            child: Image.asset(
                                              paymentInfo['imagePath'], 
                                              fit: BoxFit.contain,
                                              // Jaga-jaga kalo gambar gak ketemu/error, pake icon bank default
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, color: Colors.blue, size: 20),
                                            ),
                                          ), 
                                          
                                          const SizedBox(width: 12), 
                                          
                                          // 3. Nama Metode Pembayaran
                                          Text(
                                            paymentInfo['title'], 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                          )
                                        ]
                                      ),
                                      const Divider(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text(paymentInfo['account'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                                          ]),
                                          TextButton(onPressed: (){}, child: Text(paymentInfo['action'], style: const TextStyle(color: Colors.blue, fontSize: 12)))
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
                
                // TOMBOL KONFIRMASI
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: _handlePaymentSimulation,
                      child: const Text('Saya Sudah Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}