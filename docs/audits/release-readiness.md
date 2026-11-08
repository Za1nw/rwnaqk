# تقرير جاهزية الإطلاق والتشغيل (Release & Production Readiness)

**النافذة الزمنية:** 7 إلى 14 يومًا حتى الإطلاق.  
**الهدف:** فحص كافة المتطلبات التقنية، الأمنية، والتنظيمية اللازمة لنشر تطبيق المتجر الإلكتروني على Google Play و Apple App Store وتشغيله بثبات في بيئة الإنتاج.

---

## 1. قائمة التحقق الإلزامية للإطلاق (Production Release Gates)

| البند | المتطلب الفني | الحالة الحالية | الإجراء المطلوب قبل النشر | الأولوية |
|---|---|---|---|---|
| **اتصال HTTPS** | حظر الاتصالات غير المشفرة `http://` في الإنتاج | معتمد حالياً على `http://192.168.8.124:8000` | ضبط دومين رسمي مع شهادة SSL فعالة (`https://api.rwnaqk.com`) | **P0** |
| **توقيع التطبيق (Android)** | إعداد `key.properties` ومفتاح التوقيع `keystore` | غير مكتمل (مفتاح تصحيح افتراضي debug) | إنشاء Release Keystore وتأمينه خارج Git | **P0** |
| **حماية بيانات التوكن** | تشفير وحماية توكن العميل من الاستخراج | يستخدم `SharedPreferences` نص عادي | حظر طباعة التوكن في السجلات وتشفير التخزين | **P1** |
| **حظر سجلات التصحيح** | إيقاف `print` و `debugPrint` لبيانات العملاء | مفعل عبر `ENABLE_DEBUG_LOGS=true` | ضبط `ENABLE_DEBUG_LOGS=false` في بيئة الإنتاج | **P0** |
| **رصد الانهيارات (Crash)** | تسجيل أخطاء التطبيق اللحظية | يكتفي بـ `catch` محلي وتنبيهات | ربط `PlatformDispatcher.instance.onError` بمجمع أخطاء | **P1** |
| **صفحات الخصوصية والشروط** | روابط سارية لسياسة الخصوصية وحذف الحساب | روابط وهمية `/terms` و `/privacy` | نشر صفحات ويب قانونية حقيقية وتضمينها | **P0** |
| **أداء وحجم التطبيق** | تفعيل تقليص الكود وحماية الهندسة العكسية | R8 / ProGuard الافتراضي | تفعيل R8 والـ Obfuscation في `flutter build appbundle` | **P1** |
| **استقرار المعاملات** | اختبار دورة شراء حقيقية من السلة حتى التأكيد | يعتمد على محاكاة محلية | تنفيذ تجربة شراء فعلية عبر Staging | **P0** |

---

## 2. الإعدادات الأمنية والشبكية (Security & Networking)

### 2.1. فرض بروتوكول HTTPS وحظر Cleartext
في ملف `android/app/src/main/AndroidManifest.xml`:
* يجب التأكد من عدم السماح بـ `android:usesCleartextTraffic="true"` في وضع الإصدار (`release`).
* إضافة فحص أمان داخل [app_env.dart](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/constants/app_env.dart):
  ```dart
  static String get apiBaseUrl {
    final url = dotenv.get('API_BASE_URL', fallback: 'https://api.rwnaqk.com');
    if (isProduction && url.startsWith('http://')) {
      throw StateError('Insecure HTTP connection is prohibited in Production!');
    }
    return url;
  }
  ```

### 2.2. تنظيف السجلات وحماية الخصوصية (Zero-Leak Logging)
* منع طباعة أي تفاصيل حساسة (مثل أرقام الهواتف، كلمات المرور، أو رموز التحويل) في الـ Console.
* ضبط دالة التسجيل بحيث تعمل فقط عند `AppEnv.enableDebugLogs == true`:
  ```dart
  void appLog(String message) {
    if (AppEnv.enableDebugLogs) {
      debugPrint('[RWNAQK]: $message');
    }
  }
  ```

---

## 3. متطلبات متاجر التطبيقات (Store Guidelines Compliance)

1. **حذف الحساب (Account Deletion Requirement):**
   * تفرض Google Play و Apple App Store توفير خيار صريح ومباشر داخل التطبيق يتيح للمستخدم حذف حسابه وبياناته نهائياً.
   * **المطلوب:** إضافة زر "حذف الحساب" داخل شاشة الإعدادات يستدعي `DELETE /api/v1/customer/account`.
2. **شروط الخدمة وسياسة الخصوصية:**
   * يجب أن تكون الروابط المعرفة في `AppEnv.termsUrl` و `AppEnv.privacyPolicyUrl` روابط ويب حقيقية ومتاحة للجمهور بدون تسجيل دخول.

---

## 4. استراتيجية التراجع والتعافي السريع (Rollback & Recovery Plan)

في حال ظهور خلل حرج عقب إطلاق النسخة:
1. **التحكم بالبيانات عبر السيرفر (Server Feature Flags):**
   - يوفر الباك إند إمكانية تعطيل الدفع بالمحافظ مؤقتاً والاعتماد على الدفع عند الاستلام فقط بنقرة واحدة من لوحة التحكم، دون الحاجة لرفع تحديث جديد للمتجر.
2. **إصدار التحديث الطارئ (Hotfix Deployment):**
   - تجهيز سكريبت بناء آلي سريع يرفع رقم الإصدار في `pubspec.yaml` (مثلاً من `1.0.0+1` إلى `1.0.1+2`) ويُبنى خلال 10 دقائق.

