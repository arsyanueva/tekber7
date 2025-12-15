import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/routes/app_routes.dart';
import 'package:tekber7/screens/home/field_detail_screen.dart'; 

// --- MODEL DATA ---
class BookingHistoryItem {
  final String id;
  final String fieldId;
  final String fieldName;
  final String date;
  final String time;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  BookingHistoryItem({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.date,
    required this.time,
    required this.status,
  });
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  // List penampung data dari Database
  List<BookingHistoryItem> upcomingList = []; // Status: pending, confirmed
  List<BookingHistoryItem> historyList = [];  // Status: completed, cancelled
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  // --- FUNGSI AMBIL DATA DARI SUPABASE ---
  Future<void> _fetchBookingData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await supabase
          .from('bookings')
          .select('*, fields(name)') 
          .eq('renter_id', user.id)
          .order('booking_date', ascending: false);

      final data = response as List<dynamic>;

      List<BookingHistoryItem> tempUpcoming = [];
      List<BookingHistoryItem> tempHistory = [];

      for (var item in data) {
        final fieldData = item['fields'];
        final String nameOfField = fieldData != null ? fieldData['name'] : 'Lapangan Tidak Dikenal';

        DateTime bookingDate;
        try {
          bookingDate = DateTime.parse(item['booking_date']);
        } catch (e) {
          bookingDate = DateTime.now();
        }
        final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(bookingDate);

        final String startTime = (item['start_time'] ?? '00:00').toString().substring(0, 5);
        final String endTime = (item['end_time'] ?? '00:00').toString().substring(0, 5);
        
        final String status = item['status'] ?? 'pending';

        final bookingItem = BookingHistoryItem(
          id: item['id'],
          fieldId: item['field_id'],
          fieldName: nameOfField,
          date: formattedDate,
          time: '$startTime - $endTime',
          status: status,
        );

        if (status == 'pending' || status == 'confirmed') {
          tempUpcoming.add(bookingItem);
        } else {
          tempHistory.add(bookingItem);
        }
      }

      if (mounted) {
        setState(() {
          upcomingList = tempUpcoming;
          historyList = tempHistory;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching booking data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFFFFC700),
                indicatorWeight: 3,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Pemesanan Berlangsung"),
                  Tab(text: "Riwayat Pemesanan"),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildListContent(upcomingList, isHistoryTab: false),
                  _buildListContent(historyList, isHistoryTab: true),
                ],
              ),
      ),
    );
  }

  Widget _buildListContent(List<BookingHistoryItem> items, {required bool isHistoryTab}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistoryTab ? Icons.history : Icons.calendar_today_outlined, 
              size: 60, 
              color: Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              isHistoryTab ? 'Belum ada riwayat booking.' : 'Tidak ada booking aktif.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(context, items[index], isHistoryTab);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingHistoryItem item, bool isHistoryTab) {
    Color statusColor = Colors.orange;
    if (item.status == 'confirmed') statusColor = Colors.green;
    if (item.status == 'completed') statusColor = Colors.blue;
    if (item.status == 'cancelled') statusColor = Colors.red;

    return GestureDetector(
      onTap: () {
        // Navigasi ke FieldDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetailScreen(fieldId: item.fieldId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC700),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER KARTU
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.fieldName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // BODY KARTU
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.sports_soccer, size: 30),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.fieldName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(item.date, style: const TextStyle(fontSize: 12)),
                        Text(item.time, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  // Tombol Aksi (Review / Chat)
                  if (isHistoryTab)
                    ElevatedButton(
                      onPressed: item.status == 'completed'
                          ? () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addReview,
                                arguments: {
                                  'bookingId': item.id,
                                  'fieldId': item.fieldId,
                                  'fieldName': item.fieldName,
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Beri Review', style: TextStyle(fontSize: 11)),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Fitur Chat Penyewa belum tersedia")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Chat Penyewa', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}