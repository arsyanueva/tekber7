// Arsya Nueva Delavera (5026231099)

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B2F),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: const Color(0xFF1C1B2F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: "Lapangan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
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
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        AssetImage("assets/profile_dummy.jpg"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ================= NAME & PHONE =================
            const Text(
              "Daniel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "083812345678",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            // ================= MENU =================
            menuButton(
              icon: Icons.person_outline,
              title: "Ubah Profil",
              onTap: () {},
            ),
            menuButton(
              icon: Icons.lock_outline,
              title: "Ganti Password",
              onTap: () {
                Navigator.pushNamed(context, "/change-password");
              },
            ),

            const Spacer(),

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
                  label: const Text(
                    "Keluar",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    // TODO: Supabase signOut
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENU BUTTON =================
  static Widget menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
