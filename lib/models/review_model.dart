class ReviewModel {
  final String? id; // Nullable (Boleh kosong saat insert)
  final String bookingId;
  final String fieldId;
  final String renterId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  
  // Data Tambahan untuk UI (Wajib ada biar gak error merah di list)
  final String? ownerReply;
  final String? renterName;
  final String? renterAvatarUrl;

  ReviewModel({
    this.id, 
    required this.bookingId,
    required this.fieldId,
    required this.renterId,
    required this.rating,
    required this.comment,
    DateTime? createdAt, // Opsional
    this.ownerReply,
    this.renterName,
    this.renterAvatarUrl,
  }) : createdAt = createdAt ?? DateTime.now(); // Default waktu sekarang

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString() ?? '',
      fieldId: json['field_id']?.toString() ?? '',
      renterId: json['renter_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      
      // Ambil data tambahan
      ownerReply: json['owner_reply']?.toString(),
      
      // Mengambil data dari relasi tabel users (jika di-join)
      renterName: json['users'] != null ? json['users']['name'] : 'User',
      renterAvatarUrl: json['users'] != null ? json['users']['profile_picture'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ID jangan dikirim saat insert
      'booking_id': bookingId,
      'field_id': fieldId,
      'renter_id': renterId,
      'rating': rating,
      'comment': comment,
      'owner_reply': ownerReply,
    };
  }
}