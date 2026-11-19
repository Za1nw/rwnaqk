import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/home_local_cache.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';

/// محاكي اتصال HTTP دقيق ومتحكم به لاختبار ترويسات ETag و 304 و Cache-Control
class MockHttpAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  MockHttpAdapter([this.handler]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler == null) {
      throw Exception('Handler not set');
    }
    return handler!(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: Flutter Home Bootstrap ETag Integration Tests', () {
    late SharedPreferences prefs;
    late HomeLocalCache localCache;
    late MockHttpAdapter mockAdapter;
    late ApiClient apiClient;
    late HomeService homeService;

    final initialPayloadJson = {
      'banners': [
        {
          'id': 'b1',
          'title': 'عرض الافتتاح',
          'subtitle': 'خصومات كبرى',
          'image_url': 'http://example.com/b1.jpg',
        }
      ],
      'categories': [
        {
          'id': 'c1',
          'name': 'ملابس رجالية',
          'count': 10,
          'image_urls': ['http://example.com/c1.jpg'],
        }
      ],
      'new_items': [
        {
          'id': 'p1',
          'title': 'قميص قطني',
          'price': 5000,
          'image_url': 'http://example.com/p1.jpg',
        }
      ],
      'popular_items': [],
      'flash_sale': [],
    };

    final updatedPayloadJson = {
      'banners': [
        {
          'id': 'b1',
          'title': 'عرض الافتتاح',
          'subtitle': 'خصومات كبرى',
          'image_url': 'http://example.com/b1.jpg',
        },
        {
          'id': 'b2',
          'title': 'بانر جديد محدث',
          'subtitle': 'عرض جديد',
          'image_url': 'http://example.com/b2.jpg',
        }
      ],
      'categories': [
        {
          'id': 'c1',
          'name': 'ملابس رجالية',
          'count': 10,
          'image_urls': ['http://example.com/c1.jpg'],
        }
      ],
      'new_items': [
        {
          'id': 'p1',
          'title': 'قميص قطني',
          'price': 4500, // سعر محدث
          'image_url': 'http://example.com/p1.jpg',
        }
      ],
      'popular_items': [],
      'flash_sale': [],
    };

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localCache = HomeLocalCache(prefs);

      mockAdapter = MockHttpAdapter();
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000',
        ),
      );
      dio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(dio: dio);
      homeService = HomeService(localCache: localCache);
    });

    // -----------------------------------------------------------------------
    // السيناريو 1: أول تحميل (First Load -> 200 OK وحفظ البيانات و ETag محلياً)
    // -----------------------------------------------------------------------
    test('Scenario 1: First load returns 200 OK, saves payload and ETag to local cache', () async {
      mockAdapter.handler = (options) {
        expect(options.headers.containsKey('If-None-Match'), isFalse);

        final responseBody = jsonEncode({
          'status': 'success',
          'data': initialPayloadJson,
        });

        return ResponseBody.fromString(
          responseBody,
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"etag_v1_hash"'],
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      expect(result, isNotNull);
      expect(result!.banners.length, equals(1));
      expect(result.banners.first.titleKey, equals('عرض الافتتاح'));

      // التحقق من الحفظ في SharedPreferences
      final savedEtag = await localCache.getEtag();
      final savedPayload = await localCache.getCachedPayload();

      expect(savedEtag, equals('"etag_v1_hash"'));
      expect(savedPayload, isNotNull);
      expect(savedPayload!.banners.length, equals(1));
    });

    // -----------------------------------------------------------------------
    // السيناريو 2: تحميل ثانٍ دون تغيير (304 Not Modified واستخدام البيانات المحلية)
    // -----------------------------------------------------------------------
    test('Scenario 2: Second load sends If-None-Match, server returns 304, app uses local cached data', () async {
      // 1. الحفظ المسبق لكاش محلي مع ETag
      await localCache.saveBootstrap(
        etag: '"etag_v1_hash"',
        rawData: initialPayloadJson,
      );

      bool sentIfNoneMatch = false;

      mockAdapter.handler = (options) {
        expect(options.headers['If-None-Match'], equals('"etag_v1_hash"'));
        sentIfNoneMatch = true;

        // السيرفر يعيد 304 وجسم استجابة فارغ
        return ResponseBody.fromString(
          '',
          304,
          headers: {
            'etag': ['"etag_v1_hash"'],
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      expect(sentIfNoneMatch, isTrue);
      expect(result, isNotNull);
      // يجب أن تكون البيانات مقروءة من الكاش المحلي بنجاح
      expect(result!.banners.length, equals(1));
      expect(result.banners.first.titleKey, equals('عرض الافتتاح'));
    });

    // -----------------------------------------------------------------------
    // السيناريو 3: تغيير قسم في السيرفر (200 OK وتحديث البيانات والـ ETag محلياً)
    // -----------------------------------------------------------------------
    test('Scenario 3: Server returns 200 OK when representation changed, updating local data & ETag', () async {
      // 1. الكاش الأولي كان على v1
      await localCache.saveBootstrap(
        etag: '"etag_v1_hash"',
        rawData: initialPayloadJson,
      );

      mockAdapter.handler = (options) {
        expect(options.headers['If-None-Match'], equals('"etag_v1_hash"'));

        final responseBody = jsonEncode({
          'status': 'success',
          'data': updatedPayloadJson,
        });

        // السيرفر اكتشف تغيراً في قسم البانرات فأعاد 200 مع ETag جديد
        return ResponseBody.fromString(
          responseBody,
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"etag_v2_new_hash"'],
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      expect(result, isNotNull);
      expect(result!.banners.length, equals(2));
      expect(result.banners.last.titleKey, equals('بانر جديد محدث'));

      // التحقق من تحديث الكاش المحلي بالـ ETag الجديد
      final currentEtag = await localCache.getEtag();
      final currentPayload = await localCache.getCachedPayload();

      expect(currentEtag, equals('"etag_v2_new_hash"'));
      expect(currentPayload!.banners.length, equals(2));
    });

    // -----------------------------------------------------------------------
    // السيناريو 4: السحب للتحديث (Pull-to-Refresh -> Cache-Control: no-cache)
    // -----------------------------------------------------------------------
    test('Scenario 4: Pull-to-Refresh sends Cache-Control: no-cache and bypasses 304', () async {
      await localCache.saveBootstrap(
        etag: '"etag_v1_hash"',
        rawData: initialPayloadJson,
      );

      bool sentNoCache = false;

      mockAdapter.handler = (options) {
        expect(options.headers['Cache-Control'], equals('no-cache'));
        expect(options.headers.containsKey('If-None-Match'), isFalse);
        sentNoCache = true;

        final responseBody = jsonEncode({
          'status': 'success',
          'data': updatedPayloadJson,
        });

        return ResponseBody.fromString(
          responseBody,
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"etag_v3_refreshed"'],
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient, isRefresh: true);

      expect(sentNoCache, isTrue);
      expect(result, isNotNull);
      expect(result!.banners.length, equals(2));

      final updatedEtag = await localCache.getEtag();
      expect(updatedEtag, equals('"etag_v3_refreshed"'));
    });

    // -----------------------------------------------------------------------
    // السيناريو 5: انقطاع الإنترنت (Network / Socket Error -> استرجاع البيانات المحلية)
    // -----------------------------------------------------------------------
    test('Scenario 5: Network failure falls back seamlessly to local cached data', () async {
      await localCache.saveBootstrap(
        etag: '"etag_v1_hash"',
        rawData: initialPayloadJson,
      );

      // محاكاة انقطاع الاتصال بالإنترنت
      mockAdapter.handler = (options) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'No internet connection (SocketException)',
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      // يجب ألا يتعطل التطبيق، بل يعيد الكاش المحلي بسلاسة
      expect(result, isNotNull);
      expect(result!.banners.length, equals(1));
      expect(result.banners.first.titleKey, equals('عرض الافتتاح'));
    });

    // -----------------------------------------------------------------------
    // السيناريو 6: غياب ETag أو كاش محلي تالف (Safe Fallback دون انهيار)
    // -----------------------------------------------------------------------
    test('Scenario 6: Missing local cache or corrupted data falls back safely', () async {
      // محاكاة تخزين قيمة تالفة
      await prefs.setString(HomeLocalCache.keyPayload, '{corrupted_invalid_json:');
      await prefs.setString(HomeLocalCache.keyEtag, '"some_etag"');

      // عند قراءة الكاش التالف
      final cached = await localCache.getCachedPayload();
      expect(cached, isNull); // يتم التقاط الخطأ بأمان وإرجاع null

      mockAdapter.handler = (options) {
        final responseBody = jsonEncode({
          'status': 'success',
          'data': initialPayloadJson,
        });

        return ResponseBody.fromString(
          responseBody,
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"etag_fresh"'],
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      expect(result, isNotNull);
      expect(result!.banners.length, equals(1));

      // تم استبدال الكاش التالف بكاش سليم
      final recoveredPayload = await localCache.getCachedPayload();
      expect(recoveredPayload, isNotNull);
    });

    // -----------------------------------------------------------------------
    // السيناريو 7 (OBS-01): استلام 200 OK دون ترويسة ETag يزيل الـ ETag القديم ويحفظ البيانات الجديدة
    // -----------------------------------------------------------------------
    test('Scenario 7 (OBS-01): Server returns 200 OK without ETag removes old ETag and saves new data', () async {
      // 1. وجود ETag وكاش قديم
      await localCache.saveBootstrap(
        etag: '"old_stale_etag"',
        rawData: initialPayloadJson,
      );
      expect(await localCache.getEtag(), equals('"old_stale_etag"'));

      // 2. استلام استجابة 200 OK دون ترويسة ETag (مثل قيام Proxy وسيط بحذفها)
      mockAdapter.handler = (options) {
        final responseBody = jsonEncode({
          'status': 'success',
          'data': updatedPayloadJson,
        });

        return ResponseBody.fromString(
          responseBody,
          200,
          headers: {
            'content-type': ['application/json'],
            // غياب ترويسة ETag
          },
        );
      };

      final result = await homeService.fetchHomeBootstrap(apiClient);

      // 3. تم حفظ البيانات الجديدة بنجاح
      expect(result, isNotNull);
      expect(result!.banners.length, equals(2));
      final savedPayload = await localCache.getCachedPayload();
      expect(savedPayload, isNotNull);
      expect(savedPayload!.banners.length, equals(2));

      // 4. تم إزالة الـ ETag القديم بنجاح لمنع ربط بيانات جديدة بمعرف قديم
      final currentEtag = await localCache.getEtag();
      expect(currentEtag, isNull);
    });

    // -----------------------------------------------------------------------
    // السيناريو 8 (OBS-02): تفريغ العناصر من لوحة التحكم ينعكس بحذفها من الحالة وليس الإبقاء على القديم
    // -----------------------------------------------------------------------
    test('Scenario 8 (OBS-02): Empty lists from server update state to empty without retaining stale items', () async {
      final container = ProviderContainer(
        overrides: [
          homeServiceProvider.overrideWithValue(homeService),
          apiClientProvider.overrideWithValue(apiClient),
        ],
      );
      addTearDown(container.dispose);

      // في البداية نملأ الـ State ببيانات أولية (بانر وفئة وعنصر)
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': 'success',
            'data': initialPayloadJson,
          }),
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"v1"'],
          },
        );
      };

      final notifier = container.read(homeContentProvider.notifier);
      // انتظار معالجة الـ microtask المجدول في دالة build() الأولية حتى تكتمل دورة الأحداث بالكامل
      await pumpEventQueue();

      var state = container.read(homeContentProvider);
      expect(state.banners.length, equals(1));
      expect(state.categories.length, equals(1));
      expect(state.newItems.length, equals(1));

      // الآن السيرفر يعيد استجابة بقوائم فارغة تماماً (حذف المدير كافة البانرات والمنتجات)
      final emptyPayloadJson = {
        'banners': [],
        'categories': [],
        'new_items': [],
        'popular_items': [],
        'flash_sale': [],
      };

      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': 'success',
            'data': emptyPayloadJson,
          }),
          200,
          headers: {
            'content-type': ['application/json'],
            'etag': ['"v2_empty"'],
          },
        );
      };

      await notifier.loadHomeData(isRefresh: true);
      state = container.read(homeContentProvider);

      // يجب أن تصبح القوائم فارغة في الواجهة ولا تحتفظ بالعناصر السابقة القديمة
      expect(state.banners, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.newItems, isEmpty);
      expect(state.flashSale, isEmpty);
      expect(state.mostPopular, isEmpty);
    });
  });
}
