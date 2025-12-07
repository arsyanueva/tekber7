import 'package:flutter/material.dart';

// 1. IMPORT SCREEN TEMANMU (Yang sudah ada)
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_method_screen.dart';
import '../screens/home/home_screen.dart';

// 2. IMPORT SCREEN FITUR KAMU (BARU)
import '../screens/booking/cancel_booking_screen.dart';
import '../screens/booking/reschedule_booking_screen.dart';
import '../screens/review/reply_review_screen.dart';

class AppRoutes {
  // --- DAFTAR NAMA RUTE (STRING) ---
  static const String welcome = '/';
  static const String loginMethod = '/login-method';
  static const String home = '/home';
  
  // Nama Rute Baru (Punya Kamu)
  static const String cancelBooking = '/cancel-booking';
  static const String rescheduleBooking = '/reschedule-booking';
  static const String replyReview = '/reply-review';

  // --- DAFTAR MAP NAVIGASI ---
  // Fungsi ini yang dipanggil oleh main.dart
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Rute Teman
      welcome: (context) => const WelcomeScreen(),
      loginMethod: (context) => const LoginMethodScreen(),
      home: (context) => HomeScreen(),

      // Rute Kamu (Didaftarkan disini supaya resmi)
      cancelBooking: (context) => const CancelBookingScreen(),
      rescheduleBooking: (context) => const RescheduleBookingScreen(),
      replyReview: (context) => const ReplyReviewScreen(),
    };
  }
}