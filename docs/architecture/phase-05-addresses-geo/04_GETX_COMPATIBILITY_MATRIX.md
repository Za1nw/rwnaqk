# مصفوفة التوافقية مع GetX ونمط الكاتب الأوحد للمرحلة 05
# 04 — GETX COMPATIBILITY MATRIX: Single-Writer Bridge & Consumer Preservation

- **المشروع:** متجر رونقك الإلكتروني (`Rawnaquk E-Commerce`)
- **الموديول:** `lib/modules/customer/` و `lib/modules/cart/` و `lib/modules/orders/`
- **حالة التوافقية:** **توافق كامل بنسبة 100% دون ازدواجية في التخزين**

---

## 1. مبدأ الكاتب الأوحد وحظر التخزين المزدوج (Single-Writer Principle)

وفقاً للقواعد الإلزامية غير القابلة للتفاوض (`00-store-project-guardrails.md` و `10-getx-and-portability.md`):
1. **مصدر الحقيقة الأوحد:** يجب أن تكون حاوية Riverpod (`addressesProvider`) هي المستودع الحصري الوحيد لحالة عناوين الشحن.
2. **منع التخزين المزدوج (Zero Dual Storage):** يُحظر احتفاظ طبقة GetX بقوائم عناوين مستقلة تجري عليها عمليات تعديل أو حذف بمعزل عن Riverpod.
3. **الجسر أحادي الاتجاه (Unidirectional Sync Bridge):** تتدفق التحديثات حصرياً من Riverpod إلى مسقط GetX التوافقي (`ProfileStoreService.addresses`)، بينما تُمرر الأوامر والطلبات من GetX إلى Riverpod عبر واجهة تفويضية رقيقة (`AddressesService`).

---

## 2. تفاصيل هندسة الجسر التوافقي (Bridge Architecture)

### 2.1. مسقط البيانات في `ProfileStoreService`
في [profile_store_service.dart](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/customer/controllers/profile_store_service.dart):

```dart
// اشتراك أحادي الاتجاه ينقل أي تحديث لحالة العناوين فور حدوثه في Riverpod
_addressesSubscription = _container.listen<AddressesState>(
  addressesProvider,
  (previous, next) {
    if (!listEquals(addresses, next.addresses)) {
      addresses.assignAll(next.addresses);
      _syncLocationFromAddresses();
    }
  },
  fireImmediately: true,
);
```
- الحقل `RxList<ShippingAddress> addresses` أصبح **مسقطاً تفاعلياً للقراءة فقط** (`Read-Only Reactive Projection`).
- عند حدوث أي تعديل (إضافة، تعديل، حذف، مسح للجلسة)، يُحدّث Riverpod حالته، فيلتقط الاشتراك الحدث ويحدّث `addresses.assignAll`، مما يدفع كافة شاشات GetX المعتمدة على `Obx` لإعادة البناء فوراً وبشكل متزامن.

### 2.2. واجهة التفويض في `AddressesService`
في [addresses_service.dart](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/customer/controllers/addresses_service.dart):

```dart
class AddressesService {
  // تفويض كامل لـ Riverpod Notifier
  AddressesNotifier get _notifier => _container.read(addressesProvider.notifier);

  List<ShippingAddress> get addresses =>
      _container.read(addressesProvider).addresses;

  Future<List<ShippingAddress>> loadAddresses() async {
    return _notifier.loadAddresses();
  }

  Future<void> addAddress(ShippingAddress address) async {
    await _notifier.addAddress(address);
  }

  Future<void> updateAddress(ShippingAddress address) async {
    await _notifier.updateAddress(address);
  }

  Future<void> deleteAddress(String id) async {
    await _notifier.deleteAddress(id);
  }

  Future<void> setDefaultAddress(String id) async {
    await _notifier.setDefaultAddress(id);
  }
}
```

---

## 3. مصفوفة مستهلكي حالة العناوين عبر النظام (Address State Consumers Matrix)

| المكون المستهلك | إطار العمل الحالي | نقطة الوصول للبيانات | نوع الاستهلاك | حالة التوافقية بعد المرحلة 05 |
|---|---|---|---|---|
| `AddressesScreen` | GetX (`GetView`) | `controller.addresses` عبر `ProfileStoreService` | تفاعلي (`Obx`) | يعمل بكفاءة تامة دون أدنى تغيير في كود الواجهة. |
| `AddressesController` | GetX (`GetxController`) | `AddressesService` | أوامر CRUD وإدارة الفورم | تم تحويله إلى وسيط يرسل الأوامر لـ Riverpod. |
| `ShippingAddressSheet` | GetX / Flutter | `AddressesController` | حفظ وتعديل العنوان | حفظ مباشر مع التحقق الجغرافي. |
| `ProfileStoreService` | GetX (`GetxService`) | `addressesProvider` | مسقط عام للحساب | يستمع لـ Riverpod ويحدّث `location` والافتراضي. |
| `CartController` | GetX (`GetxController`) | `ProfileStoreService.defaultAddress` | حساب تكلفة التوصيل | قراءة سليمة ومتزامنة بنسبة 100%. |
| `CheckoutController` | GetX (`GetxController`) | `ProfileStoreService.addresses` و `defaultAddress` | اختيار عنوان الشحن للطلب | قراءة متوافقة لإنشاء الطلب في Laravel. |
| `OrdersController` | GetX (`GetxController`) | `ShippingAddress` DTO | ربط العنوان بالطلب المكتمل | عقود DTO مطابقة لعقود واجهة برمجة تطبيقات Laravel. |

---

## 4. إثبات عدم الانحراف ومنع التسريب (Zero-Drift & Leakage Verification)

1. **انعدام الانحراف الزمني (Zero Drift):** تم التحقق في الاختبار `ProfileStoreService.addresses reactively reflects Riverpod addressesProvider updates` من أن أي تغيير يتم عبر Riverpod ينعكس في نفس الإطار (`same microtask`) داخل `ProfileStoreService.addresses`.
2. **منع الكتابة المباشرة الملتوية:** تم إلغاء أي دوال في `AddressesService` كانت تعدل مباشرة في `profileStore.addresses` دون استدعاء Riverpod، وبات المسار الإلزامي لكافة العمليات يمر حصراً عبر `AddressesNotifier`.

