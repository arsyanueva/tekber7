import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/field_model.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/widgets/field_card.dart';
import 'package:tekber7/screens/booking/booking_history_screen.dart';

// Pastikan file ini ada di folder yang sama/benar
import 'all_fields_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Terdekat'; 
  String _selectedCity = 'SBY'; 

  List<FieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  Future<void> fetchFields() async {
    setState(() => isLoading = true);
    try {
      // Gunakan dynamic agar sorting tidak error
      dynamic query = Supabase.instance.client.from('fields').select();

      if (_selectedCity == 'SBY') {
        query = query.ilike('address', '%Surabaya%');
      } else if (_selectedCity == 'MLG') {
        query = query.ilike('address', '%Malang%');
      }

      if (_selectedFilter == 'Termurah') {
        query = query.order('price_per_hour', ascending: true);
      } else {
        query = query.order('created_at', ascending: false);
      }

      query = query.limit(5);

      final response = await query;
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

  void _onFilterChanged(String newFilter) {
    setState(() => _selectedFilter = newFilter);
    fetchFields();
  }

  void _onCityChanged(String? newCity) {
    if (newCity != null) {
      setState(() => _selectedCity = newCity);
      fetchFields(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(
        fields: fields, 
        isLoading: isLoading,
        selectedFilter: _selectedFilter,
        selectedCity: _selectedCity,      
        onFilterChanged: _onFilterChanged,
        onCityChanged: _onCityChanged,    
      ),
      // Diarahkan ke AllFieldsScreen jika tab Lapangan diklik (Opsional)
      AllFieldsScreen(initialCity: _selectedCity, initialFilter: 'Terdekat'),
      const BookingHistoryScreen(),
      const Center(child: Text('Halaman Profil')),
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
  final String selectedFilter;
  final String selectedCity;
  final Function(String) onFilterChanged;
  final Function(String?) onCityChanged;

  const HomeContent({
    super.key, 
    required this.fields, 
    required this.isLoading,
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
                // const Row ini aman
                const Row(children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                  SizedBox(width: 12),
                  Text('Halo, Daniel', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Spacer(),
                  Icon(Icons.notifications_outlined, color: Colors.white),
                ]),
                const SizedBox(height: 24),
                const Text('Mau sewa lapangan\ndimana ?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // NO CONST HERE (PENTING!)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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
            height: 240,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : fields.isEmpty
                    ? const Center(child: Text('Belum ada data lapangan'))
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
          style: TextStyle(color: isActive ? Colors.white : Colors.black, fontSize: 12),
        ),
      ),
    );
  }
}