import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:file/file.dart' as f;
// ignore: depend_on_referenced_packages
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/services/cache/app_image_storage_service.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';

class FakeFileSystem implements FileSystem {
  final Directory dir;
  FakeFileSystem(this.dir);

  @override
  Future<f.File> createFile(String name) async {
    return const LocalFileSystem().file('${dir.path}/$name');
  }
}

/// مستودع كاش وهمي لاختبار مزامنة السجلات وLRU بدقة
class FakeCacheInfoRepository implements CacheInfoRepository {
  final Map<String, CacheObject> objects;

  FakeCacheInfoRepository(this.objects);

  @override
  Future<bool> open() async => true;

  @override
  Future<bool> close() async => true;

  @override
  Future<bool> exists() async => true;

  @override
  Future<void> deleteDataFile() async => objects.clear();

  @override
  Future<CacheObject?> get(String key) async => objects[key];

  @override
  Future<List<CacheObject>> getAllObjects() async => objects.values.toList();

  @override
  Future<int> delete(int id) async {
    objects.removeWhere((k, v) => v.id == id);
    return 1;
  }

  @override
  Future<int> deleteAll(Iterable<int> ids) async {
    final idSet = ids.toSet();
    objects.removeWhere((k, v) => idSet.contains(v.id));
    return ids.length;
  }

  @override
  Future<CacheObject> insert(CacheObject cacheObject, {bool setTouchedToNow = true}) async {
    objects[cacheObject.key] = cacheObject;
    return cacheObject;
  }

  @override
  Future<int> update(CacheObject cacheObject, {bool setTouchedToNow = true}) async {
    objects[cacheObject.key] = cacheObject;
    return 1;
  }

  @override
  Future<dynamic> updateOrInsert(CacheObject cacheObject) async {
    objects[cacheObject.key] = cacheObject;
    return cacheObject;
  }

  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) async => [];

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) async => [];
}

/// مدير كاش وهمي متكامل لاختبار الحذف وتحديث الميتاداتا
class FakeTestCacheManager extends Fake implements CacheManager {
  final Map<String, CacheObject> repoObjects;
  final List<String> removedKeys = [];
  final Directory dir;

  FakeTestCacheManager(this.repoObjects, this.dir);

  @override
  late final Config config = Config(
    'fake_test_key',
    repo: FakeCacheInfoRepository(repoObjects),
    fileSystem: FakeFileSystem(dir),
  );

  @override
  Future<void> removeFile(String key) async {
    removedKeys.add(key);
    repoObjects.remove(key);
  }

