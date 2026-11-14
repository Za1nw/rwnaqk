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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (countryId != null) 'country_id': countryId,
        if (code != null) 'code': code,
        if (parentId != null) 'parent_id': parentId,
      };

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

  factory YemenGovernoratesLookup.fromJson(Map<String, dynamic> json) {
    final country = json['country'] is Map ? json['country'] as Map : null;
    final govList = json['governorates'] is List
        ? json['governorates'] as List
        : const [];

    return YemenGovernoratesLookup(
      countryId: (country?['id'] as num?)?.toInt() ??
          (json['country_id'] as num?)?.toInt() ??
          1,
      countryName:
          (country?['name'] ?? json['country_name'] ?? 'اليمن').toString(),
      countryCode:
          (country?['iso2'] ?? json['country_code'] ?? 'YE').toString(),
      governorates: govList
          .whereType<Map>()
          .map<GeoLookupItem>(
            (m) => GeoLookupItem.fromJson(
              m.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'country': {
          'id': countryId ?? 1,
          'name': countryName,
          'iso2': countryCode,
        },
        'governorates': governorates.map((g) => g.toJson()).toList(),
      };

  final int? countryId;
  final String countryName;
  final String countryCode;
  final List<GeoLookupItem> governorates;
}
