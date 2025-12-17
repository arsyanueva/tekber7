// Rian Chairul Ichsan (5026231121)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/review_model.dart';
import 'package:tekber7/services/review_service.dart';
import 'package:tekber7/utils/app_colors.dart';

class ReviewFormScreen extends StatefulWidget {
  final String bookingId;
  final String fieldId;
  final String fieldName;

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
  // State Form Input
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final ReviewService _reviewService = ReviewService();
  bool _isLoading = false;

  // State Data User (Penyewa)
  String _userName = 'Memuat...'; 
  String? _userPhotoUrl;

  // State Data Rating Lapangan (Average)
  double _averageRating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();   
    _fetchFieldRating(); 
  }

  // 1. Fungsi Ambil Data User (
  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final data = await supabase
            .from('users')
            .select('name, profile_picture')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _userName = data['name'] ?? user.email ?? 'Pengguna';
            _userPhotoUrl = data['profile_picture'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // 2. Fungsi Hitung Rating Rata-rata dari Database
  Future<void> _fetchFieldRating() async {
    try {
      final supabase = Supabase.instance.client;

      // Validasi ID
      if (widget.fieldId.isEmpty) return;

      final response = await supabase
          .from('reviews')
          .select('rating')
          .eq('field_id', widget.fieldId);

      final data = response as List<dynamic>;

      if (data.isNotEmpty) {
        // Hitung total & rata-rata
        final int totalStars = data.fold(0, (sum, item) => sum + (item['rating'] as int));
        final double avg = totalStars / data.length;

        if (mounted) {
          setState(() {
            _reviewCount = data.length;
            _averageRating = double.parse(avg.toStringAsFixed(1));
          });
        }
      }
    } catch (e) {
      //  debugPrint untuk error log 
      debugPrint('Error fetching rating: $e');
    }
  }

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

      // PERBAIKAN: Tidak perlu isi ID dan CreatedAt
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
        Navigator.pop(context);
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
    // Gunakan kembali kode UI layout kamu yang sudah bagus
    // Bagian Logika di atas yang paling penting
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
            // Header Nama Lapangan & Jarak
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
                    color: const Color(0xFFFFC700),
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
            
            // --- BAGIAN RATING DINAMIS ---
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                // Tampilkan Rating Hasil Hitungan
                Text(
                  _reviewCount > 0 
                      ? '$_averageRating ($_reviewCount)' // Contoh: 4.5 (12)
                      : 'Belum ada rating',               // Jika kosong
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 12),
                
                // Badge Diskon (Masih Statis/Hardcode tidak apa2)
                const Icon(Icons.verified, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                const Text('10% Discount area', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // --- USER INFO ---
            Row(
              children: [
                 CircleAvatar(
                   backgroundImage: _userPhotoUrl != null 
                      ? NetworkImage(_userPhotoUrl!) 
                      : const NetworkImage('https://i.pravatar.cc/100'),
                   radius: 16,
                 ),
                 const SizedBox(width: 12),
                 Text(
                   _userName, 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  onPressed: () => setState(() => _selectedRating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('Beri Review', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Masukkan pengalaman anda',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Posting', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}