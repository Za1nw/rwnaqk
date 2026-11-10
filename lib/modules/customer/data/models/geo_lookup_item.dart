class GeoLookupItem {
  const GeoLookupItem({
    required this.id,
    required this.name,
    this.countryId,
    this.code,
    this.parentId,
  });

  factory GeoLookupItem.fromJson(Map<String, dynamic> json) {
    return GeoLookupItem(
      id: _parseInt(json['id']),
      name: (json['name'] as String?)?.trim() ?? '',
      countryId: _parseNullableInt(json['country_id']),
      code: json['code']?.toString(),
      parentId: _parseNullableInt(json['parent_id'] ?? json['country_id']),
    );
  }

  final int id;
  final String name;
  final int? countryId;
  final String? code;
  final int? parentId;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class YemenGovernoratesLookup {
  const YemenGovernoratesLookup({
    this.countryId,
    required this.countryName,
    required this.governorates,
    this.countryCode = 'YE',
  });

  final int? countryId;
  final String countryName;
  final String countryCode;
  final List<GeoLookupItem> governorates;
}
