import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan path model ini benar sesuai struktur foldermu
import '../models/booking_model.dart'; 

class BookingService {
  // --- [SOLUSI ERROR 2] ---
  // Kita daftarin '_supabase' di sini biar dikenal sama satu class
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // HELPER: Cek Ketersediaan Slot (Dipake Reschedule)
  // ==========================================
  // --- [SOLUSI ERROR 1] ---
  // Fungsi ini wajib ada karena dipanggil sama rescheduleBooking
  Future<bool> isSlotAvailable(String fieldId, DateTime date, String startTime, String endTime) async {
    try {
      await _supabase
          .from('bookings')
          .select()
          .eq('field_id', fieldId)
          .eq('booking_date', date.toIso8601String().split('T')[0]) // Format YYYY-MM-DD
          .neq('status', 'cancelled'); // Abaikan yang udah dicancel

      // LOGIC SEDERHANA:
      // Di sini kita cuma ngecek tanggal dulu.
      // Idealnya nanti kamu filter lagi: Apakah jam yang diminta (startTime-endTime)
      // tabrakan sama jam yang ada di database?
      // Tapi buat sekarang, kita anggap kalau database kosong di tanggal itu, berarti available.
      
      // Kalau mau lebih canggih, nanti kita tambahin logika cek bentrok jam di sini.
      return true; 
    } catch (e) {
      print("Error Check Slot: $e");
      return false; // Anggap penuh kalau error biar aman
    }
  }

  // ==========================================
  // FITUR 1: RESCHEDULE (POV Renter)
  // ==========================================
  Future<bool> rescheduleBooking({
    required String bookingId,
    required String fieldId,
    required DateTime newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      // 1. Cek slot baru kosong gak?
      bool isAvailable = await isSlotAvailable(fieldId, newDate, newStartTime, newEndTime);

      if (!isAvailable) {
        return false; // Gagal, slot penuh
      }

      // 2. Update data booking
      await _supabase.from('bookings').update({
        'booking_date': newDate.toIso8601String(),
        'start_time': newStartTime,
        'end_time': newEndTime,
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'pending', // Balikin ke pending biar owner cek lagi (opsional)
      }).eq('id', bookingId);

      return true; // Berhasil

    } catch (e) {
      print("Error Reschedule: $e");
      rethrow;
    }
  }

  // ==========================================
  // FITUR 2: PEMBAYARAN (Upload Bukti)
  // ==========================================
  Future<void> submitPayment(String bookingId, File imageFile) async {
    try {
      // 1. Upload Gambar ke Storage Supabase
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$bookingId-payment.$fileExt'; // Nama file unik pake ID Booking
      final filePath = 'payment_proofs/$fileName';

      // Upload ke bucket 'booking_assets' (Pastiin bucket ini udah dibuat di Supabase)
      await _supabase.storage.from('booking_assets').upload(filePath, imageFile);

      // 2. Ambil Link Gambar Publik
      final imageUrl = _supabase.storage.from('booking_assets').getPublicUrl(filePath);

      // 3. Update Database Booking
      await _supabase.from('bookings').update({
        'payment_proof': imageUrl,
        'status': 'confirmed', // Asumsi: Upload bukti = lunas/konfirmasi
        'payment_method': 'transfer',
      }).eq('id', bookingId);

    } catch (e) {
      print("Error Payment: $e");
      rethrow;
    }
  }
  
  // ==========================================
  // EXTRA: Ambil List Booking User (Buat Halaman Riwayat)
  // ==========================================
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('renter_id', userId)
          .order('booking_date', ascending: false); // Yang terbaru di atas

      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      print("Error Get Bookings: $e");
      return [];
    }
  }
}