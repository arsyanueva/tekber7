import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final supabase = Supabase.instance.client;

  // 1. CARI ID BOOKING PERTAMA (Otomatis)
  // Ini biar kita gak usah copy paste ID manual buat ngetes
  Future<String?> getFirstBookingId() async {
    try {
      final response = await supabase
          .from('bookings')
          .select('id')
          .limit(1); // Ambil 1 data saja
      
      if (response.isNotEmpty) {
        return response[0]['id'] as String;
      }
      return null; 
    } catch (e) {
      print("Error cari ID: $e");
      return null;
    }
  }

  // 2. AMBIL DETAIL BOOKING
  Future<Map<String, dynamic>?> getBookingDetail(String bookingId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*, fields(name), users(name, phone_number)') 
          .eq('id', bookingId)
          .single();
      
      return response;
    } catch (e) {
      print("Error ambil data: $e");
      return null;
    }
  }

  // 3. UPDATE JADWAL (RESCHEDULE)
  Future<bool> rescheduleBooking(String bookingId, DateTime newDate) async {
    try {
      await supabase
          .from('bookings')
          .update({
            'booking_date': newDate.toIso8601String(),
          })
          .eq('id', bookingId);
      return true;
    } catch (e) {
      print("Error update jadwal: $e");
      return false;
    }
  }
}