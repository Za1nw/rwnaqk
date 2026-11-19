/// إعدادات وسياسات تخزين كاش الصور محلياً مع فرض قيود صارمة على المساحة
class ImageCacheConfig {
  ImageCacheConfig._();

  /// المفتاح الفريد لمخزن كاش صور التطبيق
  static const String cacheKey = 'rwnaqk_bounded_image_cache';

  /// الحد الأقصى الصارم لمساحة تخزين كاش الصور على القرص (100 ميجابايت)
  static const int maxDiskSizeBytes = 100 * 1024 * 1024; // 100 MB

  /// الحد المستهدف عند الإخلاء التلقائي (Low-Water Mark: 80 ميجابايت) لمنع تكرار الإخلاء مع كل طلب جديد
  static const int evictionTargetSizeBytes = 80 * 1024 * 1024; // 80 MB

  /// مدة صلاحية الصورة قبل اعتبارها منتهية (7 أيام)
  static const Duration stalePeriod = Duration(days: 7);

  /// الحد الأقصى المقدر لعدد عناصر الكاش في مسجل الحزم
  static const int maxNrOfCacheObjects = 500;

  /// الفاصل الزمني الأدنى بين عمليات فحص وتنظيف القرص التلقائية لمنع استهلاك المعالج وقراءة القرص المتكررة
  static const Duration minCleanupInterval = Duration(minutes: 15);

  /// الحد الأقصى لأبعاد فك تشفير الصور في الذاكرة العشوائية لمنع استهلاك الرام (OOM)
  static const int defaultMaxMemCacheWidth = 1080;
  static const int defaultThumbnailMemCacheWidth = 320;

  /// ميزانية كاش الصور في الذاكرة العشوائية (RAM) لمحرك فلاتر
  /// 50 ميجابايت كحد أقصى (مقارنة بـ 100 ميجابايت الافتراضية في Flutter) لحماية الأجهزة الضعيفة (2GB-3GB RAM)
  static const int maxMemoryCacheSizeBytes = 50 * 1024 * 1024; // 50 MB

  /// الحد الأقصى لعدد الصور المحتفظ بها مفكوكة في ذاكرة RAM
  static const int maxMemoryCacheImages = 150;

  /// عتبة عمر الملفات المؤقتة المهجورة (.tmp و .download) لاعتبارها يتيمة وحذفها بأمان
  static const Duration staleTempFileThreshold = Duration(minutes: 30);

  /// نافذة حماية الملفات التي تم تنزيلها أو كتابتها حديثاً جداً لمنع حذفها أثناء التنزيل النشط
  static const Duration activeWriteWindow = Duration(seconds: 15);

  /// الفاصل الزمني لكبح الفحص السريع لتجاوز الحد الأقصى (30 ثانية) لتفادي مسح القرص على كل إطار
  static const Duration quickCheckInterval = Duration(seconds: 30);
}
