import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/providers/fake_addresses_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة العناوين.
///
/// نستخدمه لفصل:
/// - الدول المتاحة
/// - البيانات التجريبية
/// - منطق تعيين الافتراضي
/// - الربط مع مستودع العناوين [IAddressesRepository]
class AddressesService {
  AddressesService(this._store, {IAddressesRepository? repository})
      : _repo = repository;

  final ProfileStoreService _store;
  final IAddressesRepository? _repo;

  IAddressesRepository get repo =>
      _repo ??
      (Get.isRegistered<IAddressesRepository>()
          ? Get.find<IAddressesRepository>()
          : FakeAddressesRepository());

  /// الدول المتاحة داخل نموذج العنوان.
  List<String> get countries => AppMockContentUtils.localizedCountries();

  /// جلب كافة العناوين من السيرفر أو المستودع وتحديث المخزن المحلي
  Future<List<ShippingAddress>> loadAddresses() async {
    final list = await repo.getAddresses();
    _store.addresses.assignAll(list);
    return list;
  }

  /// إضافة عنوان جديد عبر المستودع وتحديث المخزن المحلي
  Future<ShippingAddress> addAddress(ShippingAddress address) async {
    final created = await repo.createAddress(address);
    if (created.isDefault) {
      final updated = _store.addresses.map((a) => a.copyWith(isDefault: false)).toList();
      updated.insert(0, created);
      _store.addresses.assignAll(updated);
    } else {
      _store.addresses.add(created);
    }
    return created;
  }

  /// تعديل عنوان موجود عبر المستودع
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    final updated = await repo.updateAddress(address);
    final list = _store.addresses.toList();
    final idx = list.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      if (updated.isDefault) {
        for (int i = 0; i < list.length; i++) {
          list[i] = list[i].copyWith(isDefault: list[i].id == updated.id);
        }
      }
      list[idx] = updated;
      _store.addresses.assignAll(list);
    }
    return updated;
  }

  /// حذف عنوان عبر المستودع
  Future<void> removeAddress(String id) async {
    await repo.deleteAddress(id);
    final next = _store.addresses.where((e) => e.id != id).toList();
    _store.addresses.assignAll(buildDefaultAfterDelete(next));
  }

  /// تعيين عنوان كافتراضي عبر المستودع
  Future<ShippingAddress> setPrimary(String id) async {
    final updated = await repo.setPrimaryAddress(id);
    final list = _store.addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    _store.addresses.assignAll(list);
    return updated;
  }

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
  List<ShippingAddress> buildDefaultAfterDelete(
    List<ShippingAddress> addresses,
  ) {
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
