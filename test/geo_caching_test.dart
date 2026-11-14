import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';

class FakeAuthRepository implements IAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GeoLookupApiService.clearCache();
    SharedPreferences.setMockInitialValues({});
  });

  group('GeoLookupApiService & Register Governorates Caching Tests', () {
    test('cachedGovernorateNamesOrFallback provides synchronous default governorates (0ms)', () {
      final list = GeoLookupApiService.cachedGovernorateNamesOrFallback;
      expect(list, isNotEmpty);
      expect(list.contains('صنعاء'), isTrue);
      expect(list.contains('عدن'), isTrue);
      expect(list.contains('تعز'), isTrue);
      expect(list.contains('حضرموت'), isTrue);
      expect(list.length, greaterThanOrEqualTo(20));
    });

    test('Loads from persistent SharedPreferences cache when available', () async {
      final cachedPayload = {
        'country': {
          'id': 1,
          'name': 'اليمن',
          'iso2': 'YE',
        },
        'governorates': [
          {'id': 101, 'name': 'صنعاء القديمة', 'code': 'SA'},
          {'id': 102, 'name': 'عدن الصغرى', 'code': 'AD'},
        ],
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };

      SharedPreferences.setMockInitialValues({
        GeoLookupApiService.yemenCacheKey: jsonEncode(cachedPayload),
      });

      final prefs = await SharedPreferences.getInstance();
      final geoApi = GeoLookupApiService(prefs: prefs);

      final lookup = await geoApi.yemenGovernorates();
      expect(lookup, isNotNull);
      expect(lookup!.countryName, 'اليمن');
      expect(lookup.governorates.length, 2);
      expect(lookup.governorates[0].name, 'صنعاء القديمة');
      expect(lookup.governorates[1].name, 'عدن الصغرى');

      // Next call hits memory cache (0ms)
      final memoryLookup = await geoApi.yemenGovernorates();
      expect(identical(lookup, memoryLookup), isTrue);
    });

    test('RegisterService utilizes cached governorates and sets default selection to صنعاء', () async {
      final prefs = await SharedPreferences.getInstance();
      final geoApi = GeoLookupApiService(prefs: prefs);
      final authRepo = FakeAuthRepository();
      final sessionNotifier = AuthSessionNotifier();

      final registerService = RegisterService(authRepo, sessionNotifier, geoApi);

      await registerService.loadGovernorates();
      expect(registerService.governorates, isNotEmpty);
      expect(registerService.governorates.contains('صنعاء'), isTrue);
      expect(registerService.defaultGovernorate(), 'صنعاء');
      expect(registerService.defaultCountryName(), 'اليمن');
    });
  });
}
