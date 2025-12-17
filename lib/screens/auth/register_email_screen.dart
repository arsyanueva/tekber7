// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/services/auth_service.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Default role 'renter', tapi nanti akan di-update dari arguments
  String _role = 'renter'; 

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // --- MENANGKAP DATA DARI HALAMAN SEBELUMNYA ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      setState(() {
        _role = args; // Isinya akan 'owner' atau 'renter'
      });
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      _showErrorDialog("Semua data wajib diisi.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        role: _role, // <--- Menggunakan role database yang dikirim tadi
      );

      if (mounted) {
        Navigator.pushNamed(
          context, 
          '/verify-otp', 
          arguments: _emailController.text.trim()
        );
      }
    } on AuthException catch (e) {
      _showErrorDialog(e.message); 
    } catch (e) {
      _showErrorDialog("Terjadi kesalahan sistem: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gagal"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper untuk menampilkan teks role yang rapi
    String displayRole = _role == 'owner' ? 'Pemilik Lapangan' : 'Penyewa';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lengkapi Data Diri",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Info Role (Opsional, agar user yakin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[800]),
                    const SizedBox(width: 8),
                    Text(
                      "Mendaftar sebagai: $displayRole", 
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Input Nama
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  hintText: "cth: Budi Santoso",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
        
              // Input Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "cth: yuksehat@gmail.com",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
        
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "********",
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 40),
        
              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}