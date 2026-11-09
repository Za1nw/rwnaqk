import 'package:rwnaqk_frontend/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';

class ShippingAddress {
  final String id;
  final String country;
  final String address;
  final String city;
  final String postcode;

  /// default marker
  final bool isDefault;

  /// نطاق الخدمة والتغطية الجغرافية
  final bool isServiceable;
  final String coverageStatus;
  final int? governorateId;
  final int? districtId;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? contactName;
  final String? label;
  final Map<String, dynamic>? deliveryTier;

  const ShippingAddress({
    required this.id,
    required this.country,
    required this.address,
    required this.city,
    required this.postcode,
    this.isDefault = false,
    this.isServiceable = true,
    this.coverageStatus = 'in_district',
    this.governorateId,
    this.districtId,
    this.latitude,
    this.longitude,
    this.phone,
    this.contactName,
    this.label,
    this.deliveryTier,
  });

  ShippingAddress copyWith({
    String? id,
    String? country,
    String? address,
    String? city,
    String? postcode,
    bool? isDefault,
    bool? isServiceable,
    String? coverageStatus,
    int? governorateId,
    int? districtId,
    double? latitude,
    double? longitude,
    String? phone,
    String? contactName,
    String? label,
    Map<String, dynamic>? deliveryTier,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      country: country ?? this.country,
      address: address ?? this.address,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      isDefault: isDefault ?? this.isDefault,
      isServiceable: isServiceable ?? this.isServiceable,
      coverageStatus: coverageStatus ?? this.coverageStatus,
      governorateId: governorateId ?? this.governorateId,
      districtId: districtId ?? this.districtId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      contactName: contactName ?? this.contactName,
      label: label ?? this.label,
      deliveryTier: deliveryTier ?? this.deliveryTier,
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
      isServiceable: true,
      coverageStatus: 'in_district',
    );
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    final rawServiceable = json['is_serviceable'] ?? json['isServiceable'];
    final bool isServ = rawServiceable is bool
        ? rawServiceable
        : rawServiceable is num
            ? rawServiceable == 1
            : true;

    final rawDefault = json['is_primary'] ?? json['is_default'] ?? json['isDefault'];
    final bool isDef = rawDefault is bool
        ? rawDefault
        : rawDefault is num
            ? rawDefault == 1
            : false;

    return ShippingAddress(
      id: (json['id'] ?? '').toString(),
      country: (json['country'] ?? json['country_name'] ?? Mk.countryYemen).toString(),
      address: (json['address'] ?? json['description'] ?? '').toString(),
      city: (json['city'] ?? json['governorate_name'] ?? '').toString(),
      postcode: (json['postcode'] ?? json['district_name'] ?? '').toString(),
      isDefault: isDef,
      isServiceable: isServ,
      coverageStatus: (json['coverage_status'] ?? 'in_district').toString(),
      governorateId: json['governorate_id'] != null ? int.tryParse(json['governorate_id'].toString()) : null,
      districtId: json['district_id'] != null ? int.tryParse(json['district_id'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      phone: (json['contact_phone'] ?? json['phone'])?.toString(),
      contactName: (json['contact_name'] ?? json['name'])?.toString(),
      label: json['label']?.toString(),
      deliveryTier: json['delivery_tier'] is Map<String, dynamic>
          ? json['delivery_tier'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': address,
      'address': address,
      if (label != null && label!.isNotEmpty) 'label': label,
      if (phone != null && phone!.isNotEmpty) 'contact_phone': phone,
      if (contactName != null && contactName!.isNotEmpty) 'contact_name': contactName,
      if (governorateId != null) 'governorate_id': governorateId,
      if (districtId != null) 'district_id': districtId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_primary': isDefault,
    };
  }
}
