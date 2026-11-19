import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rwnaqk_frontend/core/services/cache/app_image_storage_service.dart';
import 'package:rwnaqk_frontend/core/services/cache/image_cache_config.dart';

/// مدير كاش الصور الموحد للتطبيق مع تحكم مركزي وحماية التخزين [AppImageCacheManager]
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  static final AppImageCacheManager instance = AppImageCacheManager._();

  AppImageCacheManager._()
      : super(
          Config(
            ImageCacheConfig.cacheKey,
            stalePeriod: ImageCacheConfig.stalePeriod,
            maxNrOfCacheObjects: ImageCacheConfig.maxNrOfCacheObjects,
          ),
        );

  /// مسح الكاش بالكامل بالتزامن مع خدمة التخزين المحدودة
  @override
  Future<void> emptyCache() async {
    await super.emptyCache();
    await AppImageStorageService.instance.clearAllCache();
  }
}
