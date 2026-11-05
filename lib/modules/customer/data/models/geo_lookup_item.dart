class GeoLookupItem {
  const GeoLookupItem({required this.id, required this.name, this.countryId});

  factory GeoLookupItem.fromJson(Map<String, dynamic> json) {
    return GeoLookupItem(
      id: _parseInt(json['id']),
      name: (json['name'] as String?)?.trim() ?? '',
      countryId: _parseNullableInt(json['country_id']),
    );
  }

  final int id;
  final String name;
  final int? countryId;

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
  });

  final int? countryId;
  final String countryName;
  final List<GeoLookupItem> governorates;
}
