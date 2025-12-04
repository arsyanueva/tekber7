class ReviewModel {
  final String id;
  final String bookingId;
  final String fieldId;
  final String renterId;
  final int rating; // 1 - 5
  final String comment;
  final String? ownerReply; // Jawaban pemilik (bisa null kalau belum dijawab)
  final DateTime createdAt; // Penting buat nampilin "Ulasan 2 hari yang lalu"

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.fieldId,
    required this.renterId,
    required this.rating,
    required this.comment,
    this.ownerReply,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      fieldId: json['field_id'] ?? '',
      renterId: json['renter_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      ownerReply: json['owner_reply'], // Bisa null
      createdAt: DateTime.parse(json['created_at']), // Supabase formatnya ISO8601
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'field_id': fieldId,
      'renter_id': renterId,
      'rating': rating,
      'comment': comment,
      'owner_reply': ownerReply,
      // 'created_at' biasanya otomatis diisi Supabase pas insert
    };
  }
}