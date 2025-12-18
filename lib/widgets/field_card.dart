//Lailatul Fitaliqoh (5026231229)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/field_model.dart';
import '../utils/app_colors.dart';

class FieldCard extends StatefulWidget {
  final FieldModel field;

  const FieldCard({super.key, required this.field});

  @override
  State<FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<FieldCard> {
  // State untuk menyimpan rating
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRating(); // Ambil rating saat kartu dibuat
  }

  // Fungsi Hitung Rating per Lapangan
  Future<void> _fetchRating() async {
    try {
      final supabase = Supabase.instance.client;

      // Ambil kolom rating dari reviews khusus untuk lapangan
      final response = await supabase
          .from('reviews')
          .select('rating')
          .eq('field_id', widget.field.id ?? '');

      final data = response as List<dynamic>;

      if (data.isNotEmpty) {
        final int totalStars = data.fold(0, (sum, item) => sum + (item['rating'] as int));
        final double avg = totalStars / data.length;

        if (mounted) {
          setState(() {
            _reviewCount = data.length;
            _averageRating = double.parse(avg.toStringAsFixed(1)); // Ambil 1 desimal
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Format Rupiah
  String formatCurrency(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Lebar kartu
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GAMBAR LAPANGAN
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.field.imageUrl ?? 'https://via.placeholder.com/300x150',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 140,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),

          // 2. INFO LAPANGAN
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Lapangan
                Text(
                  widget.field.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.darkBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Lokasi / Alamat Singkat
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.field.address ?? 'Surabaya',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating & Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tampilan Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          _reviewCount > 0 ? '$_averageRating' : 'New',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_reviewCount > 0)
                          Text(
                            ' ($_reviewCount)',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),

                    // Tampilan Harga
                    Text(
                      "${formatCurrency(widget.field.pricePerHour)}/jam",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBackground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}