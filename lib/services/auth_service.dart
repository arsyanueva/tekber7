import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan User saat ini
  User? get currentUser => _supabase.auth.currentUser;

  // Mendapatkan Profile User dari tabel public.users
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // --- [UPDATE] FUNGSI REGISTER DENGAN ROLE ---
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role, // <--- Tambahkan parameter role di sini
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role, // <--- Simpan role ke metadata Supabase
      },
    );
  }

  // --- FUNGSI LOGIN EMAIL (Tidak berubah) ---
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // --- [BARU] VERIFIKASI OTP ---
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}