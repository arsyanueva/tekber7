import 'dart:io';
import 'package:flutter/material.dart'; // Buat debugPrint
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
      
      // HAPUS ID DARI DATA YANG DIKIRIM
      // Biar Supabase yang bikinin UUID otomatis yang valid
      data.remove('id'); 
      data.remove('fields'); // Hapus data joinan kalo ada
      data.remove('field_name'); // Hapus data helper

      // Pastikan statusnya udah 'confirmed'
      data['status'] = 'confirmed'; 

      // Kirim ke database (Insert)
      await _supabase.from('bookings').insert(data);
      
    } catch (e) {
      debugPrint("Error create booking: $e");
      rethrow; 
    }
  }

  // ============================================================
  // BAGIAN 2: READ (AMBIL DATA)
  // ============================================================

  // Ambil Detail Booking Spesifik
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

  // Ambil List Booking User (History) dengan JOIN ke tabel Fields
  // Return List<BookingModel> biar konsisten sama UI kamu yang pake Model
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      // Kita pake .select('*, fields(*)') buat JOIN ke tabel fields
      final response = await _supabase
          .from('bookings')
          .select('*, fields(name, image_url, address)') 
          .eq('renter_id', userId)
          .order('booking_date', ascending: false); 

      // Convert response ke List<BookingModel>
      // Pastikan BookingModel.fromJson kamu sudah support parsing 'fields'['name']
      return (response as List).map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error Get Bookings: $e");
      return [];
    }
  }

  // ============================================================
  // BAGIAN 3: RESCHEDULE & AVAILABILITY
  // ============================================================

  // Cek Slot Kosong
  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0]) 
          .neq('status', 'cancelled'); 

      // Logic sederhana: kalau ada booking di hari itu, return false (perlu diperketat logic jam-nya nanti)
      // Tapi sementara ini cukup untuk cek tanggal
      return (response as List).isEmpty; 
    } catch (e) {
      debugPrint("Error Check Slot: $e");
      return false; 
    }
  }

  // Proses Reschedule
  Future<bool> rescheduleBooking({
    required String bookingId,
    required String fieldId,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      // 1. Cek slot baru kosong gak?
      // Note: Logic isSlotAvailable di atas masih basic (cek per hari). 
      // Kalau mau lebih canggih, logic jam harus ditambah.
      // bool isAvailable = await isSlotAvailable(fieldId, newDate, newStartTime, newEndTime);
      // if (!isAvailable) return false; 

      // 2. Update data booking
      await _supabase.from('bookings').update({
        'booking_date': newDate.toIso8601String().split('T')[0],
        'start_time': newStartTime,
        'end_time': newEndTime,
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'confirmed', // atau 'pending' tergantung kebijakan
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

  // Pembayaran Mock (Tanpa Upload - Pilihan "Saya Sudah Transfer")
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

  // Pembayaran Real (Dengan Upload Bukti)
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

  // Batalkan Pesanan
  Future<void> cancelBooking({
    required String bookingId, 
    required String reason, 
    double refundAmount = 0
  }) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
        // Pastikan kolom ini ada di DB kamu, kalau gak ada di-komen aja
        // 'cancellation_reason': reason,
        // 'refund_amount': refundAmount,
      }).eq('id', bookingId);
    } catch (e) {
      throw Exception("Gagal membatalkan pesanan: $e");
    }
  }
}