// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definisi Warna sesuai Desain
const Color kDarkColor = Color(0xFF221F2E); // Warna tombol gelap
const Color kYellowColor = Color(0xFFFFC200); // Warna tombol kuning/oranye
const Color kInputColor = Color(0xFFEAEAEA); // Warna background input field
const Color kTextColor =  Colors.black87;

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
  void back() => setState(() => step = ResetStep.values[step.index - 1]);

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
        // Kirim OTP ke Email
        await supabase.auth.signInWithOtp(
          email: contactCtrl.text.trim(),
          shouldCreateUser: false, // Penting: False karena kita mau reset, bukan daftar baru
        );
      } else {
        // Kirim OTP ke SMS
        await supabase.auth.signInWithOtp(
          phone: contactCtrl.text.trim(),
          shouldCreateUser: false,
        );
      }
      next(); // Pindah ke halaman input OTP
    } on AuthException catch (e) {
      // Menangkap error khusus Supabase (misal: user tidak ditemukan)
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

      // Jika session berhasil dibuat, artinya login sukses
      if (response.session != null) {
        next(); // Pindah ke halaman password baru
      } else {
        throw "Verifikasi gagal";
      }
    } on AuthException catch (e) {
      setState(() => error = e.message); // Biasanya "Token expired" atau "Invalid token"
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
      // Karena langkah verifyOtp sudah membuat user 'Login', 
      // kita bisa langsung pakai updateUser
      await supabase.auth.updateUser(
        UserAttributes(password: passCtrl.text),
      );
      next(); // Pindah ke halaman sukses
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Tombol Back & Judul)
              if (step != ResetStep.input && step != ResetStep.success)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: back,
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),

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
                const SizedBox(height: 24),

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

              // 3. KONTEN BODY (Expanded agar Spacer bekerja)
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: kDarkColor))
                    : _getCurrentContent(), 
              ),
            ],
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
          decoration: _inputDecoration(isEmail ? 'nama@email.com' : '+628...'),
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
          keyboardType: TextInputType.number, // Supaya keyboard muncul angka
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
                // Saat tombol kembali ditekan, hapus semua history route
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
      filled: true,
      fillColor: kInputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}