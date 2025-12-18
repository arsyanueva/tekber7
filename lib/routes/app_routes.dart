import 'package:flutter/material.dart';
import 'package:tekber7/models/booking_model.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_method_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/cancel_booking_screen.dart';
import '../screens/booking/confirm_cancel_screen.dart';
import '../screens/booking/booking_cancel_success_screen.dart';
import '../screens/booking/booking_detail_screen.dart';
import '../screens/booking/reschedule_booking_screen.dart';
import '../screens/booking/confirm_reschedule_screen.dart';
import '../screens/booking/reschedule_success_screen.dart';
import '../screens/review/reply_review_screen.dart';
import '../screens/review/review_form_screen.dart';
import 'package:tekber7/screens/auth/register_email_screen.dart';
import 'package:tekber7/screens/auth/login_email_screen.dart';
import 'package:tekber7/screens/auth/role_selection_screen.dart';
import 'package:tekber7/screens/auth/verify_otp_screen.dart';
import 'package:tekber7/screens/home/home_owner_screen.dart';
import 'package:tekber7/screens/home/add_field_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String loginMethod = '/login-method';
  static const String home = '/home';
  static const String registerEmail = '/register-email';
  static const String loginEmail = '/login-email';
  static const String roleSelection = '/role-selection';
  static const String verifyOtp = '/verify-otp';
  static const String homeOwner = '/home-owner';
  static const String addField = '/add-field';
  static const String addReview = '/add-review'; 
  static const String replyReview = '/reply-review';
  static const String rescheduleBooking = '/reschedule-booking';
  static const String confirmReschedule = '/confirm-reschedule';
  static const String rescheduleSuccess = '/reschedule-success';
  static const String bookingDetail = '/booking-detail';
  static const String cancelBooking = '/cancel-booking';
  static const String confirmCancel = '/confirm-cancel';
  static const String cancelSuccess = '/cancel-success';

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
      replyReview: (context) => const ReplyReviewScreen(),
      rescheduleBooking: (context) => const RescheduleBookingScreen(),

      addReview: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ReviewFormScreen(
          bookingId: args['bookingId'],
          fieldId: args['fieldId'],
          fieldName: args['fieldName'],
        );
      },

      bookingDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as BookingModel;
        return BookingDetailScreen(booking: args, selectedMethod: 'Transfer');
      },

      confirmReschedule: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ConfirmRescheduleScreen(
          oldBooking: args['oldBooking'],
          newDate: args['newDate'],
          newStartTime: args['newStartTime'],
          newEndTime: args['newEndTime'],
        );
      },

      rescheduleSuccess: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return RescheduleSuccessScreen(
          newDate: args['newDate'],
          newStartTime: args['newStartTime'],
          newEndTime: args['newEndTime'],
        );
      },

      cancelBooking: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as BookingModel;
        return CancelBookingScreen(booking: args);
      },

      confirmCancel: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ConfirmCancelScreen(
          booking: args['booking'],
          reason: args['reason'],
        );
      },

      cancelSuccess: (context) => const BookingCancelSuccessScreen(),
      rescheduleBooking: (context) => const RescheduleBookingScreen(),
    };
  }
}