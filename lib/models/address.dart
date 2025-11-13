class Address {
  final String city;
  final String state;
  final String pincode;
  final String address;
  final String? addressSecondary;
  final String? landMark;
  final double lat;
  final double lng;

  Address({
    required this.city,
    required this.state,
    required this.pincode,
    required this.address,
    this.addressSecondary,
    this.landMark,
    required this.lat,
    required this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      addressSecondary: json['address_secondary'],
      landMark: json['land_mark'],
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
    Address copyWith({
      String? city,
      String? state,
      String? pincode,
      String? address,
      String? addressSecondary,
      String? landMark,
      double? lat,
      double? lng,
    }) {
      return Address(
        city: city ?? this.city,
        state: state ?? this.state,
        pincode: pincode ?? this.pincode,
        address: address ?? this.address,
        addressSecondary: addressSecondary ?? this.addressSecondary,
        landMark: landMark ?? this.landMark,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );
    }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'pincode': pincode,
      'address': address,
      'address_secondary': addressSecondary,
      'land_mark': landMark,
      'lat': lat,
      'lng': lng,
    };
  }
}