  @override
  Future<FileInfo?> getFileFromCache(String key, {bool ignoreMemCache = false}) async {
    final obj = repoObjects[key];
    if (obj == null) return null;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempTestDir;
  final storageService = AppImageStorageService.instance;

  setUpAll(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return Directory.systemTemp.path;
    });
  });

  setUp(() {
    tempTestDir = Directory.systemTemp.createTempSync('rwnaqk_cache_test_');
    storageService.setCustomDirectory(tempTestDir);
  });

  tearDown(() {
    storageService.setCustomDirectory(null);
    storageService.setCustomCacheManager(null);
    try {
      if (tempTestDir.existsSync()) {
        tempTestDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Bounded Image Cache Storage Policy & LRU Eviction Tests', () {
    test('Calculates cache usage and file count accurately', () async {
      final file1 = File('${tempTestDir.path}/img_1.jpg');
      final file2 = File('${tempTestDir.path}/img_2.jpg');

      file1.writeAsBytesSync(List.filled(100 * 1024, 1));
      file2.writeAsBytesSync(List.filled(100 * 1024, 2));

      final count = await storageService.getCachedFileCount();
      final totalBytes = await storageService.getCacheUsageBytes();
      final totalMB = await storageService.getCacheUsageMB();

      expect(count, equals(2));
      expect(totalBytes, equals(200 * 1024));
      expect(totalMB, equals(0.2));
    });

    test('Genuine LRU: Frequently accessed old images are retained while unused recent images are evicted', () async {
      final now = DateTime.now();

      // إنشاء ملفين فيزيائيين
      final fileOldAccessed = File('${tempTestDir.path}/store_logo.jpg');
      final fileNewUnused = File('${tempTestDir.path}/random_product.jpg');

      fileOldAccessed.writeAsBytesSync(List.filled(60 * 1024, 1)); // 60 KB
      fileNewUnused.writeAsBytesSync(List.filled(60 * 1024, 2));   // 60 KB

      // تاريخ التعديل الفيزيائي (تاريخ التنزيل):
      // صورة الشعار نزلت قبل 6 أيام
      fileOldAccessed.setLastModifiedSync(now.subtract(const Duration(days: 6)));
      // صورة المنتج العشوائي نزلت قبل ساعة واحدة
      fileNewUnused.setLastModifiedSync(now.subtract(const Duration(hours: 1)));

      // تسجيل الكائنات في مستودع الكاش مع أوقات استخدام حقيقية (touched)
      final repoObjects = <String, CacheObject>{
        'url_logo': CacheObject(
          'url_logo',
          id: 1,
          relativePath: 'store_logo.jpg',
          validTill: now.add(const Duration(days: 1)),
          // الشعار تم عرضه قبل دقيقتين فقط (frequently accessed!)
          touched: now.subtract(const Duration(minutes: 2)),
          length: 60 * 1024,
        ),
        'url_random': CacheObject(
          'url_random',
          id: 2,
          relativePath: 'random_product.jpg',
          validTill: now.add(const Duration(days: 6)),
          // المنتج العشوائي لم يعرض منذ تنزيله قبل ساعة (unused!)
          touched: now.subtract(const Duration(hours: 1)),
          length: 60 * 1024,
        ),
      };

      final fakeManager = FakeTestCacheManager(repoObjects, tempTestDir);
      storageService.setCustomCacheManager(fakeManager);

      // السقف 100 KB والهدف 70 KB -> يتطلب إخلاء ملف واحد (60 KB)
      final evicted = await storageService.evictLruIfNeeded(
        maxSizeBytes: 100 * 1024,
        targetSizeBytes: 70 * 1024,
      );

      expect(evicted, equals(1));
      // تم إخلاء المنتج العشوائي رغم حداثة تنزيله لأن وقت استخدامه (touched) أقدم!
      expect(fakeManager.removedKeys, contains('url_random'));
      expect(fakeManager.removedKeys, isNot(contains('url_logo')));
    });

    test('Synchronizes physical file deletion with Cache Manager metadata', () async {
      final now = DateTime.now();
      final file = File('${tempTestDir.path}/to_delete.jpg');
      file.writeAsBytesSync(List.filled(80 * 1024, 1));
      file.setLastModifiedSync(now.subtract(const Duration(days: 2)));

      final repoObjects = <String, CacheObject>{
        'url_test_sync': CacheObject(
          'url_test_sync',
          id: 42,
          relativePath: 'to_delete.jpg',
          validTill: now.add(const Duration(days: 5)),
          touched: now.subtract(const Duration(days: 2)),
          length: 80 * 1024,
        ),
      };

      final fakeManager = FakeTestCacheManager(repoObjects, tempTestDir);
      storageService.setCustomCacheManager(fakeManager);

      // إخلاء لتجاوز الحد الأقصى
      await storageService.evictLruIfNeeded(
        maxSizeBytes: 50 * 1024,
        targetSizeBytes: 40 * 1024,
      );

      // التحقق من استدعاء removeFile(key) وحذف السجل من الـ repo
      expect(fakeManager.removedKeys, contains('url_test_sync'));
      expect(fakeManager.repoObjects.containsKey('url_test_sync'), isFalse);
    });

    test('Actual file sizes are counted including recently written files without undercounting', () async {
      final now = DateTime.now();

      // ملف مكتوب منذ 5 ثوانٍ فقط (< 15 ثانية)
      final recentFile = File('${tempTestDir.path}/recent_write.jpg');
      recentFile.writeAsBytesSync(List.filled(150 * 1024, 1)); // 150 KB
      recentFile.setLastModifiedSync(now.subtract(const Duration(seconds: 5)));

      // ملف أقدم مكتوب منذ دقيقة (100 KB)
      final olderFile = File('${tempTestDir.path}/older_file.jpg');
      olderFile.writeAsBytesSync(List.filled(100 * 1024, 2));
      olderFile.setLastModifiedSync(now.subtract(const Duration(minutes: 1)));

      // إجمالي الحجم الفعلي = 250 KB
      final totalUsage = await storageService.getCacheUsageBytes();
      expect(totalUsage, equals(250 * 1024));

      // عند محاولة الإخلاء بسقف 200 KB وهدف 160 KB:
      // يجب أن يحتسب الـ 250 KB بالكامل، لكنه يمتنع عن حذف recent_write.jpg لحمايته
      // ويحذف older_file.jpg بدلاً منه
      final evicted = await storageService.evictLruIfNeeded(
        maxSizeBytes: 200 * 1024,
        targetSizeBytes: 160 * 1024,
      );

      expect(evicted, equals(1));
      expect(olderFile.existsSync(), isFalse);
      expect(recentFile.existsSync(), isTrue); // محمي من الحذف
    });

    test('Temporary files: deletes stale temporary files (> 30 min) and protects active downloads (< 30 min)', () async {
      final now = DateTime.now();

      // ملف تنزيل نشط (بدأ قبل دقيقة واحدة)
      final activeDownload = File('${tempTestDir.path}/active.download');
      activeDownload.writeAsBytesSync(List.filled(50 * 1024, 0));
      activeDownload.setLastModifiedSync(now.subtract(const Duration(minutes: 1)));

      // ملف مؤقت مهجور/يتيم (منذ 45 دقيقة)
      final staleTemp = File('${tempTestDir.path}/abandoned.tmp');
      staleTemp.writeAsBytesSync(List.filled(50 * 1024, 0));
      staleTemp.setLastModifiedSync(now.subtract(const Duration(minutes: 45)));

      final deleted = await storageService.cleanStaleTempFiles();

      expect(deleted, equals(1));
      expect(staleTemp.existsSync(), isFalse);     // تم حذفه
      expect(activeDownload.existsSync(), isTrue); // محمي لأنه نشط
    });

    test('Clean expired files: removes files exceeding 7-day stale period and keeps fresh files', () async {
      final now = DateTime.now();

      final expiredFile = File('${tempTestDir.path}/expired.jpg');
      expiredFile.writeAsBytesSync(List.filled(10 * 1024, 1));
      expiredFile.setLastModifiedSync(now.subtract(const Duration(days: 8)));

      final freshFile = File('${tempTestDir.path}/fresh.jpg');
      freshFile.writeAsBytesSync(List.filled(10 * 1024, 2));
      freshFile.setLastModifiedSync(now.subtract(const Duration(days: 2)));

      final deleted = await storageService.cleanExpiredFiles(
        stalePeriod: const Duration(days: 7),
      );

      expect(deleted, equals(1));
      expect(expiredFile.existsSync(), isFalse);
      expect(freshFile.existsSync(), isTrue);
    });

    test('Concurrency: multiple cleanup requests are queued safely without deadlock', () async {
      final file1 = File('${tempTestDir.path}/conc_1.jpg');
      final file2 = File('${tempTestDir.path}/conc_2.jpg');
      file1.writeAsBytesSync(List.filled(10 * 1024, 1));
      file2.writeAsBytesSync(List.filled(10 * 1024, 2));

      // إطلاق 3 عمليات صيانة متزامنة في نفس اللحظة
      final results = await Future.wait([
        storageService.cleanExpiredFiles(),
        storageService.cleanStaleTempFiles(),
        storageService.evictLruIfNeeded(),
      ]);

      expect(results.length, equals(3));
      expect(await storageService.getCachedFileCount(), equals(2));
    });

    test('Diagnostics report returns comprehensive storage and temporary metrics', () async {
      final file = File('${tempTestDir.path}/diag.jpg');
      file.writeAsBytesSync(List.filled(1024 * 1024, 1)); // 1 MB

      final temp = File('${tempTestDir.path}/diag.tmp');
      temp.writeAsBytesSync(List.filled(512 * 1024, 2)); // 512 KB
      temp.setLastModifiedSync(DateTime.now().subtract(const Duration(hours: 1)));

      final diag = await storageService.getDiagnostics();

      expect(diag['file_count'], equals(1));
      expect(diag['usage_mb'], equals('1.00'));
      expect(diag['temp_mb'], equals('0.50'));
      expect(diag['total_disk_mb'], equals('1.50'));
      expect(diag['orphaned_temp_count'], equals(1));
      expect(diag['is_within_limit'], isTrue);
    });

    test('Clear all cache completely empties directory and resets usage to 0', () async {
      final file1 = File('${tempTestDir.path}/file1.jpg');
      final file2 = File('${tempTestDir.path}/file2.jpg');
      file1.writeAsBytesSync([1, 2, 3]);
      file2.writeAsBytesSync([4, 5, 6]);

      expect(await storageService.getCachedFileCount(), equals(2));

      await storageService.clearAllCache();

      expect(await storageService.getCacheUsageBytes(), equals(0));
      expect(await storageService.getCachedFileCount(), equals(0));
    });

    test('RAM Management: configureImageMemoryCache applies budget to PaintingBinding', () {
      storageService.configureImageMemoryCache(
        maxSizeBytes: 50 * 1024 * 1024,
        maxImages: 150,
      );

      expect(
        PaintingBinding.instance.imageCache.maximumSizeBytes,
        equals(50 * 1024 * 1024),
      );
      expect(
        PaintingBinding.instance.imageCache.maximumSize,
        equals(150),
      );
    });
  });

  group('AppNetworkImage Widget Tests', () {
    testWidgets('Renders error widget when URL is empty or invalid SVG', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              url: '',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('Custom placeholder and error widget are respected', (tester) async {
      const customKey = Key('custom_error_key');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              url: '   ',
              errorWidget: Text('خطأ في تحميل الصورة', key: customKey),
            ),
          ),
        ),
      );

      expect(find.byKey(customKey), findsOneWidget);
      expect(find.text('خطأ في تحميل الصورة'), findsOneWidget);
    });
  });
}
