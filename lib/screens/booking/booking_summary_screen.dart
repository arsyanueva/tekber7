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
                          builder: (context) => BookingDetailScreen(
                            booking: widget.draftBooking,
                            // KIRIM PILIHAN USER KE SEBELAH 👉
                            selectedMethod: _selectedPaymentMethod, 
                          ),
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

  // --- LOGIC PILIH PEMBAYARAN (MODEL DROPDOWN/EXPANSION) ---
  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Biar bisa full screen kalo perlu
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet( // Biar bisa ditarik ke atas
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar Kecil
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // KELOMPOK 1: TRANSFER BANK
                        _buildGroup(
                          title: "Transfer Bank",
                          icon: Icons.account_balance,
                          children: [
                            _buildPaymentOption("Transfer BCA", "assets/images/bca.png"),
                            _buildPaymentOption("Transfer BRI", "assets/images/bri.png"),
                            _buildPaymentOption("Transfer Mandiri", "assets/images/mandiri.png"),
                            _buildPaymentOption("Bank Jatim", "assets/images/bank_jatim.png"),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // KELOMPOK 2: E-WALLET
                        _buildGroup(
                          title: "E-Wallet",
                          icon: Icons.wallet,
                          children: [
                            _buildPaymentOption("E-Wallet Dana", "assets/images/dana.png"),
                            _buildPaymentOption("E-Wallet Gopay", "assets/images/gopay.png"),
                            _buildPaymentOption("E-Wallet OVO", "assets/images/ovo.png"),
                            _buildPaymentOption("ShopeePay", "assets/images/shopeepay.png"),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // KELOMPOK 3: QRIS
                        _buildGroup(
                          title: "QRIS",
                          icon: Icons.qr_code_scanner,
                          children: [
                            _buildPaymentOption("QRIS", "assets/images/qris.png"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // Widget Helper buat Group (Dropdown)
  Widget _buildGroup({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        // Ilangin garis border bawaan ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // Defaultnya kebuka kalau metode yang dipilih ada di dalam grup ini (Opsional logic)
          initiallyExpanded: false, 
          children: children,
        ),
      ),
    );
  }

  // Widget Helper buat Item Pembayaran (Mirip yang kemarin, dirapiin dikit)
  Widget _buildPaymentOption(String name, String imagePath) {
    bool isSelected = _selectedPaymentMethod == name;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = name);
        Navigator.pop(context); // Tutup popup
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40, height: 30,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Image.asset(imagePath, fit: BoxFit.contain, 
                errorBuilder: (c,o,s) => const Icon(Icons.image, size: 20, color: Colors.grey)
              ),
            ),
            const SizedBox(width: 12),
            // Nama
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
            // Radio
            if (isSelected) 
              const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}