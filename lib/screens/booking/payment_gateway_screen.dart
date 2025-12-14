import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';
import 'payment_success_screen.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final BookingModel booking;
  final String paymentMethod;
  final String imagePath; // Logo yang dikirim dari halaman sebelumnya
  final Color themeColor; // Warna tema (misal Dana=Biru, OVO=Ungu)

  const PaymentGatewayScreen({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.imagePath,
    this.themeColor = Colors.blue, // Default
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final TextEditingController _pinController = TextEditingController();
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  Future<void> _processPayment() async {
    // Validasi PIN (Dummy aja, asal gak kosong)
    if (_pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN harus 6 digit!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi Koneksi ke Bank...
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Panggil Service Update Database
      await _bookingService.confirmPaymentMock(widget.booking.id, widget.paymentMethod);

      if (mounted) {
        // Redirect ke Success Screen (Hapus history biar gak bisa back ke PIN)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessScreen(booking: widget.booking)),
          (route) => false, // Hapus semua rute sebelumnya (Clean Slate)
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.booking.totalPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.paymentMethod, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo Pembayaran Besar
            Container(
              width: 100, height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200)
              ),
              child: Image.asset(widget.imagePath, fit: BoxFit.contain),
            ),
            
            const SizedBox(height: 30),
            Text("Total Pembayaran", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 10),
            Text(formattedPrice, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: widget.themeColor)),

            const SizedBox(height: 50),
            
            // Input PIN
            const Text("Masukkan PIN Keamanan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true, // Biar jadi bintang-bintang ******
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "", // Ilangin counter 0/6
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: "••••••",
              ),
            ),

            const Spacer(),

            // Tombol Bayar
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor, // Warna tombol ngikutin brand (Dana=Biru, OVO=Ungu)
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}