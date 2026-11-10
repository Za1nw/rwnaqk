import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/geo_lookup_item.dart';

class GeoLookupApiService {
  GeoLookupApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppEnv.apiBaseUrl,
                connectTimeout:
                    Duration(seconds: AppEnv.apiTimeoutSeconds),
                receiveTimeout:
                    Duration(seconds: AppEnv.apiTimeoutSeconds),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<List<GeoLookupItem>> countries() async {
    try {
      final response = await _dio.get<dynamic>('${AppEnv.geoLookupPrefix}/countries');
      return _parseItems(response.data);
    } catch (_) {
      return const [];
    }
  }

  Future<List<GeoLookupItem>> governorates({int? countryId}) async {
    try {
      final response = await _dio.get<dynamic>(
        '${AppEnv.geoLookupPrefix}/governorates',
        queryParameters: <String, dynamic>{
          'country_id': ?countryId,
        },
      );
      return _parseItems(response.data);
    } catch (_) {
      return const [];
    }
  }

  Future<YemenGovernoratesLookup?> yemenGovernorates() async {
    try {
      final response =
          await _dio.get<dynamic>('${AppEnv.geoLookupPrefix}/yemen/governorates');
      final body = response.data;
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
        countryId: (countryMap['id'] as num?)?.toInt() ?? 1,
        countryName: countryMap['name']?.toString() ?? 'اليمن',
        countryCode: countryMap['iso2']?.toString() ?? 'YE',
        governorates: governorates,
      );
    } catch (_) {
      return null;
    }
  }

  List<GeoLookupItem> _parseItems(dynamic raw) {
    if (raw is! List) return const [];
    return _parseItemsFromRawList(raw);
  }

  List<GeoLookupItem> _parseItemsFromRawList(dynamic rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map>()
        .map<GeoLookupItem>(
          (m) => GeoLookupItem(
            id: (m['id'] as num?)?.toInt() ?? 0,
            name: (m['name'] ?? '').toString(),
            code: (m['code'] ?? m['iso2'] ?? '').toString(),
            parentId: (m['country_id'] as num?)?.toInt(),
          ),
        )
        .toList(growable: false);
  }
}
