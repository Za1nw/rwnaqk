import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwnaqk_frontend/core/services/cache/app_image_cache_manager.dart';
import 'package:rwnaqk_frontend/core/services/cache/image_cache_config.dart';

/// مرشح إخلاء الكاش وفق استراتيجية LRU الحقيقية
class _LruCandidate {
  final CacheObject? cacheObject;
  final File file;
  final int size;
  final DateTime lastAccessed;
  final bool isTrackedInRepo;

  _LruCandidate({
    this.cacheObject,
    required this.file,
    required this.size,
    required this.lastAccessed,
    required this.isTrackedInRepo,
  });
}

/// خدمة إدارة ومراقبة مساحة تخزين كاش الصور وفرض سياسة الحد الأقصى الصارم (100 MB)
/// مع دعم الإخلاء الحقيقي (LRU)، ومزامنة السجلات الرسمية، وتطهير الملفات المؤقتة، وحماية الرام
class AppImageStorageService {
  AppImageStorageService._();

  static final AppImageStorageService instance = AppImageStorageService._();

  Directory? _customDirectory;
  CacheManager? _customCacheManager;
  Future<void> _maintenanceQueue = Future.value();
  DateTime? _lastCleanupTime;
  DateTime? _lastQuickCheckTime;

  /// تهيئة مسار مخصص (مفيد جداً للاختبارات الآلية دون لمس بيانات المستخدم)
  @visibleForTesting
  void setCustomDirectory(Directory? directory) {
    _customDirectory = directory;
  }

  /// تعيين مدير كاش مخصص للاختبارات
  @visibleForTesting
  void setCustomCacheManager(CacheManager? manager) {
    _customCacheManager = manager;
  }

  CacheManager get _cacheManager =>
      _customCacheManager ?? AppImageCacheManager.instance;

  /// طابور تزامن غير متزامن يمنع التضارب وتداخل العمليات ويضمن تسلسلاً آمناً
  Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _maintenanceQueue = _maintenanceQueue.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  /// الحصول على مجلد كاش الصور الفعلي
  Future<Directory> getCacheDirectory() async {
    if (_customDirectory != null) {
      if (!await _customDirectory!.exists()) {
        await _customDirectory!.create(recursive: true);
      }
      return _customDirectory!;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/${ImageCacheConfig.cacheKey}');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      return cacheDir;
    } catch (e) {
      debugPrint('[AppImageStorageService] Error getting cache directory: $e');
      rethrow;
    }
  }

