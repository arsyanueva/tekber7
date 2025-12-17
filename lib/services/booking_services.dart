import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart'; 

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- [INI FUNGSI YANG HILANG ITU] ---
  Future<void> createBooking(BookingModel booking) async {
    try {
      final data = booking.toJson();
      
      // HAPUS ID BIAR GAK ERROR UUID
      data.remove('id'); 
      
      data['status'] = 'confirmed'; 

      await _supabase.from('bookings').insert(data);
    } catch (e) {
      print("Error create booking: $e");
      rethrow; 
    }
  }

  // --- Helper Cek Slot ---
  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0]) 
          .neq('status', 'cancelled'); 
      return true; 
    } catch (e) {
      return false; 
    }
  }

  // --- Fitur Reschedule ---
  Future<bool> rescheduleBooking({
    required String bookingId,
    required String fieldId,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      bool isAvailable = await isSlotAvailable(fieldId, newDate, newStartTime, newEndTime);
      if (!isAvailable) return false; 

      await _supabase.from('bookings').update({
        'booking_date': newDate.toIso8601String(),
        'start_time': newStartTime,
        'end_time': newEndTime,
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'pending', 
      }).eq('id', bookingId);

      return true; 
    } catch (e) {
      rethrow;
    }
  }

  // --- Fitur Upload Bukti Bayar ---
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
      rethrow;
    }
  }
  
  // --- Ambil Booking User ---
  // --- UPDATE: Ambil List Booking + Data Lapangan ---
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Kita pake .select('*, fields(*)') buat JOIN ke tabel fields
      // Syarat: Di Supabase, kolom 'field_id' di tabel bookings harus punya Foreign Key ke tabel 'fields'
      final response = await _supabase
          .from('bookings')
          .select('*, fields(name, image_url, address)') 
          .eq('renter_id', userId)
          .order('booking_date', ascending: false); 

      // Kita balikin bentuk List<Map> aja biar fleksibel ngambil data field-nya
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error Get Bookings: $e");
      return [];
    }
  }
}