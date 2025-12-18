import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';
import 'payment_success_screen.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final BookingModel booking;
  final String paymentMethod;
  final String imagePath; 
  final Color themeColor; 

  const PaymentGatewayScreen({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.imagePath,
    this.themeColor = Colors.blue, 
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final TextEditingController _pinController = TextEditingController();
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  Future<void> _processPayment() async {
    if (_pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN harus 6 digit!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    try {
      await _bookingService.createBooking(widget.booking);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessScreen(booking: widget.booking)),
          (route) => false, 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red)
        );
      }
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
            
            const Text("Masukkan PIN Keamanan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: "••••••",
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor, 
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
