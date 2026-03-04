class ShippingAddress {
  final String id;
  final String country;
  final String address;
  final String city;
  final String postcode;

  /// default marker
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.country,
    required this.address,
    required this.city,
    required this.postcode,
    this.isDefault = false,
  });

  ShippingAddress copyWith({
    String? id,
    String? country,
    String? address,
    String? city,
    String? postcode,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      country: country ?? this.country,
      address: address ?? this.address,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullText => '$country, $city, $postcode\n$address';
}