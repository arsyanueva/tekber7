import 'dart:io';
import 'package:flutter/material.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // BAGIAN 1: CREATE (BUAT BOOKING BARU)
  // ============================================================

  Future<void> createBooking(BookingModel booking) async {
    try {
      final data = booking.toJson();
      
      data.remove('id'); 
      data.remove('fields'); 
      data.remove('field_name'); 

      data['status'] = 'confirmed'; 

      await _supabase.from('bookings').insert(data);
      
    } catch (e) {
      debugPrint("Error create booking: $e");
      rethrow; 
    }
  }

  // ============================================================
  // BAGIAN 2: READ (AMBIL DATA)
  // ============================================================

  Future<Map<String, dynamic>?> getBookingDetail(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, fields(name), users(name, phone_number)') 
          .eq('id', bookingId)
          .single();
      return response;
    } catch (e) {
      debugPrint("Error ambil detail: $e");
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      final response = await _supabase
          .from('bookings')
          .select('*, fields(name, image_url, address)') 
          .eq('renter_id', userId)
          .order('booking_date', ascending: false); 

      return (response as List).map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error Get Bookings: $e");
      return [];
    }
  }

  // ============================================================
  // BAGIAN 3: RESCHEDULE & AVAILABILITY
  // ============================================================

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
      debugPrint("Error Check Slot: $e");
      return false; 
    }
  }

  Future<bool> rescheduleBooking({
    required String bookingId,
    required String fieldId,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      await _supabase.from('bookings').update({
        'booking_date': newDate.toIso8601String().split('T')[0],
        'start_time': newStartTime,
        'end_time': newEndTime,
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'confirmed',
      }).eq('id', bookingId);

      return true; 

    } catch (e) {
      debugPrint("Error Reschedule: $e");
      rethrow;
    }
  }

  // ============================================================
  // BAGIAN 4: PAYMENT & CANCEL
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
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint("Error Payment Mock: $e");
      rethrow;
    }
  }

  Future<void> submitPayment(String bookingId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$bookingId-payment.$fileExt'; 
      final filePath = 'payment_proofs/$fileName';

      await _supabase.storage.from('booking_assets').upload(filePath, imageFile);
      final imageUrl = _supabase.storage.from('booking_assets').getPublicUrl(filePath);

      await _supabase.from('bookings').update({
        'payment_proof': imageUrl,
        'status': 'confirmed', 
        'payment_method': 'transfer',
      }).eq('id', bookingId);

    } catch (e) {
      debugPrint("Error Payment: $e");
      rethrow;
    }
  }

  Future<void> cancelBooking({
    required String bookingId, 
    required String reason, 
    double refundAmount = 0
  }) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
      }).eq('id', bookingId);
    } catch (e) {
      throw Exception("Gagal membatalkan pesanan: $e");
    }
  }
}