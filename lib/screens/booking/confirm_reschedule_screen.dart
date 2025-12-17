import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan package ini sudah diinstall (Langkah 1)
import '../../services/booking_service.dart'; // Import Service
import 'reschedule_success_screen.dart'; // Lanjut ke halaman sukses

class ConfirmRescheduleScreen extends StatefulWidget {
  final String bookingId; // MENERIMA ID
  final String fieldId;
  final DateTime newDate;
  final String reason;

  const ConfirmRescheduleScreen({
    super.key, 
    required this.bookingId, // WAJIB DIISI
    required this.fieldId,
    required this.newDate, 
    required this.reason
  });

  @override
  State<ConfirmRescheduleScreen> createState() => _ConfirmRescheduleScreenState();
}

class _ConfirmRescheduleScreenState extends State<ConfirmRescheduleScreen> {
  bool _isLoading = false;
  final BookingService _bookingService = BookingService(); // Panggil Service
  final DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); 
  final String _selectedStartTime = "08:00"; 
  final String _selectedEndTime = "09:00";

  // Helper format tanggal (Sekarang pakai intl biar rapi)
  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      // HEADER
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_document, color: Color(0xFFFFC107), size: 20),
            SizedBox(width: 10),
            Text(
              "Konfirmasi Perubahan Jadwal",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU RINGKASAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  // Header Hitam
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: const Text("Bhaskara Futsal Arena", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  
                  // Isi
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Highlight Jadwal Baru (Kuning)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 40),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Jadwal Baru Anda:", style: TextStyle(fontSize: 12)),
                                  Text(
                                    _formatDate(widget.newDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const Text("Lapangan 2 | 10:00", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text("Alasan Anda:", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(widget.reason, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  // Total Biaya 0
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Biaya Perubahan"),
                        Text("Rp 0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      
      // TOMBOL KONFIRMASI (EKSEKUSI KE SUPABASE)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            
            // 1. PANGGIL SERVICE UNTUK UPDATE KE DATABASE
            bool success = await _bookingService.rescheduleBooking(
              bookingId: widget.bookingId,       // ID Booking
              fieldId: widget.fieldId,           // ID Lapangan (Pastiin variabelnya ada di widget ini)
              newDate: _selectedDate,             // Tanggal Baru yang dipilih
              newStartTime: _selectedStartTime,   // Jam Mulai Baru (Format "HH:mm", misal "18:00")
              newEndTime: _selectedEndTime,       // Jam Selesai Baru (Format "HH:mm", misal "19:00")
            );
            
            if (mounted) {
              setState(() => _isLoading = false);
              
              if (success) {
                // 2. JIKA SUKSES -> PINDAH KE HALAMAN SUKSES
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RescheduleSuccessScreen(
                      finalDate: widget.newDate,
                    ),
                  ),
                );
              } else {
                // 3. JIKA GAGAL -> MUNCUL PESAN MERAH
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal mengupdate jadwal. Cek koneksi internet."), backgroundColor: Colors.red)
                );
              }
            }
          },
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Konfirmasi Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}