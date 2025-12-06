import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/field_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/field_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk menyimpan list lapangan dari database
  List<FieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  // Fungsi mengambil data dari Supabase
  Future<void> fetchFields() async {
    try {
      final response = await Supabase.instance.client
          .from('fields') 
          .select(); 
      
      final data = response as List<dynamic>;
      
      setState(() {
        fields = data.map((json) => FieldModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fields: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu muda
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.darkBackground,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Lapangan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Pemesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER HITAM ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar & Nama
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/100'), // Avatar dummy
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Halo, Daniel',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_outlined, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Judul Besar
                  const Text(
                    'Mau sewa lapangan\ndimana ?',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar & Filter Kota
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari Lapangan di Surabaya',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFF2B2930), // Warna abu gelap
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Dropdown Kota (Dummy UI)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2930),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text('SBY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- FILTER CHIPS ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  _buildFilterChip('Terdekat', false),
                  _buildFilterChip('Termurah', true), // Ceritanya sedang aktif (hitam)
                  _buildFilterChip('Fasilitas Lengkap', false),
                ],
              ),
            ),

            // --- REKOMENDASI SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Rekomendasi untuk kamu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Lihat Semua >', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // --- LIST HORIZONTAL LAPANGAN ---
            SizedBox(
              height: 240, // Tinggi area scroll
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Loading indicator
                  : fields.isEmpty
                      ? const Center(child: Text('Belum ada data lapangan'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: fields.length,
                          itemBuilder: (context, index) {
                            return FieldCard(field: fields[index]);
                          },
                        ),
            ),
            
            const SizedBox(height: 50), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk tombol filter (Terdekat, Termurah, dll)
  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.darkBackground : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}