import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  // Gunakan satu instance SupabaseClient agar konsisten di seluruh fungsi
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // BAGIAN 1: AMBIL DATA (SINKRONISASI DENGAN TIM)
  // ============================================================

  // Ambil Detail Booking Lengkap (Join dengan tabel fields dan users)
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

  // Ambil List Booking milik User yang sedang login (untuk History)
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

  // Fungsi yang dipanggil oleh ConfirmRescheduleScreen kamu
  // Menangani pembaruan tanggal dan jam sekaligus
  Future<void> updateBookingSchedule(
    String bookingId, 
    DateTime newDate, 
    String startTime, 
    String endTime
  ) async {
    try {
      // Kita update ke database Supabase
      await _supabase.from('bookings').update({
        'booking_date': newDate.toIso8601String().split('T')[0], // Simpan format YYYY-MM-DD
        'start_time': startTime,
        'end_time': endTime,
        'status': 'confirmed', // Otomatis confirmed setelah reschedule (atau 'pending' sesuai kebijakan)
      }).eq('id', bookingId);

      print("Berhasil reschedule booking ID: $bookingId");
    } catch (e) {
      print("Error updateBookingSchedule: $e");
      throw Exception("Gagal memperbarui jadwal: $e");
    }
  }

  // Cek Ketersediaan Slot (Validasi agar tidak tabrakan jadwal)
  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0])
          .neq('status', 'cancelled');

      // Sederhananya, jika tidak ada booking di tanggal tersebut, maka tersedia
      // Untuk logic jam yang lebih detail, bisa dikembangkan di sini
      return (response as List).isEmpty; 
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // BAGIAN 3: PEMBAYARAN (SIMULASI & REAL)
  // ============================================================

  // Konfirmasi Pembayaran tanpa upload file (Simulasi Sat-Set)
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

  // Fungsi Upload Bukti Bayar Asli (Jika dibutuhkan kedepannya)
  Future<void> submitPaymentWithUpload(String bookingId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$bookingId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'payment_proofs/$fileName';

      // Upload ke Storage
      await _supabase.storage.from('booking_assets').upload(filePath, imageFile);
      final imageUrl = _supabase.storage.from('booking_assets').getPublicUrl(filePath);

      // Update URL ke Tabel Bookings
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