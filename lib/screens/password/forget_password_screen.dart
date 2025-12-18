// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definisi Warna sesuai Desain
const Color kDarkColor = Color(0xFF221F2E); // Warna tombol gelap
const Color kYellowColor = Color(0xFFFFC200); // Warna tombol kuning/oranye
const Color kInputColor = Color(0xFFEAEAEA); // Warna background input field
const Color kTextColor = Colors.black87;

enum ResetStep {
  input,
  verify,
  newPassword,
  success,
}

class ResetPasswordFlow extends StatefulWidget {
  const ResetPasswordFlow({super.key});

  @override
  State<ResetPasswordFlow> createState() => _ResetPasswordFlowState();
}

class _ResetPasswordFlowState extends State<ResetPasswordFlow> {
  ResetStep step = ResetStep.input;

  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool isEmail = true; // Default ke email
  bool loading = false;
  String? error;

  // Mengambil instance Supabase yang sudah diinit di main.dart
  SupabaseClient get supabase => Supabase.instance.client;

  void next() => setState(() => step = ResetStep.values[step.index + 1]);
  
  // LOGIC TOMBOL BACK:
  // - Jika di langkah pertama, tutup halaman (pop).
  // - Jika di langkah selanjutnya, mundur satu langkah (step - 1).
  void back() {
    if (step == ResetStep.input) {
      Navigator.pop(context);
    } else {
      setState(() => step = ResetStep.values[step.index - 1]);
      error = null; // Bersihkan error saat mundur
    }
  }

  // --- 1. MENGIRIM KODE OTP ---
  Future<void> sendReset() async {
    if (contactCtrl.text.isEmpty) {
      setState(() => error = "Harap isi data terlebih dahulu");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (isEmail) {
        await supabase.auth.signInWithOtp(
          email: contactCtrl.text.trim(),
          shouldCreateUser: false, 
        );
      } else {
        await supabase.auth.signInWithOtp(
          phone: contactCtrl.text.trim(),
          shouldCreateUser: false,
        );
      }
      next(); 
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = "Terjadi kesalahan koneksi");
    } finally {
      setState(() => loading = false);
    }
  }

  // --- 2. VERIFIKASI KODE OTP ---
  Future<void> verifyOtp() async {
    if (otpCtrl.text.isEmpty) {
      setState(() => error = "Masukkan kode OTP");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await supabase.auth.verifyOTP(
        email: isEmail ? contactCtrl.text.trim() : null,
        phone: !isEmail ? contactCtrl.text.trim() : null,
        token: otpCtrl.text.trim(),
        type: isEmail ? OtpType.email : OtpType.sms,
      );

      if (response.session != null) {
        next(); 
      } else {
        throw "Verifikasi gagal";
      }
    } on AuthException catch (e) {
      setState(() => error = e.message); 
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // --- 3. UPDATE PASSWORD BARU ---
  Future<void> updatePassword() async {
    if (passCtrl.text.isEmpty || confirmCtrl.text.isEmpty) {
      setState(() => error = "Password tidak boleh kosong");
      return;
    }
    
    if (passCtrl.text != confirmCtrl.text) {
      setState(() => error = 'Password tidak sama');
      return;
    }

    if (passCtrl.text.length < 6) {
      setState(() => error = 'Password minimal 6 karakter');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: passCtrl.text),
      );
      next(); 
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // --- WIDGET BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    // Logic Judul Header
    String title = "";
    if (step == ResetStep.input) {
      title = isEmail
          ? 'Masukkan Email Terdaftar'
          : 'Masukkan Nomor Handphone Terdaftar';
    } else if (step == ResetStep.verify) {
      title = isEmail ? 'Periksa Email Anda' : 'Periksa Kotak Pesan Anda';
    } else if (step == ResetStep.newPassword) {
      title = 'Perbarui Password';
    }

    // Handle tombol fisik Android (PopScope)
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        back(); // Panggil fungsi back custom kita
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        
        // --- INI BAGIAN APPBAR YANG DISESUAIKAN ---
        // Menggunakan AppBar standar seperti di LoginEmailScreen
        appBar: step == ResetStep.success 
            ? null 
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: back, // Panggil logika back custom
                ),
              ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Padding disamakan 24
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. JUDUL HALAMAN (Tetap di body, di bawah AppBar)
                if (step != ResetStep.success)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                
                if (step != ResetStep.success)
                  const SizedBox(height: 30), // Spacing disamakan 30
      
                // 2. ERROR MESSAGE
                if (error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  ),
      
                // 3. KONTEN BODY
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: kDarkColor))
                      : _getCurrentContent(), 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER FUNCTION ---
  Widget _getCurrentContent() {
    switch (step) {
      case ResetStep.input:
        return _input();
      case ResetStep.verify:
        return _verify();
      case ResetStep.newPassword:
        return _newPassword();
      case ResetStep.success:
        return _success();
      default:
        return const SizedBox();
    }
  }

  // --- WIDGETS BAGIAN-BAGIAN HALAMAN ---

  Widget _input() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: contactCtrl,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
          decoration: _inputDecoration(isEmail ? 'cth: nama@email.com' : 'cth: +628...'),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                isEmail = !isEmail;
                contactCtrl.clear();
                error = null;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isEmail ? 'Gunakan Nomor HP' : 'Gunakan Email',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const Spacer(),
        _primaryButton(
          onPressed: sendReset,
          text: 'Lanjutkan',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _verify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: kInputColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            contactCtrl.text,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isEmail
              ? 'Link verifikasi/OTP telah dikirim ke email. Cek inbox/spam.'
              : 'Kode OTP telah dikirim ke nomor HP Anda.',
          style: const TextStyle(color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: sendReset,
          child: const Text(
            'Kirim ulang kode',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: kTextColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: otpCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Masukkan Kode OTP'),
        ),
        const Spacer(),
        _primaryButton(
          onPressed: verifyOtp,
          text: 'Lanjutkan',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _newPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: _inputDecoration('Password baru'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmCtrl,
          obscureText: true,
          decoration: _inputDecoration('Konfirmasi Password baru'),
        ),
        const Spacer(),
        _primaryButton(
          onPressed: updatePassword,
          text: 'Lanjutkan',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _success() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: kDarkColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 30),
          const Text(
            'Password Telah\nDiperbarui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kYellowColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text(
                'Kembali ke Halaman Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UTILS WIDGETS ---

  Widget _primaryButton({required VoidCallback onPressed, required String text}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true, // Tidak ada border luar
      fillColor: kInputColor, // Warna abu-abu background input
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // Hilangkan border garis
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}