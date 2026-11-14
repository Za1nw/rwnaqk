import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/geo_lookup_item.dart';

/// مزود خدمة استعلام النطاق الجغرافي [GeoLookupApiService]
final geoLookupApiServiceProvider = Provider<GeoLookupApiService>((ref) {
  return GeoLookupApiService();
});

/// مزود جلب قائمة الدول المدعومة للشحن والتسجيل
final geoCountriesProvider = FutureProvider<List<GeoLookupItem>>((ref) async {
  final api = ref.watch(geoLookupApiServiceProvider);
  return api.countries();
});

/// مزود جلب قائمة المحافظات حسب الدولة المحددة
final geoGovernoratesProvider =
    FutureProvider.family<List<GeoLookupItem>, int?>((ref, countryId) async {
  final api = ref.watch(geoLookupApiServiceProvider);
  return api.governorates(countryId: countryId);
});

/// مزود جلب المحافظات اليمنية مع النطاق الإقليمي
final yemenGovernoratesProvider =
    FutureProvider<YemenGovernoratesLookup?>((ref) async {
  final api = ref.watch(geoLookupApiServiceProvider);
  return api.yemenGovernorates();
});
