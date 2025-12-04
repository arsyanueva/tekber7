class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String role; // 'renter' atau 'owner'
  final String? profilePicture;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.profilePicture,
    required this.isVerified,
  });

  // Dari JSON (Supabase) ke Dart Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'renter',
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  // Dari Dart Object ke JSON (buat dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'role': role,
      'profile_picture': profilePicture,
      // 'is_verified' biasanya diurus admin/sistem, jadi gak dikirim pas update profil biasa
    };
  }
}