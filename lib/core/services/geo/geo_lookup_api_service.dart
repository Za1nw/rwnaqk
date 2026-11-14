import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/geo_lookup_item.dart';

/// خدمة استعلامات التغطية الجغرافية [GeoLookupApiService] مع دعم التخزين المؤقت
/// المزدوج الذكي (RAM Memory Cache + Local Disk Storage) لتقليل زمن الاستجابة إلى 0ms.
class GeoLookupApiService {
  GeoLookupApiService({Dio? dio, this.prefs})
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
  final SharedPreferences? prefs;

  // ذاكرة الوصول السريع المؤقتة (In-Memory RAM Cache)
  static YemenGovernoratesLookup? _memoryYemenLookup;
  static List<GeoLookupItem>? _memoryCountries;
  static final Map<int?, List<GeoLookupItem>> _memoryGovernoratesByCountry = {};

  // مفتاح التخزين ومدة الصلاحية
  static const String yemenCacheKey = 'geo_cached_yemen_governorates_v1';
  static const Duration defaultTtl = Duration(days: 7);

  /// القائمة الافتراضية الموثوقة للمحافظات اليمنية في حال تعذر الاتصال تماماً
  static const List<String> defaultYemenGovernorates = [
    'صنعاء',
    'عدن',
    'تعز',
    'حضرموت',
    'الحديدة',
    'إب',
    'ذمار',
    'مأرب',
    'صعدة',
    'حجة',
    'عمران',
    'لحج',
    'أبين',
    'شبوة',
    'المهرة',
    'سقطرى',
    'البيضاء',
    'الضالع',
    'المحويت',
    'ريمة',
    'الجوف',
  ];

  /// كائن التغطية الافتراضي لليمن
  static final YemenGovernoratesLookup defaultYemenLookup =
      YemenGovernoratesLookup(
    countryId: 1,
    countryName: 'اليمن',
    countryCode: 'YE',
    governorates: defaultYemenGovernorates
        .asMap()
        .entries
        .map(
          (e) => GeoLookupItem(
            id: e.key + 1,
            name: e.value,
            countryId: 1,
          ),
        )
        .toList(growable: false),
  );

  /// استرجاع قائمة المحافظات المخزنة فوراً وبشكل متزامن (Synchronous Fast Access)
  static List<String> get cachedGovernorateNamesOrFallback {
    if (_memoryYemenLookup != null &&
        _memoryYemenLookup!.governorates.isNotEmpty) {
      return _memoryYemenLookup!.governorates.map((e) => e.name).toList();
    }
    return List<String>.from(defaultYemenGovernorates);
  }

  /// مسح الكاش لاختبارات الوحدة أو عند طلب تحديث إجباري
  static void clearCache() {
    _memoryYemenLookup = null;
    _memoryCountries = null;
    _memoryGovernoratesByCountry.clear();
  }

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<List<GeoLookupItem>> countries({bool forceRefresh = false}) async {
    if (!forceRefresh && _memoryCountries != null) {
      return _memoryCountries!;
    }

    try {
      final response =
          await _dio.get<dynamic>('${AppEnv.geoLookupPrefix}/countries');
      final items = _parseItems(response.data);
      if (items.isNotEmpty) {
        _memoryCountries = items;
      }
      return items;
    } catch (_) {
      return _memoryCountries ?? const [];
    }
  }

  Future<List<GeoLookupItem>> governorates({
    int? countryId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memoryGovernoratesByCountry.containsKey(countryId)) {
      return _memoryGovernoratesByCountry[countryId]!;
    }

    try {
      final response = await _dio.get<dynamic>(
        '${AppEnv.geoLookupPrefix}/governorates',
        queryParameters: <String, dynamic>{
          'country_id': ?countryId,
        },
      );
      final items = _parseItems(response.data);
      if (items.isNotEmpty) {
        _memoryGovernoratesByCountry[countryId] = items;
      }
      return items;
    } catch (_) {
      return _memoryGovernoratesByCountry[countryId] ?? const [];
    }
  }

  /// استرجاع محافظات اليمن مع كاش مزدوج (ذاكرة RAM + تخزين محلي دائم)
  /// ونمط Stale-While-Revalidate لتجربة استخدام فائقة السرعة
  Future<YemenGovernoratesLookup?> yemenGovernorates({
    bool forceRefresh = false,
  }) async {
    // 1. فحص كاش الذاكرة (0ms latency)
    if (!forceRefresh && _memoryYemenLookup != null) {
      return _memoryYemenLookup;
    }

    // 2. فحص التخزين المحلي الدائم (SharedPreferences)
    if (!forceRefresh) {
      try {
        final prefs = await _getPrefs();
        final rawString = prefs.getString(yemenCacheKey);
        if (rawString != null && rawString.isNotEmpty) {
          final decoded = jsonDecode(rawString);
          if (decoded is Map<String, dynamic>) {
            final cachedLookup = YemenGovernoratesLookup.fromJson(decoded);
            if (cachedLookup.governorates.isNotEmpty) {
              _memoryYemenLookup = cachedLookup;

              final cachedAt = decoded['cached_at'] as int?;
              final isExpired = cachedAt == null ||
                  DateTime.now().millisecondsSinceEpoch - cachedAt >
                      defaultTtl.inMilliseconds;

              if (!isExpired) {
                return cachedLookup;
              }

              // إذا انتهت الصلاحية، نعيد الكاش فوراً ونحدّث بالخلفية بدون تعطيل المستخدم
              _refreshYemenInBackground();
              return cachedLookup;
            }
          }
        }
      } catch (_) {}
    }

    // 3. جلب البيانات من الخادم وتخزينها
    return await _fetchAndCacheYemenGovernorates();
  }

  Future<YemenGovernoratesLookup> _fetchAndCacheYemenGovernorates() async {
    try {
      final response = await _dio.get<dynamic>(
        '${AppEnv.geoLookupPrefix}/yemen/governorates',
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return _memoryYemenLookup ?? defaultYemenLookup;
      }

      final country = body['country'];
      final governoratesRaw = body['governorates'];

      final countryMap = country is Map
          ? country.map((key, value) => MapEntry(key.toString(), value))
          : const <String, dynamic>{};

      final governorates = _parseItemsFromRawList(governoratesRaw);

      if (governorates.isNotEmpty) {
        final lookup = YemenGovernoratesLookup(
          countryId: (countryMap['id'] as num?)?.toInt() ?? 1,
          countryName: countryMap['name']?.toString() ?? 'اليمن',
          countryCode: countryMap['iso2']?.toString() ?? 'YE',
          governorates: governorates,
        );

        _memoryYemenLookup = lookup;

        // حفظ محلي دائم مع طابع زمني
        try {
          final prefs = await _getPrefs();
          final cacheData = <String, dynamic>{
            ...lookup.toJson(),
            'cached_at': DateTime.now().millisecondsSinceEpoch,
          };
          await prefs.setString(yemenCacheKey, jsonEncode(cacheData));
        } catch (_) {}

        return lookup;
      }

      return _memoryYemenLookup ?? defaultYemenLookup;
    } catch (_) {
      return _memoryYemenLookup ?? defaultYemenLookup;
    }
  }

  void _refreshYemenInBackground() {
    _fetchAndCacheYemenGovernorates().catchError((_) => defaultYemenLookup);
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
