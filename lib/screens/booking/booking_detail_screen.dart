import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/routes/app_routes.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;
  final String fieldName;
  final String selectedMethod;

  const BookingDetailScreen({
    super.key, 
    required this.booking,
    this.fieldName = "Lapangan Futsal",
    required this.selectedMethod,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final Color _primaryDark = const Color(0xFF1E1E1E);   
  final Color _primaryYellow = const Color(0xFFFFC700); 

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DINAMIS STATUS ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(
      widget.booking.bookingDate.year, 
      widget.booking.bookingDate.month, 
      widget.booking.bookingDate.day
    );

    String displayStatus = widget.booking.status;
    bool isActuallyPast = bookingDay.isBefore(today);

    // Jika sudah lewat hari dan status masih confirmed, anggap COMPLETED
    if (isActuallyPast && widget.booking.status == 'confirmed') {
      displayStatus = 'completed';
    }

    // Tombol aktif hanya jika belum lewat tanggalnya DAN statusnya belum cancelled/completed
    bool isActive = (widget.booking.status == 'confirmed' || widget.booking.status == 'pending') && !isActuallyPast;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: _primaryDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: _primaryYellow, size: 24),
            const SizedBox(width: 8),
            Text(
              "Detail Pesanan", 
              style: TextStyle(color: _primaryYellow, fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.booking.fieldName ?? widget.fieldName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text("Lapangan 2 (Rumput Sintetis)", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const Divider(height: 30),
                  _buildDetailRow(Icons.calendar_today, "Tanggal", _formatDate(widget.booking.bookingDate)),
                  const SizedBox(height: 15),
                  _buildDetailRow(Icons.access_time, "Jam", "${widget.booking.startTime} - ${widget.booking.endTime}"),
                  const SizedBox(height: 15),
                  _buildDetailRow(Icons.confirmation_number, "ID Booking", "#${widget.booking.id.substring(0, 8)}"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status", style: TextStyle(color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          displayStatus.toUpperCase(), 
                          style: TextStyle(color: _getStatusColor(displayStatus), fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Bayar", style: TextStyle(color: Colors.grey)),
                      Text(_formatCurrency(widget.booking.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tombol hanya muncul jika pesanan masih aktif (belum lewat tanggalnya)
      bottomNavigationBar: isActive ? Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.rescheduleBooking, arguments: widget.booking),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryYellow, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Ubah Jadwal", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () {
                   Navigator.pushNamed(context, AppRoutes.cancelBooking, arguments: widget.booking);
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Batalkan Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ) : null,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.grey)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }

  Color _getStatusColor(String status) {
    if (status == 'confirmed') return Colors.green;
    if (status == 'pending') return Colors.orange;
    if (status == 'cancelled') return Colors.red;
    if (status == 'completed') return Colors.blue;
    return Colors.blue;
  }
}