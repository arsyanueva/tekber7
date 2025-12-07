import 'package:flutter/material.dart';
import 'package:tekber7/utils/app_colors.dart';
import 'package:tekber7/routes/app_routes.dart';

// Class Model Sederhana untuk History
class BookingHistoryItem {
  final String id;
  final String fieldName;
  final String fieldId;
  final String date;
  final String time;
  final String courtName;

  BookingHistoryItem({
    required this.id,
    required this.fieldName,
    required this.fieldId,
    required this.date,
    required this.time,
    required this.courtName,
  });
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data menggunakan Object Class
    final List<BookingHistoryItem> history = [
      BookingHistoryItem(
        id: 'booking-001',
        fieldName: 'Baskhara Futsal Arena',
        fieldId: 'field-123',
        date: 'Sabtu, 15 Juni 2024',
        time: 'Pukul 18.00',
        courtName: 'Lapangan 2',
      )
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Penyewaan lapangan anda', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, 
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return _buildHistoryCard(context, item);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, BookingHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC700),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header Kartu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(item.fieldName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          
          // Body Kartu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.sports_soccer, size: 40),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.courtName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${item.date} - ${item.time}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                // Tombol Review
                ElevatedButton(
                  onPressed: () {
                    // PERBAIKAN: Gunakan dot notation (.id), bukan ['id']
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addReview,
                      arguments: {
                        'bookingId': item.id,       // Benar: item.id
                        'fieldId': item.fieldId,    // Benar: item.fieldId
                        'fieldName': item.fieldName,// Benar: item.fieldName
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Beri Review', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}