class ReviewModel {
  final String? id;
  final String bookingId;
  final String fieldId;
  final String renterId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  ReviewModel({
    this.id,
    required this.bookingId,
    required this.fieldId,
    required this.renterId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  // Konversi data ke JSON untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'field_id': fieldId,
      'renter_id': renterId,
      'rating': rating,
      'comment': comment,
      // created_at biasanya otomatis diurus oleh database (default now())
    };
  }

  // Factory untuk mengubah JSON dari Supabase menjadi object (jika perlu read)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      fieldId: json['field_id'],
      renterId: json['renter_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}