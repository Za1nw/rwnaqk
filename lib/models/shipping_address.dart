import 'package:rwnaqk/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';

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

  bool get isEmpty =>
      address.trim().isEmpty && city.trim().isEmpty && postcode.trim().isEmpty;

  String get localizedCountry =>
      AppMockContentUtils.localizedCountryLabel(country);

  String get formatted {
    final line2 = [
      if (city.trim().isNotEmpty) city.trim(),
      if (postcode.trim().isNotEmpty) postcode.trim(),
    ].join(', ');

    return [
      if (address.trim().isNotEmpty) address.trim(),
      if (line2.isNotEmpty) line2,
      if (country.trim().isNotEmpty) localizedCountry.trim(),
    ].join('\n');
  }

  String get fullText => formatted;

  factory ShippingAddress.empty() {
    return const ShippingAddress(
      id: '',
      country: Mk.countryYemen,
      address: '',
      city: '',
      postcode: '',
    );
  }
}
