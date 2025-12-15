import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/utils/app_colors.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  
  // Data Lapangan
  Map<String, dynamic>? fieldData;
  List<String> facilitiesList = [];

  // Data Review
  List<Map<String, dynamic>> reviewsList = [];
  double averageRating = 0.0;
  int reviewCount = 0;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Ambil Detail Lapangan
      final fieldResponse = await supabase
          .from('fields')
          .select()
          .eq('id', widget.fieldId)
          .single();

      // 2. Ambil Review + Data User (Join)
      final reviewsResponse = await supabase
          .from('reviews')
          .select('*, users(name, profile_picture)')
          .eq('field_id', widget.fieldId)
          .order('created_at', ascending: false);

      // --- OLAH DATA ---
      final fData = fieldResponse;
      
      // Parse fasilitas (pisahkan dengan koma)
      final String rawFacilities = fData['facilities'] ?? '';
      final List<String> fList = rawFacilities.isNotEmpty 
          ? rawFacilities.split(',').map((e) => e.trim()).toList() 
          : [];

      // Hitung Rating
      final rList = List<Map<String, dynamic>>.from(reviewsResponse);
      double totalRating = 0;
      if (rList.isNotEmpty) {
        for (var r in rList) {
          totalRating += (r['rating'] as num).toDouble();
        }
        averageRating = totalRating / rList.length;
      }

      if (mounted) {
        setState(() {
          fieldData = fData;
          facilitiesList = fList;
          reviewsList = rList;
          reviewCount = rList.length;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching detail: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper format rupiah
  String formatCurrency(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    // Loading State
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika data tidak ditemukan
    if (fieldData == null) {
      return const Scaffold(body: Center(child: Text("Data lapangan tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. GAMBAR HEADER (Background)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300, // Tinggi gambar
            child: Image.network(
              fieldData!['image_url'] ?? 'https://via.placeholder.com/400x300', // Gambar dummy jika null
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stackTrace) => Container(color: Colors.grey),
            ),
          ),

          // Tombol Back & Share di atas gambar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // (Opsional) Tombol Share/Love bisa ditambah disini
              ],
            ),
          ),

          // 2. KONTEN UTAMA (Sheet Putih Melengkung)
          Positioned.fill(
            top: 220, // Mulai menimpa gambar sedikit
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // --- HEADER INFO ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul & Jarak
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fieldData!['name'],
                                style: const TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBackground,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC700),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '7.7 km', // Hardcode jarak (karena butuh GPS real)
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Rating & Diskon
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${averageRating.toStringAsFixed(1)} ($reviewCount)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.verified, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            const Text('10% Discount area', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Alamat
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fieldData!['address'] ?? 'Alamat tidak tersedia',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Buka Google Maps
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buka Google Maps...")));
                                    },
                                    child: const Text(
                                      "Buka di Google Maps",
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- TAB BAR ---
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.darkBackground,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFFFFC700),
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: "Fasilitas"),
                            Tab(text: "Review"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- TAB VIEW CONTENT ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // TAB 1: FASILITAS
                        _buildFacilitiesTab(),

                        // TAB 2: REVIEW
                        _buildReviewsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. BOTTOM BAR (Harga & Tombol Sewa)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Harga lapangan perjam", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  formatCurrency(fieldData!['price_per_hour']),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBackground),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Arahkan ke halaman Booking form
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lanjut ke Booking...")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Sewa Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TAB: FASILITAS ---
  Widget _buildFacilitiesTab() {
    if (facilitiesList.isEmpty) {
      return const Center(child: Text("Belum ada data fasilitas"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: facilitiesList.length,
      itemBuilder: (context, index) {
        final item = facilitiesList[index];
        // Kita pakai icon statis untuk semua fasilitas karena stringnya dinamis
        // (Untuk icon dinamis butuh logic if/else yang panjang: if item=='Wifi' return IconWifi)
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.darkBackground, size: 20),
              ),
              const SizedBox(width: 16),
              Text(item, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET TAB: REVIEW ---
  Widget _buildReviewsTab() {
    if (reviewsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text("Belum ada review", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: reviewsList.length,
      itemBuilder: (context, index) {
        final review = reviewsList[index];
        final user = review['users']; // Data user hasil join
        final userName = user != null ? user['name'] ?? 'Anonim' : 'Anonim';
        final userPic = user != null ? user['profile_picture'] : null;
        final rating = review['rating'] ?? 0;
        final comment = review['comment'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: userPic != null 
                    ? NetworkImage(userPic) 
                    : const NetworkImage('https://i.pravatar.cc/100'),
              ),
              const SizedBox(width: 12),
              // Isi Review
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text('$rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Komentar
                    Text(comment, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}