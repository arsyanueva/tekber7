class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final int pricePerHour;
  final String openHour;
  final String closeHour;
  final String facilities;
  final String description;
  final String imageUrl; 
  final double latitude;
  final double longitude;
  final double rating;  

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.openHour,
    required this.closeHour,
    required this.facilities,
    required this.description,
    required this.imageUrl,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.rating, 
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Tanpa Nama',
      address: json['address']?.toString() ?? 'Alamat tidak tersedia',
      pricePerHour: int.tryParse(json['price_per_hour'].toString()) ?? 0,
      openHour: json['open_hour']?.toString() ?? '08:00',
      closeHour: json['close_hour']?.toString() ?? '22:00',
      facilities: json['facilities']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      
      // Jika gambar kosong/null, alternatif pakai gambar placeholder
      imageUrl: (json['image_url'] != null && json['image_url'].toString().isNotEmpty)
          ? json['image_url'].toString()
          : 'https://via.placeholder.com/300', 
      
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      
      // Jika null, anggap 0.0
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}