class LocationData {
  final double latitude;
  final double longitude;
  final String name;
  final String description;
  final String? address;
  final String? phone;
  final String? website;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
    this.address,
    this.phone,
    this.website,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double? ?? 0.0,
      longitude: json['longitude'] as double? ?? 0.0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
    'description': description,
    'address': address,
    'phone': phone,
    'website': website,
  };
}
