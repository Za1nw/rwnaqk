import 'package:get/get.dart';
import 'package:rwnaqk/models/geo_lookup_item.dart';

class GeoLookupApiService extends GetConnect {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.8.124:8000',
  );

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = _defaultBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultContentType = 'application/json';
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  Future<List<GeoLookupItem>> countries() async {
    final response = await get('/api/v1/geo/countries');
    return _parseItems(response.body);
  }

  Future<List<GeoLookupItem>> governorates({int? countryId}) async {
    final response = await get(
      '/api/v1/geo/governorates',
      query: <String, dynamic>{if (countryId != null) 'country_id': countryId},
    );
    
    return _parseItems(response.body);
  }

  Future<YemenGovernoratesLookup?> yemenGovernorates() async {
    final response = await get('/api/v1/geo/yemen/governorates');
    print(response.body);
    final body = response.body;

    if (body is! Map<String, dynamic>) {
      return null;
    }

    final country = body['country'];
    final governoratesRaw = body['governorates'];

    final countryMap = country is Map
        ? country.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};

    final governorates = _parseItemsFromRawList(governoratesRaw);

    return YemenGovernoratesLookup(
      countryId: _parseNullableInt(countryMap['id']),
      countryName: (countryMap['name'] as String?)?.trim() ?? '',
      governorates: governorates,
    );
  }

  List<GeoLookupItem> _parseItems(dynamic body) {
    if (body is! Map<String, dynamic>) {
      return const <GeoLookupItem>[];
    }

    final data = body['data'];
    return _parseItemsFromRawList(data);
  }

  List<GeoLookupItem> _parseItemsFromRawList(dynamic data) {
    if (data is! List) {
      return const <GeoLookupItem>[];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => GeoLookupItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
