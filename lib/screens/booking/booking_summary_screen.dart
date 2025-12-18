import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:tekber7/models/booking_model.dart';
import 'payment_confirmation_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  final String fieldLocation; 
  final String fieldImage;    
  final DateTime selectedDate;
  final String selectedTime;  
  final int price;            

  const BookingSummaryScreen({
    super.key,
    required this.fieldId,
    required this.fieldName,
    required this.fieldLocation,
    required this.fieldImage,
    required this.selectedDate,
    required this.selectedTime,
    required this.price,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  late BookingModel _draftBooking; 
  String _selectedPaymentMethod = "Pilih Metode Pembayaran";
  
  // DATA USER DINAMIS
  String userName = "Loading...";
  String userPhone = "-";
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Ambil data user pas layar dibuka
    
    // Setup Model Booking
    _draftBooking = BookingModel(
      id: "booking-${DateTime.now().millisecondsSinceEpoch}",
      fieldId: widget.fieldId,
      renterId: Supabase.instance.client.auth.currentUser?.id ?? "unknown", // Pake ID Asli
      bookingDate: widget.selectedDate,
      startTime: widget.selectedTime.split(" - ")[0], 
      endTime: widget.selectedTime.split(" - ")[1],   
      totalPrice: widget.price,
      status: "pending",
      paymentMethod: _selectedPaymentMethod,
      createdAt: DateTime.now(),
    );
  }

  // --- FUNGSI AMBIL DATA USER ---
  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Ambil data detail dari tabel 'users' berdasarkan ID auth
        final data = await supabase
            .from('users')
            .select('name, phone_number')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            userName = data['name'] ?? "User Tanpa Nama";
            userPhone = data['phone_number'] ?? user.email ?? "-"; // Fallback ke email kalo hp kosong
            isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error ambil user: $e");
      if (mounted) setState(() => isLoadingUser = false);
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
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
                        Expanded( // Pake Expanded biar teks panjang gak overflow
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatDate(widget.selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("${widget.fieldName} (${widget.selectedTime})", style: const TextStyle(color: Colors.grey)),
                              Text(widget.fieldLocation, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        _buildUbahButton(() => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. PEMESAN (DINAMIS SEKARANG! 😎)
                  _buildSectionLabel("Pemesan", "E-tiket akan dikirim ke kontak ini"),
                  _buildCard(
                    child: isLoadingUser 
                      ? const Center(child: LinearProgressIndicator(color: Colors.amber))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(userPhone, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            // Tombol ubah dimatiin dulu, karena ngubah profil itu fitur lain
                            // _buildUbahButton(() {}), 
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
                        Expanded(
                          child: Row(
                            children: [
                              if (_selectedPaymentMethod != "Pilih Metode Pembayaran")
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedPaymentMethod,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedPaymentMethod == "Pilih Metode Pembayaran" ? Colors.grey : Colors.black
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
                    Text(_formatCurrency(widget.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(
                            booking: _draftBooking,
                            fieldName: widget.fieldName, 
                            selectedMethod: _selectedPaymentMethod, 
                          ),
                        ),
                      );
                    },
                    child: const Text("Lanjut Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // --- LOGIC PILIH PEMBAYARAN (SAMA AJA KAYAK KEMARIN) ---
  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet( 
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
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildGroup(title: "Transfer Bank", icon: Icons.account_balance, children: [
                            _buildPaymentOption("Transfer BCA", "assets/images/bca.png"),
                            _buildPaymentOption("Transfer BRI", "assets/images/bri.png"),
                            _buildPaymentOption("Transfer Mandiri", "assets/images/mandiri.png"),
                            _buildPaymentOption("Bank Jatim", "assets/images/jatim.png"),
                          ]),
                        const SizedBox(height: 10),
                        _buildGroup(title: "E-Wallet", icon: Icons.wallet, children: [
                            _buildPaymentOption("E-Wallet Dana", "assets/images/dana.png"),
                            _buildPaymentOption("E-Wallet Gopay", "assets/images/gopay.png"),
                            _buildPaymentOption("E-Wallet OVO", "assets/images/ovo.png"),
                            _buildPaymentOption("ShopeePay", "assets/images/shopeepay.png"),
                          ]),
                        const SizedBox(height: 10),
                        _buildGroup(title: "QRIS", icon: Icons.qr_code_scanner, children: [
                            _buildPaymentOption("QRIS", "assets/images/qris.png"),
                          ]),
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

  Widget _buildGroup({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: false, 
          children: children,
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String name, String imagePath) {
    bool isSelected = _selectedPaymentMethod == name;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = name);
        Navigator.pop(context); 
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (c,o,s) => const Icon(Icons.image, size: 20, color: Colors.grey))),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20),
          ],
        ),
      ),
    );
  }
}