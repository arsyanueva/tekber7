// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:tekber7/utils/app_colors.dart'; // Pastikan file warna ada

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Default value untuk database: 'renter' atau 'owner'
  String _selectedRoleValue = 'renter'; 

  @override
  Widget build(BuildContext context) {
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
            // 1. TEKS DIPERBESAR
            const Text(
              "Daftar Sebagai",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), 
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                // KARTU 1: PENGELOLA (OWNER)
                Expanded(
                  child: _buildRoleCard(
                    label: 'Pengelola',
                    imagePath: 'assets/images/owner.png', 
                    value: 'owner', 
                  ),
                ),
                const SizedBox(width: 16),
                
                // KARTU 2: PENYEWA (RENTER)
                Expanded(
                  child: _buildRoleCard(
                    label: 'Penyewa',
                    imagePath: 'assets/images/renter.png', 
                    value: 'renter', 
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 3. TOMBOL DIPERBESAR
            SizedBox(
              width: double.infinity,
              height: 60, // Tinggi ditambah (50 -> 60)
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/register-email', 
                    arguments: _selectedRoleValue 
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBackground,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Radius diperhalus sedikit
                  ),
                ),
                child: const Text(
                  "Daftar", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18) // Font tombol diperbesar
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({required String label, required String imagePath, required String value}) {
    final bool isSelected = _selectedRoleValue == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleValue = value;
        });
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          // 2. LOGIKA WARNA BACKGROUND: Hitam jika dipilih, Abu-abu jika tidak
          color: isSelected ? AppColors.darkBackground : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: AppColors.darkBackground, width: 2) 
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 80),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                // Ubah warna teks jadi Putih jika background Hitam (Selected)
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}