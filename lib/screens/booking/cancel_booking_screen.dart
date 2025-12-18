import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/routes/app_routes.dart';

class CancelBookingScreen extends StatefulWidget {
  final BookingModel booking;
  const CancelBookingScreen({super.key, required this.booking});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFFFFC700), size: 24),
            SizedBox(width: 8),
            Text(
              "Batalkan Pesanan", 
              style: TextStyle(color: Color(0xFFFFC700), fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoBox("Tanggal", DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.booking.bookingDate)),
            _infoBox("Lapangan", widget.booking.fieldName ?? "Lapangan Futsal"),
            const SizedBox(height: 24),
            const Text("Alasan Pembatalan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Masukkan alasan pembatalan anda",
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E), 
            minimumSize: const Size(double.infinity, 50), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          onPressed: () {
            if (_reasonController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alasan wajib diisi")));
              return;
            }
            Navigator.pushNamed(context, AppRoutes.confirmCancel, arguments: {
              'booking': widget.booking,
              'reason': _reasonController.text,
            });
          },
          child: const Text("Lanjut ke Konfirmasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}