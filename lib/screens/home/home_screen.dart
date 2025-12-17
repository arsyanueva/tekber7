import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/field_model.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/widgets/field_card.dart';
import 'package:tekber7/screens/booking/booking_history_screen.dart';
import 'package:tekber7/services/auth_service.dart';
import 'field_detail_screen.dart'; 
import 'package:tekber7/screens/home/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  List<FieldModel> fields = [];
  bool isLoading = true;
  String userName = 'Sobat Olahraga'; // Default greeting
  String _selectedFilter = 'Termurah'; // Default filter

  @override
  void initState() {
    super.initState();
    fetchFields();
    fetchUserProfile();
  }

  Future<void> fetchFields() async {
    try {
      final response = await Supabase.instance.client.from('fields').select();
      final data = response as List<dynamic>;
      if (mounted) {
        setState(() {
          fields = data.map((json) => FieldModel.fromJson(json)).toList();
          _sortFields(); // Apply default filter
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final authService = AuthService();
      final userProfile = await authService.getUserProfile();
      if (mounted && userProfile != null) {
        setState(() {
          userName = userProfile['name'] ?? 'Sobat Olahraga';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _sortFields();
    });
  }

  void _sortFields() {
    switch (_selectedFilter) {
      case 'Termurah':
        fields.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'Fasilitas Lengkap':
        fields.sort((a, b) {
          final countA = a.facilities.split(',').length;
          final countB = b.facilities.split(',').length;
          return countB.compareTo(countA); // Descending (most facilities first)
        });
        break;
      case 'Terdekat':
        // Mock User Location (Surabaya Center for demo)
        const userLat = -7.2575; 
        const userLng = 112.7521;
        
        fields.sort((a, b) {
          // Simple Euclidean distance approximation for sorting
          final distA = (a.latitude - userLat) * (a.latitude - userLat) + 
                        (a.longitude - userLng) * (a.longitude - userLng);
          final distB = (b.latitude - userLat) * (b.latitude - userLat) + 
                        (b.longitude - userLng) * (b.longitude - userLng);
          return distA.compareTo(distB);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(
        fields: fields, 
        isLoading: isLoading, 
        userName: userName,
        selectedFilter: _selectedFilter,
        onFilterChanged: _onFilterChanged,
      ),
      const Center(child: Text('Halaman Lapangan')),
      const BookingHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkBackground,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Lapangan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Pemesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- WIDGET KONTEN BERANDA (Update untuk Filter) ---
class HomeContent extends StatelessWidget {
  final List<FieldModel> fields;
  final bool isLoading;
  final String userName;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const HomeContent({
    super.key, 
    required this.fields, 
    required this.isLoading,
    required this.userName,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER HITAM
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
                Row(children: [
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                  const SizedBox(width: 12),
                  Text('Halo, $userName', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                ]),
                
                const SizedBox(height: 24),
                
                // Judul Besar
                const Text('Mau sewa lapangan\ndimana ?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 24),

                // BAGIAN PENCARIAN & KOTA
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Lapangan di Surabaya',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFF2B2930), 
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
                    // Dropdown Kota
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

          // 2. FILTER CHIPS (Interactive)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Terdekat'),
                  _buildFilterChip('Termurah'),
                  _buildFilterChip('Fasilitas Lengkap'),
                ],
              ),
            ),
          ),

          // 3. JUDUL REKOMENDASI
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rekomendasi untuk kamu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Lihat Semua >', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // 4. LIST LAPANGAN
          SizedBox(
            height: 260,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : fields.isEmpty
                    ? const Center(child: Text('Belum ada data lapangan'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24),
                        itemCount: fields.length,
                        itemBuilder: (context, index) {
                          final field = fields[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FieldDetailScreen(
                                    fieldId: field.id, 
                                  ),
                                ),
                              );
                            },
                            child: FieldCard(field: field),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Helper Widget untuk Filter Chip
  Widget _buildFilterChip(String label) {
    final bool isActive = selectedFilter == label;
    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: Container(
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}