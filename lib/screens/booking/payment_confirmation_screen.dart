import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';
import 'payment_gateway_screen.dart'; 

class PaymentConfirmationScreen extends StatefulWidget {
  final BookingModel booking;
  final String fieldName;
  final String selectedMethod;

  const PaymentConfirmationScreen({
    super.key, 
    required this.booking,
    this.fieldName = "Bhaskara Futsal Arena",
    required this.selectedMethod,
  });

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  void _handlePaymentSimulation() {
    final info = _getPaymentInfo(); 
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          booking: widget.booking,
          paymentMethod: widget.selectedMethod,
          imagePath: info['imagePath'],        
          themeColor: info['color'] ?? Colors.blue, 
        ),
      ),
    );
  }

  Map<String, dynamic> _getPaymentInfo() {
    String method = widget.selectedMethod;
    
    String title = method;
    String account = "Menunggu Pembayaran...";
    String action = "Instruksi";
    String logoPath = "assets/images/bca.png"; 
    Color color = Colors.blue;

    if (method.contains("BCA")) {
      logoPath = "assets/images/bca.png";
      account = "0812-3456-7890 (BCA)";
      action = "Salin No. Rekening";
    } else if (method.contains("BRI")) {
      logoPath = "assets/images/bri.png";
      account = "1234-5678-9000 (BRI)";
      action = "Salin No. BRIVA";
      color = Colors.blue.shade900;
    } else if (method.contains("Mandiri")) {
      logoPath = "assets/images/mandiri.png";
      account = "900-00-123123-4 (Mandiri)";
      color = Colors.indigo;
    } else if (method.contains("Jatim")) {
      logoPath = "assets/images/jatim.png"; 
      account = "001-234-567 (Jatim)";
      color = Colors.red;
    } else if (method.contains("Dana")) {
      logoPath = "assets/images/dana.png";
      account = "0812-3456-7890 (Bara)";
      action = "Buka Aplikasi Dana";
    } else if (method.contains("Gopay")) {
      logoPath = "assets/images/gopay.png";
      account = "0812-3456-7890 (Gopay)";
      action = "Buka Gojek";
      color = Colors.green;
    } else if (method.contains("OVO")) {
      logoPath = "assets/images/ovo.png";
      account = "0812-3456-7890 (OVO)";
      action = "Buka OVO";
      color = Colors.purple;
    } else if (method.contains("Shopee")) {
      logoPath = "assets/images/shopeepay.png";
      account = "0812-3456-7890 (Shopee)";
      action = "Buka Shopee";
      color = Colors.orange;
    } else if (method.contains("QRIS")) {
      logoPath = "assets/images/qris.png";
      title = "QRIS";
      account = "Scan QR Code di bawah";
      action = "Download QR";
      color = Colors.black;
    }

    return {
      "imagePath": logoPath,
      "color": color, 
      "title": title,
      "account": account,
      "action": action
    };
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = _formatDate(widget.booking.bookingDate);
    final paymentInfo = _getPaymentInfo();

    const Color primaryBlack = Color(0xFF1E1E1E);
    const Color primaryYellow = Color(0xFFFFD700);
    const Color bgGrey = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: primaryBlack,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        iconTheme: const IconThemeData(color: primaryYellow),
        title: const Text('Konfirmasi Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(color: bgGrey, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                            color: primaryBlack,
                            child: Text(widget.fieldName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Container(
                            width: double.infinity, padding: const EdgeInsets.all(16), color: primaryYellow,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [Icon(Icons.sports_soccer, size: 20), SizedBox(width: 8), Text('Lapangan 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                                const SizedBox(height: 8),
                                Text('$formattedDate | ${widget.booking.startTime}', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 13)),
                              ],
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 50, height: 35,
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade200)),
                                        child: Image.asset(paymentInfo['imagePath'], fit: BoxFit.contain,
                                           errorBuilder: (c,o,s) => const Icon(Icons.account_balance, color: Colors.blue, size: 20),
                                        ),
                                      ), 
                                      const SizedBox(width: 12), 
                                      Text(paymentInfo['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                                    ]),
                                    
                                    SizedBox(height: 28, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryYellow, padding: const EdgeInsets.symmetric(horizontal: 12), elevation: 0), onPressed: (){ Navigator.pop(context); }, child: const Text("Ubah", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))))
                                  ],
                                ),
                                const Divider(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(paymentInfo['account'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                                    ]),
                                    TextButton(onPressed: (){}, child: Text(paymentInfo['action'], style: const TextStyle(color: Colors.blue, fontSize: 12)))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: primaryYellow, size: 40),
                          const SizedBox(height: 10),
                          const Text('Penyewaan Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildRow("Tanggal", _formatDate(widget.booking.bookingDate)),
                          _buildRow("Waktu", "${widget.booking.startTime} - ${widget.booking.endTime}"),
                          _buildRow("Lapangan", "2"),
                          const Divider(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: primaryYellow.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("Total Biaya", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Rp ${widget.booking.totalPrice}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _handlePaymentSimulation,
                child: const Text('Lanjut ke Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))]));
}