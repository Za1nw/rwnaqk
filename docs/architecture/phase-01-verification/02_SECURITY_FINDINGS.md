# التقرير الأمني وفحص سلامة التخزين والجلسات
# Phase 01.1 Security Findings — Storage Audit & Session Lifecycles

> **المجال:** فحص أمني تفصيلي لـ `SecureAuthTokenStorage` و `ApiClient` و `AuthSessionService`  
> **التصنيف:** مراجعة أمنية لنواة التخزين والاتصال بالشبكة  
> **المرجع:** `D:\project\laravel\app-rwnaqk\rwnaqk_frontend`

---

## 1. الثغرة الأولى: تسرب التوكن غير المشفر كبديل في الإنتاج (Plaintext Fallback Vulnerability)

### التوصيف والموقع:
- **الملف:** [`lib/core/services/auth/auth_token_storage.dart`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/services/auth/auth_token_storage.dart#L79-L85)
- **الخطورة:** **عالية (High Severity / CVSS 7.4)**
- **الكود المرصود قبل الإصلاح:**
  ```dart
  try {
    await _storage.write(key: LocalStorageKeys.authToken, value: normalized);
  } catch (e) {
    debugPrint('[SecureStorage] Warning writing to secure storage: $e');
    // في بيئة الاختبارات أو الأجهزة التي لا تدعم Keystore، كتابة كاحتياط
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalStorageKeys.authToken, normalized);
    return;
  }
  ```

### سيناريو الاستغلال والمخاطر:
1. تم وضع هذا الكود لتمرير الاختبارات الأحادية عند غياب قنوات المنصة الحقيقية (`MissingPluginException`).
2. ولكن في بيئة الإنتاج على أجهزة المستخدمين، في حال واجه نظام التشفير `Android Keystore` أو `iOS Keychain` خطأ في التهيئة أو قفل الشاشة، كان التوكن يُكتب فوراً داخل ملف `SharedPreferences.xml` العادي بدون أي تشفير!
3. هذا يجعل رمز مصادقة العميل (Bearer JWT) عرضة للقراءة من خلال النسخ الاحتياطي للنظام (Android ADB Backup)، أو الأجهزة المروّتة، أو أي تطبيق آخر يستغل ثغرات نظام الملفات، مما يتيح انتحال شخصية العميل بالكامل والوصول لبياناته وطلباته.

### المعالجة الهندسية المنفذة:
- تم إلغاء استدعاء `prefs.setString` نهائياً من دالة `writeToken`.
- في وضع الإنتاج (`kReleaseMode`)، يتم إطلاق الخطأ (`rethrow`) لعدم السماح بإنشاء جلسة غير مؤمنة.
- تم قصر التعامل مع `SharedPreferences` حصراً على دالة `readToken` لقراءة التوكنات القديمة مرة واحدة وترحيلها إلى التخزين المشفر ثم حذفها فوراً (`prefs.remove`).
- تم التحقق باختبار الوحدة من أن التخزين المشفر يمسح التوكن من `SharedPreferences` ولا يعود لكتابته فيها إطلاقاً.

---

## 2. الثغرة الثانية: تدمير الجلسة النشطة عبر استجابات 401 المتأخرة (Stale 401 Session Hijack)

### التوصيف والموقع:
- **الملف:** [`lib/core/network/api_client.dart`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/network/api_client.dart#L96-L105) و [`lib/core/services/auth/auth_session_service.dart`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/services/auth/auth_session_service.dart#L175-L195)
- **الخطورة:** **متوسطة إلى عالية (Medium-High / Denial of Service on Session)**

### سيناريو الاستغلال والمخاطر:
1. قام المستخدم (أ) بفتح شاشة تطلق استدعاء شبكة بطيء (مثل جلب تفاصيل طلب معقد) باستخدام `Token_A`.
2. قبل اكتمال الطلب، قام المستخدم (أ) بتسجيل الخروج، وسجّل المستخدم (ب) دخوله بنفس التطبيق وحصل على `Token_B` ساري المفعول.
3. بعد ثوانٍ، انتهى طلب المستخدم (أ) وأرجع الخادم رمز `401 Unauthorized` (لأن `Token_A` أُلغي على الخادم).
4. استقبل `ApiClient` رمز 401 واستدعى `onUnauthorized()` بشكل أعمى دون التحقق من أي توكن تسبب في هذا الخطأ.
5. قامت `AuthSessionService.handleUnauthorized()` بحذف التوكن النشط حالياً من الذاكرة والتخزين، وتدمير جلسة المستخدم (ب) الجديد، وتوجيهه قسراً لشاشة الدخول!

### المعالجة الهندسية المنفذة:
1. تزويد `ApiClient` بـ `onUnauthorizedWithToken(String failedToken)`، حيث يتم استخراج التوكن من ترويسة الطلب الفعلي (`Authorization: Bearer <token>`).
2. تزويد `AuthSessionService.handleUnauthorized({String? failedToken})` بالتحقق الصارم:
   ```dart
   if (failedToken != null && failedToken.isNotEmpty) {
     final currentToken = (token.value ?? '').trim();
     if (currentToken.isNotEmpty && currentToken != failedToken) {
       debugPrint('[AuthSession] Stale 401 ignored: request token does not match active session.');
       return; // تجاهل الخطأ القديم لحماية الجلسة النشطة الجديدة
     }
   }
   ```
3. تم إثبات هذه الحماية عبر السيناريو الاختباري رقم (4) في `test/phase1_verification_test.dart`.

---

## 3. الثغرة الثالثة: تفعيل خروج خاطئ عند فشل تسجيل الدخول العادي

### التوصيف والموقع:
- إذا قام مستخدم بإدخال بريد إلكتروني أو كلمة مرور خاطئة في شاشة تسجيل الدخول، يُرجع خادم Laravel رمز 401.
- في السابق، كان هذا الاستدعاء يطلق `onUnauthorized` كأي طلب شبكة آخر، مما كان يطلق روتين تنظيف الكاش وإعادة التوجيه رغم أن المستخدم لم يسجل دخوله بعد.

### المعالجة الهندسية المنفذة:
- في `ApiClient`: يتم فحص ما إذا كان الطلب الفاشل يحتوي على ترويسة `Authorization: Bearer ...`.
- طلبات تسجيل الدخول (Login) بطبيعتها لا تحتوي على توكن Bearer، وبالتالي يتم تجاهل إطلاق رد نداء إنهاء الجلسة، والاكتفاء بإرجاع استثناء `UnauthorizedException` لشاشة تسجيل الدخول لعرض رسالة "بيانات الدخول غير صحيحة" للمستخدم.

---

## 4. الثغرة الرابعة: توقف دورة التطهير عند حدوث استثناء في دوال الكاش

### التوصيف والموقع:
- في حال كان أحد المتحكمات المرتبطة بـ `onSessionTerminated` يحتوي على خطأ رمى استثناءً (Exception) أثناء تفريغ السلة أو العناوين، كان ذلك يقطع تنفيذ دالة `handleUnauthorized()` قبل إتمام التوجيه لشاشة تسجيل الدخول.

### المعالجة الهندسية المنفذة:
- تم لف استدعاء `onSessionTerminated?.call()` داخل كتلة `try / catch` مستقلة لمنع أي خلل في دوال المستمعين من تعطيل تنظيف التوكن أو توجيه المستخدم بأمان.

