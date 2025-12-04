class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> facilities; // Kita ubah text jadi List biar gampang di UI
  final int pricePerHour;
  final String openHour;
  final String closeHour;
  final String? description;
  final String? imageUrl;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.facilities,
    required this.pricePerHour,
    required this.openHour,
    required this.closeHour,
    this.description,
    this.imageUrl,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // Logic buat misahin fasilitas (misal di DB: "Wifi,Parkir" -> jadi List ["Wifi", "Parkir"])
    List<String> facilitiesList = [];
    if (json['facilities'] != null && json['facilities'].toString().isNotEmpty) {
      facilitiesList = json['facilities'].toString().split(',').map((e) => e.trim()).toList();
    }

    return FieldModel(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      facilities: facilitiesList,
      pricePerHour: json['price_per_hour'] ?? 0,
      openHour: json['open_hour'] ?? '08:00',
      closeHour: json['close_hour'] ?? '22:00',
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities.join(','), // Ubah List balik jadi String koma
      'price_per_hour': pricePerHour,
      'open_hour': openHour,
      'close_hour': closeHour,
      'description': description,
      'image_url': imageUrl,
    };
  }
}