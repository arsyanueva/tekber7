// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/services/auth_service.dart';
import 'package:tekber7/utils/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final int _otpLength = 8; 

  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  bool _isButtonActive = false;
  bool _isLoading = false;
  String _email = ''; 
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Generate 8 controller & 8 focus node
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _email = args;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkInput() {
    String otp = _controllers.map((e) => e.text).join();
    setState(() {
      _isButtonActive = otp.length == _otpLength;
    });
  }

  void _onDigitChanged(String value, int index) {
    // Pindah ke kotak selanjutnya
    if (value.length == 1 && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } 
    // Pindah ke kotak sebelumnya (Backspace)
    else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    _checkInput();
  }

  Future<void> _verify() async {
    if (!_isButtonActive) return;

    setState(() => _isLoading = true);
    String otp = _controllers.map((e) => e.text).join();

    try {
      // 1. Verifikasi OTP ke Supabase
      await _authService.verifyOtp(email: _email, token: otp);

      // 2. Ambil Data Profile untuk Cek Role
      // Karena user baru saja terverifikasi, kita cek dia daftar sebagai apa
      final userProfile = await _authService.getUserProfile();
      final role = userProfile?['role'] ?? 'renter'; // Default ke renter

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi Berhasil!')),
        );

        // 3. Navigasi Berdasarkan Role
        if (role == 'owner') {
          // Arahkan Owner ke Home Owner
          Navigator.pushNamedAndRemoveUntil(context, '/home-owner', (route) => false);
        } else {
          // Arahkan Penyewa ke Home Biasa
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // RUMUS RESPONSIF BARU (Agar 8 kotak muat):
    // Lebar layar dikurangi padding kiri-kanan (48), dikurangi sedikit spasi antar kotak
    double screenWidth = MediaQuery.of(context).size.width;
    // Kita bagi ruang yang ada dengan jumlah digit (8)
    double boxSize = (screenWidth - 60) / _otpLength; 

    // Safety check: Jangan terlalu kecil, tapi untuk 8 digit pasti agak kecil
    if (boxSize > 50) boxSize = 50; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan Kode Verifikasi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 12),
            Text("Kode 8 digit telah dikirim ke $_email", style: TextStyle(color: Colors.grey[600])),
            
            const SizedBox(height: 40),

            // --- INPUT OTP 8 DIGIT ---
            // Menggunakan Wrap atau Row dengan spaceBetween agar rapi
            SizedBox(
              height: 60, // Tinggi container baris input
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return Container(
                    width: boxSize, 
                    height: boxSize + 10, 
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8), // Radius dikecilkan dikit biar tidak terlalu bulat
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onDigitChanged(value, index),
                        // Font size dikecilkan sedikit agar muat
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero, // Hilangkan padding internal agar angka di tengah
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // --- TOMBOL VERIFIKASI ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isButtonActive && !_isLoading ? _verify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonActive ? AppColors.darkBackground : Colors.grey[300],
                  foregroundColor: _isButtonActive ? Colors.white : Colors.grey[600],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}