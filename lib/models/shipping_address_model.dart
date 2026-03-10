class ShippingAddressModel {
  final String country;
  final String addressLine;
  final String city;
  final String postcode;

  const ShippingAddressModel({
    required this.country,
    required this.addressLine,
    required this.city,
    required this.postcode,
  });

  bool get isEmpty =>
      addressLine.trim().isEmpty &&
      city.trim().isEmpty &&
      postcode.trim().isEmpty;

  String get formatted {
    final line2 = [
      if (city.trim().isNotEmpty) city.trim(),
      if (postcode.trim().isNotEmpty) postcode.trim(),
    ].join(', ');

    return [
      if (addressLine.trim().isNotEmpty) addressLine.trim(),
      if (line2.isNotEmpty) line2,
      if (country.trim().isNotEmpty) country.trim(),
    ].join('\n');
  }

  ShippingAddressModel copyWith({
    String? country,
    String? addressLine,
    String? city,
    String? postcode,
  }) {
    return ShippingAddressModel(
      country: country ?? this.country,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
    );
  }

  factory ShippingAddressModel.empty() {
    return const ShippingAddressModel(
      country: 'Yemen',
      addressLine: '',
      city: '',
      postcode: '',
    );
  }
}