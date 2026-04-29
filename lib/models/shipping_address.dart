class ShippingAddress {
  final String id;
  final String governorate;
  final String district;
  final String street;
  final String addressDetails;

  /// default marker
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.governorate,
    required this.district,
    required this.street,
    required this.addressDetails,
    this.isDefault = false,
  });

  ShippingAddress copyWith({
    String? id,
    String? governorate,
    String? district,
    String? street,
    String? addressDetails,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      street: street ?? this.street,
      addressDetails: addressDetails ?? this.addressDetails,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  bool get isEmpty {
    return governorate.trim().isEmpty &&
        district.trim().isEmpty &&
        street.trim().isEmpty &&
        addressDetails.trim().isEmpty;
  }

  String get formatted {
    final locationLine = [
      if (district.trim().isNotEmpty) district.trim(),
      if (governorate.trim().isNotEmpty) governorate.trim(),
    ].join(', ');

    return [
      if (addressDetails.trim().isNotEmpty) addressDetails.trim(),
      if (street.trim().isNotEmpty) street.trim(),
      if (locationLine.isNotEmpty) locationLine,
    ].join('\n');
  }

  String get fullText => formatted;

  factory ShippingAddress.empty() {
    return const ShippingAddress(
      id: '',
      governorate: '',
      district: '',
      street: '',
      addressDetails: '',
    );
  }
}