  /// قراءة المساحة المستخدمة لكاش الصور الثابت بالبايت (يشمل جميع الملفات المكتملة حتى الحديثة منها)
  Future<int> getCacheUsageBytes() async {
    try {
      final dir = await getCacheDirectory();
      if (!await dir.exists()) return 0;

      int totalBytes = 0;
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is File && !_isTempOrLocked(entity.path)) {
          try {
            totalBytes += await entity.length();
          } catch (_) {
            // تجاهل الملفات المحذوفة أو قيد الكتابة أثناء الحساب
          }
        }
      }
      return totalBytes;
    } catch (e) {
      debugPrint('[AppImageStorageService] Error calculating cache usage: $e');
      return 0;
    }
  }

  /// قراءة المساحة المستخدمة بالميجابايت (MB)
  Future<double> getCacheUsageMB() async {
    final bytes = await getCacheUsageBytes();
    return double.parse((bytes / (1024 * 1024)).toStringAsFixed(2));
  }

  /// قراءة الحد الأقصى المهيأ للمساحة بالميجابايت (MB)
  double getMaxCacheSizeMB() {
    return ImageCacheConfig.maxDiskSizeBytes / (1024 * 1024);
  }

  /// عدد ملفات الصور المخزنة حالياً
  Future<int> getCachedFileCount() async {
    try {
      final dir = await getCacheDirectory();
      if (!await dir.exists()) return 0;

      int count = 0;
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is File && !_isTempOrLocked(entity.path)) {
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// تنظيف الملفات منتهية الصلاحية مع مزامنة سجلات الكاش الرسمية
  Future<int> cleanExpiredFiles({Duration? stalePeriod}) async {
    return _synchronized(() async {
      final expiryDuration = stalePeriod ?? ImageCacheConfig.stalePeriod;
      final now = DateTime.now();
      int deletedCount = 0;

      try {
        final dir = await getCacheDirectory();
        if (!await dir.exists()) return 0;

        // 1. حذف الملفات المنتهية عبر السجل الرسمي إن وجد
        final Set<String> handledKeys = {};
        try {
          final repo = _cacheManager.config.repo;
          await repo.open();
          final allObjects = await repo.getAllObjects();
          for (final obj in allObjects) {
            if (obj.validTill.isBefore(now)) {
              await _cacheManager.removeFile(obj.key);
              handledKeys.add(obj.key);
              deletedCount++;
            }
          }
        } catch (_) {}

        // 2. فحص أي ملفات فيزيائية يتيمة على القرص تجاوزت مدة الصلاحية
        await for (final entity in dir.list(recursive: false, followLinks: false)) {
          if (entity is File && !_isTempOrLocked(entity.path)) {
            try {
              final stat = await entity.stat();
              if (now.difference(stat.modified) > expiryDuration) {
                if (await entity.exists()) {
                  await entity.delete();
                  deletedCount++;
                }
              }
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('[AppImageStorageService] Error cleaning expired files: $e');
      }

      return deletedCount;
    });
  }

  /// تنظيف الملفات المؤقتة والمهجورة (.tmp و .download) القديمة (> 30 دقيقة) بأمان
  /// مع حماية التنزيلات النشطة الجارية (< 30 دقيقة)
  Future<int> cleanStaleTempFiles({Duration? threshold}) async {
    return _synchronized(() async {
      final staleThreshold = threshold ?? ImageCacheConfig.staleTempFileThreshold;
      final now = DateTime.now();
      int deletedCount = 0;

      try {
        final dir = await getCacheDirectory();
        if (!await dir.exists()) return 0;

        await for (final entity in dir.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            final filename = _basename(entity.path).toLowerCase();
            if (filename.endsWith('.tmp') || filename.endsWith('.download')) {
              try {
                final stat = await entity.stat();
                if (now.difference(stat.modified) > staleThreshold) {
                  if (await entity.exists()) {
                    await entity.delete();
                    deletedCount++;
                  }
                }
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        debugPrint('[AppImageStorageService] Error cleaning stale temp files: $e');
      }

      return deletedCount;
    });
  }

  /// فرض الحد الأقصى للمساحة (100 MB) مع إخلاء الملفات الأقدم وصولاً وفق استراتيجية LRU الحقيقية
  /// عند تجاوز 100 ميجابايت، يتم الإخلاء حتى 80 ميجابايت ومزامنة قاعدة بيانات الكاش رسمياً
  Future<int> evictLruIfNeeded({
    int maxSizeBytes = ImageCacheConfig.maxDiskSizeBytes,
    int targetSizeBytes = ImageCacheConfig.evictionTargetSizeBytes,
  }) async {
    return _synchronized(() async {
      int evictedCount = 0;

      try {
        final dir = await getCacheDirectory();
        if (!await dir.exists()) return 0;

        // 1. استخراج الكائنات المسجلة في الـ Repo للحصول على أوقات الوصول الحقيقية (touched)
        final Map<String, CacheObject> repoObjectsByFilename = {};
        try {
          final repo = _cacheManager.config.repo;
          await repo.open();
          final allObjects = await repo.getAllObjects();
          for (final obj in allObjects) {
            final filename = _basename(obj.relativePath);
            repoObjectsByFilename[filename] = obj;
            repoObjectsByFilename[obj.relativePath] = obj;
          }
        } catch (_) {}

        final now = DateTime.now();
        int totalPersistentBytes = 0;
        final List<_LruCandidate> candidates = [];

        await for (final entity in dir.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            final filename = _basename(entity.path);

            if (_isTempOrLocked(filename)) {
              continue;
            }

            try {
              final stat = await entity.stat();
              final fileSize = stat.size;

              // حساب حجم جميع الملفات المكتملة في إجمالي المساحة دون استبعاد أي ملف
              totalPersistentBytes += fileSize;

              // حماية الملفات المكتوبة خلال نافذة الحماية (15 ثانية) من الحذف أثناء التنزيل
              final isActivelyWritten =
                  now.difference(stat.modified) < ImageCacheConfig.activeWriteWindow;
              if (isActivelyWritten) {
                continue;
              }

              final trackedObj = repoObjectsByFilename[filename] ??
                  repoObjectsByFilename[entity.path];

              final DateTime lastAccessed;
              if (trackedObj != null && trackedObj.touched != null) {
                // وقت الاستخدام الحقيقي المسجل في قاعدة بيانات الحزمة الرسمية
                lastAccessed = trackedObj.touched!;
              } else if (trackedObj != null) {
                lastAccessed = trackedObj.validTill
                    .subtract(ImageCacheConfig.stalePeriod);
              } else {
                lastAccessed = stat.modified;
              }

              candidates.add(_LruCandidate(
                cacheObject: trackedObj,
                file: entity,
                size: fileSize,
                lastAccessed: lastAccessed,
                isTrackedInRepo: trackedObj != null,
              ));
            } catch (_) {}
          }
        }

        // إذا كانت المساحة ضمن السقف المسموح، لا داعي للإخلاء
        if (totalPersistentBytes <= maxSizeBytes) {
          return 0;
        }

        // فرز المرشحين تصاعدياً حسب وقت آخر وصول حقيقي (LRU: الأقدم استخداماً أولاً)
        candidates.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

        // الإخلاء بالتتابع حتى النزول تحت الحجم المستهدف (80 MB)
        for (final item in candidates) {
          if (totalPersistentBytes <= targetSizeBytes) {
            break;
          }

          try {
            if (item.isTrackedInRepo && item.cacheObject != null) {
              // حذف الملف ومزامنة سجله رسمياً في SQLite/Repo
              await _cacheManager.removeFile(item.cacheObject!.key);
            } else {
              if (await item.file.exists()) {
                await item.file.delete();
              }
            }
            totalPersistentBytes -= item.size;
            evictedCount++;
          } catch (e) {
            debugPrint('[AppImageStorageService] Error evicting item: $e');
          }
        }
      } catch (e) {
        debugPrint('[AppImageStorageService] Error during LRU eviction: $e');
      }

      return evictedCount;
    });
  }

  /// فحص سريع وخفيف للمساحة: إذا تجاوز الحجم الكلي 100 ميجابايت يتم تشغيل الإخلاء فوراً
  /// دون الانتظار لفترة الـ 15 دقيقة
  Future<bool> checkAndEvictIfOverLimit() async {
    final now = DateTime.now();
    if (_lastQuickCheckTime != null &&
        now.difference(_lastQuickCheckTime!) < ImageCacheConfig.quickCheckInterval) {
      return false;
    }
    _lastQuickCheckTime = now;

    final currentBytes = await getCacheUsageBytes();
    if (currentBytes > ImageCacheConfig.maxDiskSizeBytes) {
      await evictLruIfNeeded();
      return true;
    }
    return false;
  }

  /// تنفيذ فحص وصيانة شاملة مع كبح التكرار
  Future<void> runMaintenanceIfNeeded({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastCleanupTime != null &&
        now.difference(_lastCleanupTime!) < ImageCacheConfig.minCleanupInterval) {
      return;
    }

    _lastCleanupTime = now;

    try {
      await cleanExpiredFiles();
      await cleanStaleTempFiles();
      await evictLruIfNeeded();
    } catch (e) {
      debugPrint('[AppImageStorageService] Maintenance run error: $e');
    }
  }

  /// مسح كاش الصور بالكامل بالتزامن مع تفريغ قاعدة البيانات ومسح الملفات الفيزيائية
  Future<void> clearAllCache() async {
    await _synchronized(() async {
      try {
        final repo = _cacheManager.config.repo;
        await repo.open();
        final allObjects = await repo.getAllObjects();
        final ids = allObjects.map((e) => e.id).whereType<int>().toList();
        if (ids.isNotEmpty) {
          await repo.deleteAll(ids);
        }
      } catch (_) {}

      try {
        final dir = await getCacheDirectory();
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: false, followLinks: false)) {
            try {
              await entity.delete(recursive: true);
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('[AppImageStorageService] Error clearing image cache: $e');
      }
    });
  }

  /// تكوين ميزانية كاش الصور في الذاكرة العشوائية (RAM) لمحرك فلاتر
  void configureImageMemoryCache({
    int? maxSizeBytes,
    int? maxImages,
  }) {
    try {
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          maxSizeBytes ?? ImageCacheConfig.maxMemoryCacheSizeBytes;
      PaintingBinding.instance.imageCache.maximumSize =
          maxImages ?? ImageCacheConfig.maxMemoryCacheImages;
      debugPrint(
        '[AppImageStorageService] Memory cache policy applied: '
        'maxSizeBytes=${PaintingBinding.instance.imageCache.maximumSizeBytes}, '
        'maxImages=${PaintingBinding.instance.imageCache.maximumSize}',
      );
    } catch (e) {
      debugPrint('[AppImageStorageService] Could not configure imageCache: $e');
    }
  }

  /// تقرير تشخيصي شامل ودقيق لحالة الكاش
  Future<Map<String, dynamic>> getDiagnostics() async {
    final dir = await getCacheDirectory();
    int persistentBytes = 0;
    int tempBytes = 0;
    int persistentCount = 0;
    int orphanedTempCount = 0;
    final now = DateTime.now();

    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is File) {
          final filename = _basename(entity.path).toLowerCase();
          try {
            final stat = await entity.stat();
            final size = stat.size;
            if (filename.endsWith('.tmp') || filename.endsWith('.download')) {
              tempBytes += size;
              if (now.difference(stat.modified) > ImageCacheConfig.staleTempFileThreshold) {
                orphanedTempCount++;
              }
            } else if (!_isTempOrLocked(filename)) {
              persistentBytes += size;
              persistentCount++;
            }
          } catch (_) {}
        }
      }
    }

    final totalDiskBytes = persistentBytes + tempBytes;
    final maxBytes = ImageCacheConfig.maxDiskSizeBytes;

    return {
      'usage_bytes': persistentBytes,
      'usage_mb': (persistentBytes / (1024 * 1024)).toStringAsFixed(2),
      'temp_bytes': tempBytes,
      'temp_mb': (tempBytes / (1024 * 1024)).toStringAsFixed(2),
      'total_disk_bytes': totalDiskBytes,
      'total_disk_mb': (totalDiskBytes / (1024 * 1024)).toStringAsFixed(2),
      'max_mb': (maxBytes / (1024 * 1024)).toStringAsFixed(0),
      'file_count': persistentCount,
      'orphaned_temp_count': orphanedTempCount,
      'is_within_limit': persistentBytes <= maxBytes,
      'stale_days': ImageCacheConfig.stalePeriod.inDays,
    };
  }

  /// استخراج اسم الملف بدون مسار بطريقة برمجية نقية دون مكتبات خارجية
  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index != -1 ? normalized.substring(index + 1) : normalized;
  }

  /// هل الملف مؤقت أو مقفل أو قاعدة بيانات؟
  bool _isTempOrLocked(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.tmp') ||
        lower.endsWith('.download') ||
        lower.endsWith('.lock') ||
        lower.endsWith('.db') ||
        lower.endsWith('.db-journal') ||
        lower.endsWith('.json');
  }
}
