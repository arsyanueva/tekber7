import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Bikin instance supabase biar gampang dipanggil
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Sign Up (Daftar Baru)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role, // 'renter' atau 'owner'
  }) async {
    try {
      // Daftar ke Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role, 
          // Kita simpan nama & role di metadata auth dulu
          // Nanti idealnya ada Trigger di Database buat auto-copy ke tabel 'users'
          // Tapi buat sekarang, kita insert manual di UI atau trigger nanti.
        },
      );
      
      // Setelah Auth sukses, kita simpan data detail ke tabel 'public.users'
      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id, // PENTING: ID Auth = ID Tabel Users
          'email': email,
          'name': name,
          'role': role,
          'phone_number': '', // Default kosong dulu
          'is_verified': false,
        });
      }

      return response;
    } catch (e) {
      rethrow; // Lempar error biar bisa ditangkep di UI (misal: "Email sudah terdaftar")
    }
  }

  // 2. Sign In (Login)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 3. Sign Out (Logout)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 4. Cek User yang sedang login
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // 5. Ambil Data Profil User dari Tabel 'users'
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single(); // Ambil 1 baris aja
      return data;
    } catch (e) {
      return null;
    }
  }
}