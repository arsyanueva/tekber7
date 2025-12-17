import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

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

    final inserted = await _supabase.from('users').insert({
      ...payload,
      'name': name,
      'role': role,
      'is_verified': true,
    }).select().single();

    return UserModel.fromJson(inserted);
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

  // Check if user exists
  Future<bool> userExists(String identifier, String method) async {
    final payload = method == 'email'
        ? {'email': identifier}
        : {'phone_number': identifier};

    final user = await _supabase
        .from('users')
        .select()
        .match(payload)
        .maybeSingle();

    return user != null;
  }
}