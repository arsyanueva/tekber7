import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';
import 'package:tekber7/screens/booking/reschedule_success_screen.dart';

class ConfirmRescheduleScreen extends StatefulWidget {
  final BookingModel oldBooking; 
  final DateTime newDate;
  final String newStartTime; 
  final String newEndTime;   

  const ConfirmRescheduleScreen({
    super.key,
    required this.oldBooking,
    required this.newDate,
    required this.newStartTime,
    required this.newEndTime,
  });

  @override
  State<ConfirmRescheduleScreen> createState() => _ConfirmRescheduleScreenState();
}

class _ConfirmRescheduleScreenState extends State<ConfirmRescheduleScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  
  final Color _primaryDark = const Color(0xFF1E1E1E);   
  final Color _primaryYellow = const Color(0xFFFFC700); 

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.updateBookingSchedule(widget.oldBooking.id, widget.newDate, widget.newStartTime, widget.newEndTime);
      
      if (mounted) {
        // --- UPDATED: MENGIRIM DATA KE HALAMAN SUKSES ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RescheduleSuccessScreen(
              newDate: widget.newDate,          // Kirim Tanggal Baru
              newStartTime: widget.newStartTime, // Kirim Jam Mulai Baru
              newEndTime: widget.newEndTime,     // Kirim Jam Selesai Baru
            )
          )
        );
        // ------------------------------------------------
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _primaryDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: _primaryYellow), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: _primaryYellow, size: 24),
            const SizedBox(width: 8),
            Text('Konfirmasi Perubahan', style: TextStyle(color: _primaryYellow, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryYellow,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.oldBooking.fieldName ?? "Lapangan Futsal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.sports_soccer, size: 30),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Lapangan 2", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${_formatDate(widget.newDate)} | ${widget.newStartTime}", style: const TextStyle(fontSize: 12)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Tanggal Lama", _formatDate(widget.oldBooking.bookingDate)),
                    _buildDetailRow("Jam Lama", "${widget.oldBooking.startTime} - ${widget.oldBooking.endTime}"),
                    const SizedBox(height: 10),
                    _buildDetailRow("Tanggal Baru", _formatDate(widget.newDate), isNew: true),
                    _buildDetailRow("Jam Baru", "${widget.newStartTime} - ${widget.newEndTime}", isNew: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryDark, 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Konfirmasi Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isNew ? Colors.green[700] : Colors.black)),
      ]),
    );
  }
}