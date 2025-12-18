import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/routes/app_routes.dart';
import 'package:provider/provider.dart'; 
import 'package:tekber7/providers/review_provider.dart'; 
import 'package:tekber7/models/booking_model.dart';
import 'package:tekber7/services/booking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final BookingService _bookingService = BookingService();
  
  List<BookingModel> upcomingList = [];
  List<BookingModel> historyList = [];  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  Future<void> _fetchBookingData() async {
    try {
      final allBookings = await _bookingService.getUserBookings();

      List<BookingModel> tempUpcoming = [];
      List<BookingModel> tempHistory = [];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var item in allBookings) {
        final bookingDay = DateTime(
          item.bookingDate.year, 
          item.bookingDate.month, 
          item.bookingDate.day
        );  

        bool isPast = bookingDay.isBefore(today);

        if ((item.status == 'pending' || item.status == 'confirmed') && !isPast) {
          tempUpcoming.add(item);
        } 
        else {
          tempHistory.add(item);
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

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
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

  Widget _buildListContent(List<BookingModel> items, {required bool isHistoryTab}) {
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

  Widget _buildBookingCard(BuildContext context, BookingModel item, bool isHistoryTab) {
    String displayStatus = item.status.toUpperCase();
    Color statusColor = Colors.orange;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(item.bookingDate.year, item.bookingDate.month, item.bookingDate.day);

    if (bookingDay.isBefore(today) && item.status == 'confirmed') {
      displayStatus = "COMPLETED";
      statusColor = Colors.blue;
    } else {
      if (item.status == 'confirmed') statusColor = Colors.green;
      if (item.status == 'completed') statusColor = Colors.blue;
      if (item.status == 'cancelled') statusColor = Colors.red;
    }

    String finalName = item.fieldName ?? "Lapangan Futsal"; 

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          AppRoutes.bookingDetail,
          arguments: item,
        );
        _fetchBookingData(); 
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
                      finalName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      displayStatus, 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

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
                        Text(finalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_formatDate(item.bookingDate), style: const TextStyle(fontSize: 12)),
                        Text("${item.startTime} - ${item.endTime}", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  if (isHistoryTab)
                    ElevatedButton(
                      onPressed: (item.status == 'completed' || (bookingDay.isBefore(today) && item.status == 'confirmed'))
                          ? () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addReview, 
                                arguments: {
                                  'bookingId': item.id,
                                  'fieldId': item.fieldId,
                                  'fieldName': finalName,
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