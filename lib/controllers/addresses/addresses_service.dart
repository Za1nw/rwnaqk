import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/models/shipping_address.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة العناوين.
///
/// نستخدمه لفصل:
/// - الدول المتاحة
/// - البيانات التجريبية
/// - منطق تعيين الافتراضي
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لجلب العناوين وحفظها وحذفها من السيرفر.
class AddressesService {
  AddressesService(this._store);

  final ProfileStoreService _store;

  /// الدول المتاحة داخل نموذج العنوان.
  List<String> get countries => AppMockContentUtils.localizedCountries();

  /// هذه الدالة تعيد عناوين تجريبية جاهزة.
  List<ShippingAddress> seedMockAddresses() {
    _store.seedAddressesIfNeeded();
    return _store.addresses.toList(growable: false);
  }

  /// هذه الدالة تعيد قائمة جديدة مع جعل عنوان واحد فقط هو الافتراضي.
  List<ShippingAddress> markDefault({
    required List<ShippingAddress> addresses,
    required String id,
  }) {
    final list = addresses.toList();

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isDefault: list[i].id == id);
    }

    return list;
  }

  /// هذه الدالة تضمن بقاء عنوان افتراضي بعد الحذف.
  ///
  /// إذا لم يعد هناك عنوان افتراضي بعد الحذف وكان هناك عناصر متبقية،
  /// يتم جعل أول عنوان هو الافتراضي.
  List<ShippingAddress> buildDefaultAfterDelete(List<ShippingAddress> addresses) {
    if (addresses.isEmpty) return addresses;

    final hasDefault = addresses.any((e) => e.isDefault);
    if (hasDefault) return addresses;

    final list = addresses.toList();
    list[0] = list[0].copyWith(isDefault: true);
    return list;
  }

  void saveAddresses(List<ShippingAddress> items) {
    _store.addresses.assignAll(items);
  }
}
