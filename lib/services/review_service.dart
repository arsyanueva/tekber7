import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/review_model.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> submitReview(ReviewModel review) async {
    // Insert ke database menggunakan toJson
    await _supabase.from('reviews').insert(review.toJson());
  }

  Future<void> postReview(String bookingId, String fieldId, int rating, String comment) async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? 'dummy-user-id';

    final review = ReviewModel(
      bookingId: bookingId,
      fieldId: fieldId,
      renterId: userId,
      rating: rating,
      comment: comment,
      // createdAt otomatis diisi oleh Model
    );
    
    await submitReview(review);
  }

  Future<List<ReviewModel>> getReviewsByField(String fieldId) async {
    try {
      // Query dengan JOIN ke tabel users untuk ambil nama & foto
      final response = await _supabase
          .from('reviews')
          .select('*, users(name, profile_picture)') 
          .eq('field_id', fieldId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  Future<void> replyReview(String reviewId, String reply) async {
    await _supabase
        .from('reviews')
        .update({'owner_reply': reply})
        .eq('id', reviewId);
  }
}