import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_method_screen.dart';
import '../screens/auth/register_method_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/identity_input_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/home/home_screen.dart';
// Pastikan file-file ini sudah ada di folder booking
import '../screens/booking/cancel_booking_screen.dart';
import '../screens/booking/reschedule_booking_screen.dart';
// Pastikan file-file ini sudah ada di folder review
import '../screens/review/reply_review_screen.dart';
import '../screens/review/review_form_screen.dart';

class AppRoutes {
  // Definisi nama route
  static const String welcome = '/';
  static const String loginMethod = '/login-method';
  static const String registerMethod = '/register-method';
  static const String roleSelection = '/role';
  static const String identityInput = '/identity';
  static const String otpVerification = '/otp';
  static const String home = '/home';
  static const String addReview = '/add-review'; 
  static const String cancelBooking = '/cancel-booking';
  static const String rescheduleBooking = '/reschedule-booking';
  static const String replyReview = '/reply-review';

  // Map route ke Widget
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      loginMethod: (context) => const LoginMethodScreen(),
      registerMethod: (context) => const RegisterMethodScreen(),
      home: (context) => const HomeScreen(),
      
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

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case roleSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(
            flowType: args['flowType'],
            method: args['method'],
          ),
        );

      case identityInput:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => IdentityInputScreen(
            flowType: args['flowType'],
            method: args['method'],
            role: args['role'],
          ),
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            flowType: args['flowType'],
            method: args['method'],
            role: args['role'],
            value: args['value'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route tidak ditemukan')),
          ),
        );
    }
  }
}