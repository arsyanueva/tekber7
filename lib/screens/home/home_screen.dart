// Created by Lailatul Fitaliqoh (5026231229), edited by all member
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/field_model.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/widgets/field_card.dart';
import 'package:tekber7/screens/booking/booking_history_screen.dart';
import 'package:tekber7/services/auth_service.dart';
import 'package:tekber7/screens/home/profile_screen.dart';
import 'package:tekber7/screens/home/all_fields_screen.dart';
import 'field_detail_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // State
  String _selectedCity = 'SBY'; 
  String _selectedFilter = 'Terdekat'; 
  String userName = 'Sobat Olahraga'; 
  List<FieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
    fetchUserProfile();
  }

  Future<void> fetchFields() async {
    setState(() => isLoading = true);
    try {
      dynamic query = Supabase.instance.client.from('fields').select();

      if (_selectedCity == 'SBY') {
        query = query.ilike('address', '%Surabaya%');
      } else if (_selectedCity == 'MLG') {
        query = query.ilike('address', '%Malang%');
      }

      query = query.limit(5); // Limit 5 untuk tampilan home

      final response = await query;
      final data = response as List<dynamic>;
      
      if (mounted) {
        setState(() {
          fields = data.map((json) => FieldModel.fromJson(json)).toList();
          _sortFields(); 
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error fetching fields: $e");
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

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
      _sortFields();
    });
  }

  void _onCityChanged(String? newCity) {
    if (newCity != null) {
      setState(() => _selectedCity = newCity);
      fetchFields(); 
    }
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
          return countB.compareTo(countA); 
        });
        break;
      case 'Terdekat':
        const userLat = -7.2575; 
        const userLng = 112.7521;
        fields.sort((a, b) {
          final distA = (a.latitude - userLat) * (a.latitude - userLat) + (a.longitude - userLng) * (a.longitude - userLng);
          final distB = (b.latitude - userLat) * (b.latitude - userLat) + (b.longitude - userLng) * (b.longitude - userLng);
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
        selectedCity: _selectedCity,
        onFilterChanged: _onFilterChanged,
        onCityChanged: _onCityChanged,
      ),
      AllFieldsScreen(initialCity: _selectedCity, initialFilter: 'Terdekat'),
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
        onTap: (index) => setState(() => _selectedIndex = index),
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

class HomeContent extends StatelessWidget {
  final List<FieldModel> fields;
  final bool isLoading;
  final String userName;
  final String selectedFilter;
  final String selectedCity;
  final Function(String) onFilterChanged;
  final Function(String?) onCityChanged;

  const HomeContent({
    super.key, 
    required this.fields, 
    required this.isLoading,
    required this.userName,
    required this.selectedFilter,
    required this.selectedCity,
    required this.onFilterChanged,
    required this.onCityChanged,
  });

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                  const SizedBox(width: 12),
                  Text('Halo, $userName', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                ]),
                const SizedBox(height: 24),
                const Text('Mau sewa lapangan\ndimana ?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search, // Ubah tombol keyboard jadi 'Search'
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            // Pindah halaman bawa data search dan kota
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllFieldsScreen(
                                  initialCity: selectedCity, // Bawa filter kota yang sedang aktif
                                  initialFilter: selectedFilter,
                                  initialSearch: value, // Bawa kata kunci pencarian
                                ),
                              ),
                            );
                          }
                        },
                        // -----------------------------
                        decoration: InputDecoration(
                          hintText: 'Cari Lapangan di ${selectedCity == "SBY" ? "Surabaya" : "Malang"}',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2B2930),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF2B2930), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCity,
                          dropdownColor: const Color(0xFF2B2930),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          onChanged: onCityChanged, 
                          items: const [
                            DropdownMenuItem(value: 'SBY', child: Text("SBY")),
                            DropdownMenuItem(value: 'MLG', child: Text("MLG")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rekomendasi untuk kamu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllFieldsScreen(
                          initialCity: selectedCity,
                          initialFilter: selectedFilter,
                        ),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua >', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
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
                                  builder: (context) => FieldDetailScreen(fieldId: field.id),
                                ),
                              );
                            },
                            child: FieldCard(field: field)
                          );
                        },
                      ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = selectedFilter == label;
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