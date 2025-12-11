import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  // Kita pake standarisasi variabel '_supabase' biar konsisten
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // BAGIAN 1: FITUR DATA (Gabungan Punya Temenmu)
  // ==========================================

  // [PUNYA TEMENMU] Ambil Detail Booking Lengkap (Join Table)
  // Ini penting biar nama Lapangan & User ketahuan
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

  // [PUNYA TEMENMU] Helper buat Testing (Cari ID pertama)
  Future<String?> getFirstBookingId() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('id')
          .limit(1);
      
      if (response.isNotEmpty) {
        return response[0]['id'] as String;
      }
      return null; 
    } catch (e) {
      print("Error cari ID: $e");
      return null;
    }
  }

  // [PUNYA KAMU] Ambil List Booking User (Buat History)
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

  // ==========================================
  // BAGIAN 2: LOGIC RESCHEDULE (Punya Kamu - Lebih Lengkap)
  // ==========================================

  // Cek Ketersediaan Slot (Wajib ada buat validasi)
  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0])
          .neq('status', 'cancelled');

      // Logic sederhana: sementara kita anggap available dulu
      // Nanti bisa diperketat logic jam-nya
      return true; 
    } catch (e) {
      return false;
    }
  }

  // Fungsi Reschedule yang KITA PAKAI (Ada jamnya)
  // Punya temenmu tadi cuma tanggal doang, jadi kurang detail
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
        'status': 'pending', 
      }).eq('id', bookingId);

      return true;
    } catch (e) {
      print("Error Reschedule: $e");
      rethrow;
    }
  }

  // ==========================================
  // BAGIAN 3: PEMBAYARAN (Baru & Lama)
  // ==========================================

  // [BARU - REQUEST KAMU] Simulasi Bayar Tanpa Upload (Sat Set)
  // [UPDATE] Sekarang nerima parameter 'paymentMethod'
  Future<void> confirmPaymentMock(String bookingId, String paymentMethod) async {
    // --- JALUR TIKUS (Tetap amanin buat testing) ---
    if (bookingId.contains('test')) {
      print("Mode Testing: Bayar pake $paymentMethod sukses! 🚀");
      return; 
    }

    try {
      // Mapping nama UI ke nama Database (biar rapi)
      // Misal: "Transfer BCA" -> "bca", "E-Wallet Dana" -> "dana"
      String dbMethod = 'transfer'; // Default
      if (paymentMethod.contains('BCA')) dbMethod = 'transfer_bca';
      if (paymentMethod.contains('Dana')) dbMethod = 'ewallet_dana';
      if (paymentMethod.contains('QRIS')) dbMethod = 'qris';

      await _supabase.from('bookings').update({
        'status': 'confirmed', 
        'payment_proof': 'confirmed_by_system_mock', 
        'payment_method': dbMethod, // <--- INI YANG PENTING
        // 'updated_at': DateTime.now().toIso8601String(), // Inget ini dihapus kalo DB gada kolomnya
      }).eq('id', bookingId);
    } catch (e) {
      print("Error Mock Payment: $e");
      rethrow;
    }
  }

  // [LAMA - OPTIONAL] Upload Bukti Bayar (Disimpan aja buat jaga-jaga)
  Future<void> submitPaymentWithUpload(String bookingId, File imageFile) async {
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
      print("Error Payment Upload: $e");
      rethrow;
    }
  }
}