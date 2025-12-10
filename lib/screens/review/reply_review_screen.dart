import 'package:flutter/material.dart';

class ReplyReviewScreen extends StatefulWidget {
  const ReplyReviewScreen({super.key});

  @override
  State<ReplyReviewScreen> createState() => _ReplyReviewScreenState();
}

class _ReplyReviewScreenState extends State<ReplyReviewScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    const Color primaryBlack = Color(0xFF1E1E1E);
    const Color accentYellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Abu
      
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: primaryBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Balas Ulasan",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU UTAMA
            Container(
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
                  // 1. INFO LAPANGAN (Header Hitam)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: primaryBlack,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    // FIXED: const dihapus dari sini
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bhaskara Futsal Arena", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        // Badge Jarak
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: accentYellow,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Text("7.7 km", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Bintang (Info Lapangan)
                        const Row(
                          children: [
                            Icon(Icons.star, color: accentYellow, size: 18),
                            SizedBox(width: 5),
                            Text("4.8 (40)", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Text("● 10% Discount area", style: TextStyle(fontSize: 12, color: Colors.orange)),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // 2. KOMENTAR USER (YANG MAU DIBALAS)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar User
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama & Rating User
                                  Row(
                                    children: [
                                      const Text("Tomo", style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: accentYellow.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.star, size: 12, color: Colors.orange),
                                            SizedBox(width: 4),
                                            Text("5.0", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Isi Komentar
                                  Text(
                                    "Lapangannya bagus dan worth it sama harganya, fasilitasnya juga lengkap.",
                                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // 3. INPUT BALASAN (TEXTFIELD)
                        const Text("Masukkan Balasan Anda", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _replyController,
                          maxLines: 5, // Kotak agak besar
                          decoration: InputDecoration(
                            hintText: "Tulis ucapan terima kasih atau tanggapan...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // TOMBOL POSTING (Di Bawah)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : () async {
              if (_replyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Balasan tidak boleh kosong!"))
                );
                return;
              }

              setState(() => _isLoading = true);

              // SIMULASI POSTING KE DATABASE
              await Future.delayed(const Duration(seconds: 2));

              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Balasan berhasil diposting!"),
                    backgroundColor: Colors.green,
                  )
                );
                Navigator.pop(context); 
              }
            },
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Posting", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}