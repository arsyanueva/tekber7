import 'package:flutter/material.dart';
import 'package:tekber7/models/booking_model.dart';
import 'booking_detail_screen.dart'; // Nanti lari ke sini

class BookingSummaryScreen extends StatefulWidget {
  final String fieldName;
  final BookingModel draftBooking; 

  const BookingSummaryScreen({
    super.key,
    required this.fieldName,
    required this.draftBooking,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  String _selectedPaymentMethod = "Pilih Metode Pembayaran";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Hitam
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)), // Back Kuning
        title: const Text('Pesanan Anda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DATA PESANAN
                  _buildSectionLabel("Data Pesanan", "Ringkasan pesanan lapangan anda"),
                  _buildCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(widget.draftBooking.bookingDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(widget.fieldName, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        _buildUbahButton(() {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. PEMESAN (Dummy dulu)
                  _buildSectionLabel("Pemesan", "E-tiket akan dikirim ke kontak ini"),
                  _buildCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bara Ardiwinata", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text("+62812345678", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        _buildUbahButton(() {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. PEMBAYARAN (Selector)
                  _buildSectionLabel("Pembayaran", "Pilih metode pembayaran"),
                  _buildCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_selectedPaymentMethod != "Pilih Metode Pembayaran")
                               const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              _selectedPaymentMethod,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedPaymentMethod == "Pilih Metode Pembayaran" ? Colors.grey : Colors.black
                              ),
                            ),
                          ],
                        ),
                        _buildUbahButton(_showPaymentSelector),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BOTTOM BAR (TOTAL & TOMBOL BAYAR)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Harga Total"),
                    Text("Rp ${widget.draftBooking.totalPrice}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E), // Hitam
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_selectedPaymentMethod == "Pilih Metode Pembayaran") {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih pembayaran dulu!")));
                        return;
                      }
                      // GAS KE HALAMAN KONFIRMASI
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(booking: widget.draftBooking),
                        ),
                      );
                    },
                    child: const Text("Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionLabel(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _buildUbahButton(VoidCallback onTap) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), padding: const EdgeInsets.symmetric(horizontal: 16)),
        onPressed: onTap,
        child: const Text("Ubah", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text("Transfer BCA"),
              onTap: () { setState(() => _selectedPaymentMethod = "Transfer BCA"); Navigator.pop(context); },
            ),
             ListTile(
              leading: const Icon(Icons.wallet, color: Colors.blue),
              title: const Text("E-Wallet Dana"),
              onTap: () { setState(() => _selectedPaymentMethod = "Dana"); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}