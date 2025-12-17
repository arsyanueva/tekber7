class ReviewModel {
  final String? id;
  final String bookingId;
  final String fieldId;
  final String renterId;
  final int rating;
  final String comment;
  final String? ownerReply;
  final String? renterName;
  final String? renterAvatarUrl;
  final DateTime? createdAt;

  ReviewModel({
    this.id, 
    required this.bookingId,
    required this.fieldId,
    required this.renterId,
    required this.rating,
    required this.comment,    
    this.ownerReply,
    this.renterName,
    this.renterAvatarUrl,
    this.createdAt,
  });

  // Konversi data ke JSON untuk dikirim ke Supabase (Create Review)
  Map<String, dynamic> toJson() {
    return {
      // ID jangan dikirim saat insert
      'booking_id': bookingId,
      'field_id': fieldId,
      'renter_id': renterId,
      'rating': rating,
      'comment': comment,
    };
  }

  // Factory untuk mengubah JSON dari Supabase menjadi object (Read Review)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'] ?? '',
      fieldId: json['field_id'] ?? '',
      renterId: json['renter_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',      
      ownerReply: json['owner_reply'], 
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      renterName: json['users'] != null ? json['users']['name'] : 'User',
      renterAvatarUrl: json['users'] != null ? json['users']['profile_picture'] : null,
    );
  }
}