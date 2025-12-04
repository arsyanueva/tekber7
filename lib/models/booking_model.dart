class BookingModel {
  final String id;
  final String fieldId;
  final String renterId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalPrice;
  final String status; // pending, confirmed, cancelled, completed

  BookingModel({
    required this.id,
    required this.fieldId,
    required this.renterId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
  });

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'renter_id': renterId,
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
    };
  }
}