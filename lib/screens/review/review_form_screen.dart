import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/review_model.dart';
import 'package:tekber7/services/review_service.dart';
import 'package:tekber7/utils/app_colors.dart';
class ReviewFormScreen extends StatefulWidget {
  final String bookingId;
  final String fieldId;
  final String fieldName; // Untuk ditampilkan di header

  const ReviewFormScreen({
    super.key,
    required this.bookingId,
    required this.fieldId,
    required this.fieldName,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final ReviewService _reviewService = ReviewService();
  bool _isLoading = false;

  void _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon berikan rating bintang')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      final review = ReviewModel(
        bookingId: widget.bookingId,
        fieldId: widget.fieldId,
        renterId: user.id,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      await _reviewService.submitReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil dikirim!')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Nama Lapangan & Badge Diskon (Visual dummy sesuai gambar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.fieldName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBackground,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC700), // Kuning
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '7.7 km',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Rating Lapangan (Static info)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text('4.8 (40)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.verified, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                const Text('10% Discount area', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // User Info
            const Row(
              children: [
                 CircleAvatar(
                   backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                   radius: 16,
                 ),
                 SizedBox(width: 12),
                 Text(
                   'Daniel',
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                 ),
              ],
            ),
            const SizedBox(height: 24),

            // Input Bintang
            const Text('Beri Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            // Input Text Review
            const Text('Beri Review', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Masukkan pengalaman anda',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Posting
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Posting',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}