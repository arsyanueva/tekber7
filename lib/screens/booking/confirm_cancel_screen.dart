import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/utils/refund_helper.dart';
import 'package:tekber7/services/booking_service.dart';
import 'package:tekber7/routes/app_routes.dart';

class ConfirmCancelScreen extends StatefulWidget {
  final BookingModel booking;
  final String reason;

  const ConfirmCancelScreen({super.key, required this.booking, required this.reason});

  @override
  State<ConfirmCancelScreen> createState() => _ConfirmCancelScreenState();
}

class _ConfirmCancelScreenState extends State<ConfirmCancelScreen> {
  bool _isLoading = false;

  String _getPolicyStatus(int percentage) {
    if (percentage == 100) return "Refund Penuh";
    if (percentage > 0) return "Refund Sebagian";
    return "Tidak Ada Refund";
  }

  @override
  Widget build(BuildContext context) {
    final refund = RefundHelper.calculate(widget.booking.bookingDate, widget.booking.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), 
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_problem_rounded, color: Color(0xFFFFC700), size: 24),
            SizedBox(width: 8),
            Text(
              "Konfirmasi Pembatalan", 
              style: TextStyle(color: Color(0xFFFFC700), fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFFFC700)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_soccer, size: 40, color: Colors.black),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.booking.fieldName ?? "Baskhara Futsal Arena", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Lapangan 2", style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13)),
                          Text("${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.booking.bookingDate)} | ${widget.booking.startTime}", 
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Alasan Pembatalan:", style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  widget.reason, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade100, width: 2),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text("Informasi Pengembalian Dana", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const Divider(height: 25),
                  _refundRow("Status Kebijakan", _getPolicyStatus(refund.refundPercentage)),
                  _refundRow("Persentase Kembali", "${refund.refundPercentage}%", valueColor: Colors.blue),
                  const Divider(),
                  _refundRow("Total Dana Kembali", "Rp ${refund.refundAmount.toInt()}", isBold: true, isTotal: true),
                  const SizedBox(height: 10),
                  Text(refund.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            try {
              await BookingService().cancelBooking(
                bookingId: widget.booking.id,
                reason: widget.reason,
                refundAmount: refund.refundAmount,
              );
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.cancelSuccess, (route) => false);
            } catch (e) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
            }
          },
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Konfirmasi Pembatalan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _refundRow(String label, String value, {bool isBold = false, bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: isTotal ? 18 : 14, 
            color: isTotal ? Colors.green[700] : (valueColor ?? Colors.black)
          )),
        ],
      ),
    );
  }
}