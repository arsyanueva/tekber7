import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tekber7/models/review_model.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Method untuk POST review (Digunakan oleh Provider & Screen)
  Future<void> submitReview(ReviewModel review) async {
    await _supabase.from('reviews').insert(review.toJson());
  }

  // 2. Method postReview (Alias untuk submitReview agar cocok dengan Provider Anda)
  Future<void> postReview(String bookingId, String fieldId, int rating, String comment) async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? 'dummy-user-id'; // Handle null user

    final review = ReviewModel(
      bookingId: bookingId,
      fieldId: fieldId,
      renterId: userId,
      rating: rating,
      comment: comment,
    );
    
    await submitReview(review);
  }

  // 3. Method getReviewsByField (Dicari oleh Provider)
  Future<List<ReviewModel>> getReviewsByField(String fieldId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('field_id', fieldId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      // Return empty list jika error atau data kosong
      return [];
    }
  }

  // 4. Method replyReview (Dicari oleh Provider)
  Future<void> replyReview(String reviewId, String reply) async {
    await _supabase
        .from('reviews')
        .update({'owner_reply': reply})
        .eq('id', reviewId);
  }
}