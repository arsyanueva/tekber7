// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/services/auth_service.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/screens/home/profile_screen.dart';
import 'package:tekber7/screens/home/field_detail_screen.dart';

// --- MODEL SEDERHANA UNTUK BOOKING ---
class OwnerBookingModel {
  final String fieldName;
  final String courtName;
  final String date;
  final String time;

  OwnerBookingModel({
    required this.fieldName,
    required this.courtName,
    required this.date,
    required this.time,
  });
}

// --- MODEL SEDERHANA UNTUK MY FIELD ---
class MyFieldModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final num price;
  final num rating;

  MyFieldModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });

  factory MyFieldModel.fromJson(Map<String, dynamic> json) {
    return MyFieldModel(
      id: json['id'],
      name: json['name'] ?? 'Tanpa Nama',
      address: json['address'] ?? '-',
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
      price: json['price_per_hour'] ?? 0,
      rating: json['rating'] ?? 0.0,
    );
  }
}

class HomeOwnerScreen extends StatefulWidget {
  const HomeOwnerScreen({super.key});

  @override
  State<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen> {
  int _selectedIndex = 0;
  String userName = 'Partner Field Master';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final authService = AuthService();
      final userProfile = await authService.getUserProfile();
      if (mounted && userProfile != null) {
        setState(() {
          userName = userProfile['name'] ?? 'Partner';
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  // FIXED: Removed 'const' because the list contains non-const elements (OwnerHomeContent depends on userName variable)
  List<Widget> get _pages {
    return [
      // Tab 1: Beranda Owner
      OwnerHomeContent(userName: userName),
      
      // Tab 2: Lapangan Saya (Kelola Lapangan)
      const OwnerMyFieldsContent(),
      
      // Tab 3: Profil
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkBackground,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Lapangan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: KONTEN BERANDA (DASHBOARD) - UPDATED
// ============================================================================
class OwnerHomeContent extends StatefulWidget {
  final String userName;
  const OwnerHomeContent({super.key, required this.userName});

  @override
  State<OwnerHomeContent> createState() => _OwnerHomeContentState();
}

class _OwnerHomeContentState extends State<OwnerHomeContent> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // Fetch Booking Real dari Supabase
  Future<void> fetchBookings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('bookings')
          // [PENTING] Gunakan !inner untuk melakukan Inner Join agar bisa filter berdasarkan owner di tabel fields
          .select('*, fields!inner(name, owner_id)') 
          
          // Filter: Ambil booking dimana field-nya dimiliki oleh user yang sedang login
          .eq('fields.owner_id', user.id) 
          
          .order('booking_date', ascending: true);

      final data = response as List<dynamic>;

      if (mounted) {
        setState(() {
          bookings = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
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
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                  const SizedBox(width: 12),
                  Text('Halo, ${widget.userName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.notifications, color: Colors.white),
                ]),
                const SizedBox(height: 24),
                const Text('Daftarkan lapangan kamu\ndan dapatkan penghasilan', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.pushNamed(context, '/add-field');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.darkBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Daftar Membership", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. RIWAYAT PENYEWAAN REAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Riwayat Penyewaan', style: TextStyle(fontSize: 16, color: Colors.black87)),
                Text('Lihat Semua >', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookings.isEmpty
              ? const Padding(padding: EdgeInsets.all(24), child: Text("Belum ada penyewaan masuk."))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final fieldName = booking['fields'] != null ? booking['fields']['name'] : 'Lapangan';
                    final date = booking['booking_date'];
                    final time = booking['start_time'].toString().substring(0, 5);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: const BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Text(fieldName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryYellow,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sports_soccer, size: 30),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Jadwal Masuk:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('$date | $time', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 2: LAPANGAN SAYA (MY FIELDS)
// ============================================================================
class OwnerMyFieldsContent extends StatefulWidget {
  const OwnerMyFieldsContent({super.key});

  @override
  State<OwnerMyFieldsContent> createState() => _OwnerMyFieldsContentState();
}

class _OwnerMyFieldsContentState extends State<OwnerMyFieldsContent> {
  List<MyFieldModel> myFields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyFields();
  }

  Future<void> fetchMyFields() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('fields')
          .select()
          .eq('owner_id', user.id);

      final data = response as List<dynamic>;
      
      if (mounted) {
        setState(() {
          myFields = data.map((json) => MyFieldModel.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching my fields: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              color: Colors.white,
              width: double.infinity,
              child: const Text(
                'Lapangan yang dikelola',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBackground),
              ),
            ),
            
            const SizedBox(height: 16),

            isLoading 
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              : myFields.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: myFields.length,
                      itemBuilder: (context, index) {
                        return _buildMyFieldCard(myFields[index]);
                      },
                    ),

            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.pushNamed(context, '/add-field');
                  },
                  icon: const Icon(Icons.add_circle, color: AppColors.darkBackground),
                  label: const Text("Tambahkan Lapangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Belum ada lapangan yang dikelola."),
      ),
    );
  }

  Widget _buildMyFieldCard(MyFieldModel field) {
    return GestureDetector(
      onTap: () {
        // --- [NEW] Navigate to FieldDetailScreen ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetailScreen(
              fieldId: field.id, 
              // fieldId is passed here so FieldDetailScreen can detect ownership
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      field.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Admin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        Text(field.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(field.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' ${field.rating} (40)', style: const TextStyle(fontSize: 12)),
                            const Spacer(),
                            Text('${field.price}k', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('/jam', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Edit Button (Keep existing functionality or logic if needed)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                   // Navigate to Edit Field Screen if you implement it later
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit akan segera hadir!")));
                },
                child: const Text("Edit", style: TextStyle(color: Colors.blue)),
              ),
            )
          ],
        ),
      ),
    );
  }
}