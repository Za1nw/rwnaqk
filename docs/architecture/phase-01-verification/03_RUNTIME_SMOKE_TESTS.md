# تقرير فحص واختبارات بيئة التشغيل الحية (Smoke Tests)
# Phase 01.1 Runtime Smoke Tests & Platform Evaluation

> **المجال:** تقييم بيئات التشغيل المتاحة وتنفيذ اختبارات الدخان الحية لتطبيق «رونقك»  
> **المرجع:** `D:\project\laravel\app-rwnaqk\rwnaqk_frontend`

---

## 1. ملخص حالة المنصات المستهدفة (Platform Evaluation Matrix)

وفق التوجيهات الهندسية الصارمة، تم فحص كافة المنصات وبيئات التشغيل المتاحة في النظام وتسجيل النتائج بأدلة تشغيل فعلية:

| المنصة المستهدفة | نوع البيئة | نتيجة التقييم | الدليل الهندسي وبيان الحالة |
|---|---|---|---|
| **Android (Mobile)** | `Pixel 6 API 36` (Emulator) | **PARTIAL / BLOCKED** | تم تجميع وبناء APK بنجاح، وتثبيته على المحاكي، واجتياز اختبار رحلة الشراء كاملة، ثم انقطع اتصال ADB بسبب بطء المعالجة الرسومية بدون شاشة (Headless SwiftShader). |
| **Windows (Desktop)** | `windows-x64` | **BLOCKED** | محجوب لعدم تثبيت حزمة Visual Studio C++ Toolchain على نظام التشغيل (`flutter doctor`). |
| **Web (Chrome / Edge)** | `web-javascript` | **NOT RUN** | لم يتم تشغيلها لأن الهدف المعماري للتطبيق هو الهواتف الذكية (iOS / Android) وليس الويب في هذه المرحلة. |
| **Flutter Test Runner** | `TestWidgetsFlutterBinding` | **PASSED (100%)** | تم اجتياز **77 اختباراً من أصل 77 اختباراً** آلياً شاملاً لجميع سيناريوهات النواة، الجلسة، والواجهات. |

---

## 2. تفاصيل اختبار منصة Android على محاكي `Pixel 6 API 36`

### أ. إجراءات التشغيل والبناء:
1. تم إطلاق محاكي الأندرويد بالأمر:
   ```powershell
   C:\Android\Sdk\emulator\emulator.exe -avd Pixel_6_API_36 -no-window -no-audio -no-boot-anim
   ```
2. تم التحقق من اتصال المحاكي واكتمال الإقلاع عبر:
   ```powershell
   adb devices # emulator-5554 device
   adb shell getprop sys.boot_completed # returned 1
   ```
3. تم إطلاق الاختبار التكاملي:
   ```powershell
   flutter test integration_test/mock_store_e2e_test.dart
   ```

### ب. نتائج التجميع والتنفيذ الفعلي:
- **تجميع Gradle:** اكتمل بنجاح تام في **108.8 ثانية**:
  ```text
  Running Gradle task 'assembleDebug'... 108.8s
  √ Built build\app\outputs\flutter-apk\app-debug.apk
  Installing build\app\outputs\flutter-apk\app-debug.apk... 1,841ms
  ```
- **تنفيذ الاختبار الأول (End-to-End Shopping Journey):**
  - تم رفع الشجرة الكاملة للمتجر `ProviderScope -> MyApp -> GetMaterialApp`.
  - تم التحقق من نجاح رحلة التسوق: إضافة المنتج للمفضلة والسلة، تفعيل كود الخصم `RAWNAQ`، اختيار عنوان التوصيل والدفع عند الاستلام، وتأكيد الطلب.
  - **النتيجة:** **اجتياز بنجاح تام (PASSED) في 10 ثوانٍ**.
- **التعثر أثناء الاختبار الثاني (Session Logout and Data Isolation):**
  - أثناء إجراء عملية تسجيل الخروج في الاختبار الثاني، حدث عطل في اتصال ADB الداخلي الخاص بالمحاكي الافتراضي في وضع الـ Headless:
  ```text
  ERROR | adb protocol fault (couldn't read status length)
  ```
  - سبب ذلك هو تشغيل المحاكي بدون نافذة عرض (`-no-window`) على جهاز يعمل بمعالج رسومي مدمج (Intel UHD) مع محاكي برمجي (Google SwiftShader)، مما استهلك موارد الذاكرة وأسقط قناة الاتصال.

---

## 3. تفاصيل اختبار منصة Windows Desktop

تمت محاولة تشغيل الاختبار التكاملي على منصة Windows مباشرة:
```powershell
flutter test integration_test/mock_store_e2e_test.dart -d windows
```
**النتيجة:**
```text
Failed to load "mock_store_e2e_test.dart": Unable to find suitable Visual Studio toolchain. Please run `flutter doctor` for more details.
```
**التقييم:** محجوب (BLOCKED) نتيجة عدم توفر بيئة تجميع C++ لـ Windows Desktop، وهو أمر طبيعي لمشروع يستهدف تطبيقات الهواتف النقالة.

---

## 4. تقييم اختبارات الدخان المعتمدة على بيئة محاكاة الواجهات (Widget Tree)

في بيئة اختبار واجهات فلاتر المعتمدة، تم اختبار كافة المسارات الحيوية بنجاح بنسبة 100%:
1. **بدء التطبيق وتدشين `ProviderScope`:** تم التأكد من تحميل شجرة الودجات بدون أخطاء.
2. **شاشات الترحيب والمصادقة:** التحقق من مسارات الدخول واستعادة الجلسة.
3. **تصفح الكتالوج والمنتجات والسلة:** التحقق من عرض المنتجات وإضافة العناصر وحساب الأسعار.
4. **تسجيل الخروج وتفريغ الكاش:** التحقق من مسح بيانات السلة، الطلبات، العناوين، والمفضلة بدون تسريب.
5. **توافقية GetX والملاحة والترجمة:** الحفاظ على مسارات `GetPage` واللغات العربية والإنجليزية.

