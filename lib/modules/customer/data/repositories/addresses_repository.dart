import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';

/// عقد المستودع النقي الخاص بإدارة عناوين شحن العملاء.
///
/// هذا العقد مستقل تماماً عن GetX ولا يحتوي على أي عناصر تحكم بالواجهة،
/// مما يتيح التبديل الآمن بين السيرفر الحقيقي [AddressesRepositoryImpl]
/// والبيانات التجريبية [FakeAddressesRepository].
abstract class IAddressesRepository {
  /// جلب كافة عناوين العميل المصادق
  Future<List<ShippingAddress>> getAddresses();

  /// إضافة عنوان شحن جديد
  Future<ShippingAddress> createAddress(ShippingAddress address);

  /// تعديل عنوان شحن موجود
  Future<ShippingAddress> updateAddress(ShippingAddress address);

  /// حذف عنوان شحن
  Future<void> deleteAddress(String id);

  /// تعيين عنوان محدد كعنوان افتراضي
  Future<ShippingAddress> setPrimaryAddress(String id);
}

