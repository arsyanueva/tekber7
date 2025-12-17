// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/screens/home/change_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel untuk menampung data user
  String name = "Loading...";
  String emailOrPhone = "Loading...";
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // FUNGSI: Ambil data dari User Metadata Supabase
  void _getProfileData() {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      setState(() {
        // Ambil nama dari metadata (jika ada), kalau tidak pakai bagian depan email
        final metadata = user.userMetadata;
        
        // Cek apakah ada 'full_name' atau 'name' di metadata
        name = metadata?['name'] ?? metadata?['full_name'] ?? 'User';
        
        // Jika nama masih kosong/default, pakai email
        if (name == 'User' && user.email != null) {
          name = user.email!.split('@')[0];
        }

        // Ambil Phone jika login pakai phone, atau Email jika pakai email
        emailOrPhone = user.phone ?? user.email ?? '-';
      });
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B2F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ================= AVATAR =================
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      // Jika nanti ada URL avatar, pakai NetworkImage
                      backgroundImage: const AssetImage("assets/profile_dummy.png"),
                      // backgroundColor: Colors.grey, // Opsi jika gambar gagal load
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit, // Ganti icon kamera jadi edit
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ================= NAME & PHONE (DARI DATABASE) =================
              Text(
                name, // <-- Variabel Nama
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                emailOrPhone, // <-- Variabel Email/HP
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // ================= MENU =================
              _menuButton(
              icon: Icons.person_outline,
              title: "Ubah Profil",
              onTap: () {
                // --- TEMPEL KODENYA DI SINI ---
                Navigator.pushNamed(context, '/change-profile').then((result) {
                  // Jika kembali membawa data 'true' (berhasil update), refresh data
                  if (result == true) {
                    _getProfileData();
                  }
                });
              },
            ),
              _menuButton(
                icon: Icons.lock_outline,
                title: "Ganti Password",
                onTap: () {
                  Navigator.pushNamed(context, "/change-password");
                },
              ),

              const SizedBox(height: 40),

              // ================= LOGOUT =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("Keluar", style: TextStyle(fontSize: 16)),
                    onPressed: _signOut,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}