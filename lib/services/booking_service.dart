import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // BAGIAN 1: AMBIL DATA & BUAT BARU
  // ============================================================

  // TAMBAHKAN INI: Agar bisa buat booking baru
  Future<void> createBooking(BookingModel booking) async {
    try {
      final data = booking.toJson();
      data.remove('id'); // Supabase akan generate UUID otomatis
      data['status'] = 'confirmed'; 
      await _supabase.from('bookings').insert(data);
    } catch (e) {
      print("Error create booking: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getBookingDetail(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, fields(name), users(name, phone_number)') 
          .eq('id', bookingId)
          .single();
      return response;
    } catch (e) {
      print("Error ambil detail: $e");
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('renter_id', userId)
          .order('booking_date', ascending: false);

      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      print("Error Get Bookings: $e");
      return [];
    }
  }

  // ============================================================
  // BAGIAN 2: FITUR RESCHEDULE (LOGIKA KAMU)
  // ============================================================

  Future<void> updateBookingSchedule(String bookingId, DateTime newDate, String startTime, String endTime) async {
    try {
      await _supabase.from('bookings').update({
        // Gunakan .split('T')[0] agar format di DB tetap YYYY-MM-DD
        'booking_date': newDate.toIso8601String().split('T')[0], 
        'start_time': startTime,
        'end_time': endTime,
        'status': 'confirmed',
      }).eq('id', bookingId);

      print("Berhasil reschedule booking ID: $bookingId");
    } catch (e) {
      print("Error updateBookingSchedule: $e");
      throw Exception("Gagal memperbarui jadwal: $e");
    }
  }

  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0])
          .neq('status', 'cancelled');

      return (response as List).isEmpty; 
    } catch (e) {
      return false;
    }
  }
  Future<void> cancelBooking({
    required String bookingId, 
    required String reason, 
    required double refundAmount
  }) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'refund_amount': refundAmount,
      }).eq('id', bookingId);
    } catch (e) {
      throw Exception("Gagal membatalkan pesanan: $e");
    }
  }

  // ============================================================
  // BAGIAN 3: PEMBAYARAN
  // ============================================================

  Future<void> confirmPaymentMock(String bookingId, String paymentMethod) async {
    try {
      String dbMethod = 'transfer';
      if (paymentMethod.contains('BCA')) dbMethod = 'transfer_bca';
      if (paymentMethod.contains('Dana')) dbMethod = 'ewallet_dana';
      if (paymentMethod.contains('QRIS')) dbMethod = 'qris';

      await _supabase.from('bookings').update({
        'status': 'confirmed', 
        'payment_proof': 'confirmed_by_mock_system', 
        'payment_method': dbMethod,
      }).eq('id', bookingId);
    } catch (e) {
      print("Error Payment Mock: $e");
      rethrow;
    }
  }

  Future<void> submitPaymentWithUpload(String bookingId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$bookingId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'payment_proofs/$fileName';

      await _supabase.storage.from('booking_assets').upload(filePath, imageFile);
      final imageUrl = _supabase.storage.from('booking_assets').getPublicUrl(filePath);

      await _supabase.from('bookings').update({
        'payment_proof': imageUrl,
        'status': 'confirmed',
        'payment_method': 'transfer',
      }).eq('id', bookingId);
    } catch (e) {
      print("Error Payment Upload: $e");
      rethrow;
    }
  }
}