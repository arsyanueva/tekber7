import 'package:flutter/material.dart';
import '../../services/booking_service.dart'; 
import 'confirm_reschedule_screen.dart'; 

class RescheduleBookingScreen extends StatefulWidget {
  const RescheduleBookingScreen({super.key});

  @override
  State<RescheduleBookingScreen> createState() => _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final BookingService _bookingService = BookingService();
  
  bool _isLoadingData = true; 
  Map<String, dynamic>? _bookingData; 
  DateTime? _selectedDate; 
  String? _realBookingId; // Menyimpan ID asli dari database

  @override
  void initState() {
    super.initState();
    _loadBookingData(); // Mulai cari data
  }

  // --- LOGIC PINTAR: CARI DATA SENDIRI ---
  Future<void> _loadBookingData() async {
    // 1. Cari ID dulu
    String? id = await _bookingService.getFirstBookingId();
    
    if (id == null) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data Kosong! Isi tabel bookings di Supabase dulu."))
        );
      }
      return;
    }

    // 2. Kalau ketemu ID-nya, tarik detail lengkapnya
    _realBookingId = id; // Simpan ID buat dipake nanti pas update
    final data = await _bookingService.getBookingDetail(id);
    
    if (mounted) {
      setState(() {
        _bookingData = data;
        _isLoadingData = false;
      });
    }
  }

  // Fungsi Kalender
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1E1E),
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Helper Format Tanggal
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      // Format manual: 15 Juni 2024
      List<String> months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateObj(DateTime date) {
     List<String> months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
     return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: const BackButton(color: Color(0xFFFFC107)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_calendar, color: Color(0xFFFFC107), size: 20),
            SizedBox(width: 10),
            Text("Ubah Jadwal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      
      // BODY: Loading State
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator()) 
        : _bookingData == null 
            ? const Center(child: Text("Data booking tidak ditemukan di database")) 
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Data Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text("Ringkasan pesanan lapangan anda", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 15),
                          
                          // KOTAK TANGGAL
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedDate == null 
                                          ? _formatDate(_bookingData!['booking_date']) // Dari DB
                                          : _formatDateObj(_selectedDate!), // Pilihan Baru
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _selectedDate == null ? Colors.black : Colors.green[700]
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _bookingData!['fields'] != null ? _bookingData!['fields']['name'] : "Lapangan", 
                                        style: const TextStyle(fontSize: 12, color: Colors.grey)
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC107),
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () => _selectDate(context),
                                    child: const Text("Ubah", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),

                          const Text("Pemesan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bookingData!['users'] != null ? _bookingData!['users']['name'] : "User",
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _bookingData!['users'] != null ? _bookingData!['users']['phone_number'] : "-",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),

                          const Text("Alasan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Masukkan alasan anda",
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (_selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan klik tombol Ubah (Kuning) untuk memilih tanggal baru!"), backgroundColor: Colors.red));
                return;
              }
              
              if (_reasonController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi alasan dulu"), backgroundColor: Colors.red));
                 return;
              }

              // Pindah ke Konfirmasi (Kirim ID Asli)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmRescheduleScreen(
                    bookingId: _realBookingId!, // ID ASLI DIKIRIM KE SINI
                    fieldId: _bookingData!['field_id'], // ID Lapangan
                    newDate: _selectedDate!,
                    reason: _reasonController.text,
                  ),
                ),
              );
            },
            child: const Text("Konfirmasi Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}