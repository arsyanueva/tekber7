class BookingModel {
  final String id;
  final String fieldId;
  final String renterId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalPrice;
  final String status;
  final String? paymentMethod;
  final DateTime createdAt;
  final String? fieldName; 

  BookingModel({
    required this.id,
    required this.fieldId,
    required this.renterId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    this.fieldName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? extractedFieldName;
    if (json['fields'] != null) {
      extractedFieldName = json['fields']['name'];
    }

    return BookingModel(
      id: json['id'] ?? '',
      fieldId: json['field_id'] ?? '',
      renterId: json['renter_id'] ?? '',
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: (json['start_time'] ?? '00:00').toString().substring(0, 5), 
      endTime: (json['end_time'] ?? '00:00').toString().substring(0, 5),
      totalPrice: json['total_price'] is int ? json['total_price'] : int.tryParse(json['total_price'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      fieldName: extractedFieldName, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'renter_id': renterId,
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }
}