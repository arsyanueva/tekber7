import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_method_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/cancel_booking_screen.dart';
import '../screens/booking/reschedule_booking_screen.dart';
import '../screens/review/reply_review_screen.dart';
import '../screens/review/review_form_screen.dart';
import 'package:tekber7/screens/auth/register_email_screen.dart';
import 'package:tekber7/screens/auth/login_email_screen.dart';
import 'package:tekber7/screens/auth/role_selection_screen.dart';
import 'package:tekber7/screens/auth/verify_otp_screen.dart';
import 'package:tekber7/screens/home/home_owner_screen.dart';
import 'package:tekber7/screens/home/add_field_screen.dart';


class AppRoutes {
  // Definisi nama route
  static const String welcome = '/';
  static const String loginMethod = '/login-method';
  static const String home = '/home';
  static const String addReview = '/add-review'; 
  static const String cancelBooking = '/cancel-booking';
  static const String rescheduleBooking = '/reschedule-booking';
  static const String replyReview = '/reply-review';
  static const String registerEmail = '/register-email';
  static const String loginEmail = '/login-email';
  static const String roleSelection = '/role-selection';
  static const String verifyOtp = '/verify-otp';
  static const String homeOwner = '/home-owner';
  static const String addField = '/add-field';

  // Map route ke Widget
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      loginMethod: (context) => const LoginMethodScreen(),
      home: (context) => const HomeScreen(),
      registerEmail: (context) => const RegisterEmailScreen(),
      loginEmail: (context) => const LoginEmailScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      verifyOtp: (context) => const VerifyOtpScreen(),
      homeOwner: (context) => const HomeOwnerScreen(),
      addField: (context) => const AddFieldScreen(),
      // Route khusus untuk Add Review dengan Arguments
      addReview: (context) {
        // 1. Ambil data args dan cast sebagai Map
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

        // 2. Pass data ke Constructor ReviewFormScreen
        return ReviewFormScreen(
          bookingId: args['bookingId'],
          fieldId: args['fieldId'],
          fieldName: args['fieldName'],
        );
      },

      cancelBooking: (context) => const CancelBookingScreen(),
      rescheduleBooking: (context) => const RescheduleBookingScreen(),
      replyReview: (context) => const ReplyReviewScreen(),
    };
  }
}