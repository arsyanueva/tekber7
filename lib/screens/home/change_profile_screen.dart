// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/utils/app_colors.dart'; // Pastikan import warna sesuai projectmu

class ChangeProfileScreen extends StatefulWidget {
  const ChangeProfileScreen({super.key});

  @override
  State<ChangeProfileScreen> createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangeProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. LOAD DATA SAAT INI
  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Ambil nama dari metadata
      final metadata = user.userMetadata;
      _nameController.text = metadata?['name'] ?? metadata?['full_name'] ?? '';
      
      // Ambil phone dari metadata (prioritas) atau dari auth user login
      _phoneController.text = metadata?['phone'] ?? user.phone ?? '';
    }
  }

  // 2. FUNGSI UPDATE PROFIL
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw "User tidak ditemukan";

      // Update data ke User Metadata Supabase
      // Kita simpan di 'data' agar tidak mengubah kredensial login (aman untuk demo)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(), // Simpan sebagai display data
            'full_name': _nameController.text.trim(), // Redundansi untuk kompatibilitas
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal 'true' agar halaman profil refresh
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal update: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ubah Profil",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Input Nama ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  hintText: "Masukkan nama lengkap",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Input No HP ---
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  hintText: "Contoh: 08123456789",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.phone_android),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nomor HP tidak boleh kosong";
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground, // Warna gelap sesuai tema
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}