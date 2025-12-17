import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/utils/app_colors.dart';

import 'package:tekber7/screens/booking/booking_summary_screen.dart'; 
import 'package:tekber7/widgets/review_list_section.dart'; 

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
  double averageRating = 0.0;
  int reviewCount = 0;

  // Tab Controller
  late TabController _tabController;

  // DATA JAM OPERASIONAL
  final List<String> timeSlots = [
    "08.00 - 09.00", "09.00 - 10.00", "10.00 - 11.00",
    "11.00 - 12.00", "13.00 - 14.00", "14.00 - 15.00",
    "15.00 - 16.00", "16.00 - 17.00", "17.00 - 18.00",
    "18.00 - 19.00", "19.00 - 20.00", "20.00 - 21.00"
  ];

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

      final fieldResponse = await supabase
          .from('fields')
          .select()
          .eq('id', widget.fieldId)
          .single();

      final reviewsResponse = await supabase
          .from('reviews')
          .select('rating')
          .eq('field_id', widget.fieldId);

      final fData = fieldResponse;
      
      final String rawFacilities = fData['facilities'] ?? '';
      final List<String> fList = rawFacilities.isNotEmpty 
          ? rawFacilities.split(',').map((e) => e.trim()).toList() 
          : [];

      final rList = List<Map<String, dynamic>>.from(reviewsResponse);
      double totalRating = 0;
      if (rList.isNotEmpty) {
        for (var r in rList) {
          totalRating += (r['rating'] as num).toDouble();
        }
        averageRating = totalRating / rList.length;
      }
      reviewCount = rList.length;

      if (mounted) {
        setState(() {
          fieldData = fData;
          facilitiesList = fList;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching detail: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  String formatCurrency(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // --- [UPDATE] LOGIC PILIH TANGGAL & JAM ---
  void _showBookingModal() {
    // Default tanggal hari ini
    DateTime tempSelectedDate = DateTime.now();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Biar modal bisa tinggi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Set<String> selectedSlots = {}; 
        
        return StatefulBuilder( 
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 550, // Tinggiin dikit biar muat date picker
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- PILIH TANGGAL (BARU) ---
                  const Text("Tanggal Bermain", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      // Munculin Kalender Bawaan Android/iOS
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempSelectedDate,
                        firstDate: DateTime.now(), // Gaboleh pilih tanggal lampau
                        lastDate: DateTime.now().add(const Duration(days: 30)), // Maksimal 30 hari ke depan
                      );
                      if (picked != null && picked != tempSelectedDate) {
                        setModalState(() {
                          tempSelectedDate = picked;
                          selectedSlots.clear(); // Reset jam kalo ganti tanggal (biar ga error)
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tempSelectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.darkBackground, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  const Text("Pilih Jam", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 10),

                  // GRID PILIHAN JAM (SAMA KAYAK SEBELUMNYA)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 2.5, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = timeSlots[index];
                        final isSelected = selectedSlots.contains(slot);
                        
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedSlots.remove(slot);
                              } else {
                                selectedSlots.add(slot);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.darkBackground : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.darkBackground : Colors.grey.shade300
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Info Total & Tombol
                  if (selectedSlots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${selectedSlots.length} Jam dipilih"),
                          Text(
                            formatCurrency((fieldData!['price_per_hour'] as num) * selectedSlots.length),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBackground),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (selectedSlots.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih minimal 1 jam bos!")));
                          return;
                        }

                        // --- VALIDASI URUTAN JAM (COPY PASTE YANG LAMA) ---
                        List<int> indexes = selectedSlots.map((slot) => timeSlots.indexOf(slot)).toList();
                        indexes.sort();
                        bool isConsecutive = true;
                        for (int i = 0; i < indexes.length - 1; i++) {
                          if (indexes[i + 1] != indexes[i] + 1) {
                            isConsecutive = false;
                            break;
                          }
                        }
                        if (!isConsecutive) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jam harus berurutan!"), backgroundColor: Colors.red));
                          return;
                        }

                        // --- OLAH DATA AKHIR ---
                        String firstSlot = timeSlots[indexes.first];
                        String lastSlot = timeSlots[indexes.last];
                        String startTime = firstSlot.split(" - ")[0];
                        String endTime = lastSlot.split(" - ")[1];
                        String finalTimeRange = "$startTime - $endTime";
                        int totalPrice = (fieldData!['price_per_hour'] as num).toInt() * selectedSlots.length;

                        Navigator.pop(context);

                        // KIRIM DATA (TERMASUK TANGGAL YANG DIPILIH)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingSummaryScreen(
                              fieldId: widget.fieldId,
                              fieldName: fieldData!['name'],
                              fieldLocation: fieldData!['address'] ?? 'Surabaya',
                              fieldImage: fieldData!['image_url'] ?? 'assets/images/placeholder.png',
                              
                              selectedDate: tempSelectedDate, // <--- INI PAKE TANGGAL PILIHAN USER
                              
                              selectedTime: finalTimeRange,
                              price: totalPrice,
                            ),
                          ),
                        );
                      },
                      child: const Text("Lanjut Pembayaran", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.darkBackground)),
      );
    }

    if (fieldData == null) {
      return const Scaffold(body: Center(child: Text("Data lapangan tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. GAMBAR HEADER
          Positioned(
            top: 0, left: 0, right: 0, height: 300,
            child: Image.network(
              fieldData!['image_url'] ?? 'https://via.placeholder.com/400x300',
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stackTrace) => Container(color: Colors.grey),
            ),
          ),

          // Tombol Back
          Positioned(
            top: 40, left: 16, right: 16,
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
              ],
            ),
          ),

          // 2. KONTEN UTAMA
          Positioned.fill(
            top: 220,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fieldData!['name'],
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBackground),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xFFFFC700), borderRadius: BorderRadius.circular(20)),
                              child: const Text('7.7 km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text('${averageRating.toStringAsFixed(1)} ($reviewCount)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            const Icon(Icons.verified, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            const Text('10% Discount area', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fieldData!['address'] ?? 'Alamat tidak tersedia',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

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
                        _buildFacilitiesTab(),
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

      // 3. BOTTOM BAR (TOMBOL SEWA)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
              onPressed: _showBookingModal, 
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

  // --- TAB: FASILITAS ---
  Widget _buildFacilitiesTab() {
    if (facilitiesList.isEmpty) return const Center(child: Text("Belum ada data fasilitas"));
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: facilitiesList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.darkBackground, size: 20),
              const SizedBox(width: 16),
              Text(facilitiesList[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  // --- TAB: REVIEW ---
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      child: ReviewListSection(
        fieldId: widget.fieldId,
        isOwner: true, 
      ),
    );
  }
}