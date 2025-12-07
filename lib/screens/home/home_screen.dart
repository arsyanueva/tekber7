import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan path import ini benar (sesuaikan dengan nama package Anda)
import 'package:tekber7/models/field_model.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/widgets/field_card.dart';
// 1. INI PENTING: Import halaman BookingHistoryScreen
import 'package:tekber7/screens/booking/booking_history_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Variabel untuk menentukan tab mana yang aktif (0, 1, 2, atau 3)
  int _selectedIndex = 0; 
  
  List<FieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  Future<void> fetchFields() async {
    try {
      final response = await Supabase.instance.client.from('fields').select();
      final data = response as List<dynamic>;
      if (mounted) {
        setState(() {
          fields = data.map((json) => FieldModel.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. DAFTAR HALAMAN TAB
    // Urutan di sini harus SAMA PERSIS dengan urutan BottomNavigationBarItem di bawah
    final List<Widget> pages = [
      // Index 0: Home (Beranda)
      HomeContent(fields: fields, isLoading: isLoading), 
      
      // Index 1: Lapangan
      const Center(child: Text('Halaman Lapangan')),
      
      // Index 2: Pemesanan -> INI YANG MEMANGGIL HISTORY
      const BookingHistoryScreen(), 
      
      // Index 3: Profil
      const Center(child: Text('Halaman Profil')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      // 4. BODY MENGGUNAKAN LOGIKA INDEX
      // Ini yang bikin layar berganti saat diklik tanpa perlu AppRoutes
      body: pages[_selectedIndex], 

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Menandai ikon mana yang aktif
        selectedItemColor: AppColors.darkBackground,
        unselectedItemColor: Colors.grey,
        // 5. SAAT DIKLIK, UBAH NILAI _selectedIndex
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'), // Index 0
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Lapangan'), // Index 1
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Pemesanan'), // Index 2 (Target)
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'), // Index 3
        ],
      ),
    );
  }
}

// --- WIDGET KONTEN BERANDA ---
class HomeContent extends StatelessWidget {
  final List<FieldModel> fields;
  final bool isLoading;

  const HomeContent({super.key, required this.fields, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
             decoration: const BoxDecoration(
               color: AppColors.darkBackground,
               borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
             ),
             child: Column(
               children: [
                 const Row(children: [
                   CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                   SizedBox(width: 12),
                   Text('Halo, Daniel', style: TextStyle(color: Colors.white, fontSize: 16)),
                   Spacer(),
                   Icon(Icons.notifications_outlined, color: Colors.white),
                 ]),
                 const SizedBox(height: 24),
                 const Text('Mau sewa lapangan\ndimana ?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
           const SizedBox(height: 20),
           SizedBox(
             height: 240,
             child: isLoading
                 ? const Center(child: CircularProgressIndicator())
                 : fields.isEmpty
                     ? const Center(child: Text('Belum ada data'))
                     : ListView.builder(
                         scrollDirection: Axis.horizontal,
                         padding: const EdgeInsets.only(left: 24),
                         itemCount: fields.length,
                         itemBuilder: (context, index) => FieldCard(field: fields[index]),
                       ),
           ),
           const SizedBox(height: 50),
        ],
      ),
    );
  }
}