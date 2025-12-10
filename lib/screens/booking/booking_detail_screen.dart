import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Ganti 'tekber7' sesuai nama package project kamu
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_services.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // --- LOGIC PEMBAYARAN & RESCHEDULE (SAMA KAYAK TADI) ---
  Future<void> _handlePayment() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        await _bookingService.submitPayment(widget.booking.id, File(image.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bukti bayar terupload!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna Custom sesuai desain
    const Color primaryBlack = Color(0xFF1E1E1E);
    const Color primaryYellow = Color(0xFFFFD700);
    const Color bgGrey = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: primaryBlack, // Background atas Hitam
      appBar: AppBar(
        backgroundColor: primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryYellow))
          : Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: bgGrey,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // 1. CARD DETAIL LAPANGAN (HEADER HITAM & KUNING)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header Hitam
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: primaryBlack,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  ),
                                  child: const Text(
                                    'Bhaskara Futsal Arena', // Dummy Name (Nanti ambil dari relasi field)
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Body Kuning
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  color: primaryYellow,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sports_soccer, size: 20),
                                          SizedBox(width: 8),
                                          Text('Lapangan 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatDate(widget.booking.bookingDate)} | ${widget.booking.startTime}',
                                        style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                // Footer Putih (Metode Bayar)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row( // Logo Bank Dummy
                                            children: [
                                              Icon(Icons.account_balance, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('BCA Transfer BCA', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () {}, 
                                            style: TextButton.styleFrom(
                                              backgroundColor: primaryYellow,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            ),
                                            child: const Text('Ubah', style: TextStyle(color: Colors.black, fontSize: 10)),
                                          )
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      const Text('0812345678910 a.n. FieldMaster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      const Text('Lihat QR Code', style: TextStyle(color: Colors.blue, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 2. CARD RINCIAN BIAYA (Sesuai Desain Kanan)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: primaryYellow.withOpacity(0.2)),
                                    child: const Icon(Icons.check_circle, color: primaryYellow, size: 40),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Center(child: Text('Penyewaan Lapangan', style: TextStyle(fontWeight: FontWeight.bold))),
                                const SizedBox(height: 20),
                                _buildDetailRow('Tanggal', _formatDate(widget.booking.bookingDate)),
                                _buildDetailRow('Waktu', '${widget.booking.startTime} - ${widget.booking.endTime}'),
                                _buildDetailRow('Nomor Lapangan', '2'), // Dummy
                                _buildDetailRow('Metode Pembayaran', 'Transfer BCA'),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: primaryYellow.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Biaya', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Rp ${widget.booking.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 3. COUNTDOWN TIMER (Hiasan)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: primaryYellow.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16),
                                    SizedBox(width: 8),
                                    Text('Lakukan pembayaran dalam', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                Text('01 : 23 : 45', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 4. TOMBOL KONFIRMASI (Sticky di Bawah)
                Container(
                  // --- PERUBAHAN DI SINI ---
                  // Kita kasih padding bawah 50 (sebelumnya 20) biar tombolnya naik jauh ke atas
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 60), 
                  
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // Opsional: Kasih bayangan dikit biar keliatan misah sama konten atasnya
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E), // primaryBlack
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handlePayment,
                      child: const Text(
                        'Konfirmasi Pembayaran', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Widget Helper buat Baris Detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  // Format Tanggal Sederhana
  String _formatDate(DateTime date) {
    // Kalo mau format Indonesia (Sabtu, 15 Juni), butuh library intl
    // Sementara kita pake format simple dulu
    return "${date.day}/${date.month}/${date.year}";
  }
}