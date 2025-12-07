import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();
  
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String fieldId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await _service.getReviewsByField(fieldId);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(String bookingId, String fieldId, int rating, String comment) async {
    await _service.postReview(bookingId, fieldId, rating, comment);
    await fetchReviews(fieldId); // Refresh data
  }

  Future<void> replyReview(String reviewId, String reply, String fieldId) async {
    await _service.replyReview(reviewId, reply);
    await fetchReviews(fieldId); // Refresh data
  }
}