class BookingModel {
  final String id;
  final String fieldId;
  final String renterId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'
  
  // [BARU] Tambahan biar error ilang
  final String? paymentMethod; 
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.fieldId,
    required this.renterId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    // [BARU] Masukin ke constructor
    this.paymentMethod,
    this.createdAt,
  });

  // Convert dari JSON (Supabase) ke Object Flutter
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      fieldId: json['field_id'] ?? '',
      renterId: json['renter_id'] ?? '',
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalPrice: json['total_price'] ?? 0,
      status: json['status'] ?? 'pending',
      // [BARU] Ambil dari JSON
      paymentMethod: json['payment_method'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Convert dari Object Flutter ke JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      // 'id' biasanya digenerate otomatis sama Supabase, jadi opsional dikirim
      'field_id': fieldId,
      'renter_id': renterId,
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
      // [BARU] Kirim ke JSON
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}