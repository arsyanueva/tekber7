import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  // Bikin instance supabase biar gampang dipanggil
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> handleAuth({
    required String flowType,
    required String method,
    required String value,
    required String role,
  }) async {
    final payload = method == 'email'
        ? {'email': value}
        : {'phone_number': value};

    if (flowType == 'login') {
      // Login
      final user = await _supabase
          .from('users')
          .select()
          .match(payload)
          .maybeSingle();

      if (user == null) {
        throw Exception('Akun belum terdaftar');
      }

      // optional: update last_login
      await _supabase.from('users').update({
        'is_verified': true,
      }).match(payload);

      return;
    } else {
      // Register
      final existingUser = await _supabase
          .from('users')
          .select()
          .match(payload)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Akun sudah terdaftar');
      }

      await _supabase.from('users').insert({
        ...payload,
        'role': role,
        'is_verified': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      return;
    }
  }

  // 1. Sign Up (Daftar Baru)
  Future<UserModel> registerWithOtp({
    required String identifier,
    required String method, // 'email' | 'phone'
    required String name,
    required String role,
  }) async {
    final payload = method == 'email'
      ? {'email': identifier}
      : {'phone_number': identifier};

    final existingUser = await _supabase
        .from('users')
        .select()
        .match(payload)
        .maybeSingle();

    if (existingUser != null) {
      throw Exception('User sudah terdaftar');
    }

    final inserted = await _supabase.from('users').insert({
      ...payload,
      'name': name,
      'role': role,
      'is_verified': true,
    }).select().single();

    return UserModel.fromJson(inserted);
  }

  // 2. Sign In (Login)
  Future<UserModel> loginWithOtp({
    required String identifier,
    required String method,
  }) async {
    final payload = method == 'email'
        ? {'email': identifier}
        : {'phone_number': identifier};

    final user = await _supabase
        .from('users')
        .select()
        .match(payload)
        .maybeSingle();

    if (user == null) {
      throw Exception('User belum terdaftar');
    }
    return UserModel.fromJson(user);
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