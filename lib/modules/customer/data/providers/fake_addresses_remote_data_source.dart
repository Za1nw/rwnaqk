import 'package:rwnaqk_frontend/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';

/// تطبيق وهمي (Fake) لمستودع العناوين يعمل بالذاكرة لاختبارات Mock.
class FakeAddressesRepository implements IAddressesRepository {
  FakeAddressesRepository({List<ShippingAddress>? initialAddresses}) {
    if (initialAddresses != null && initialAddresses.isNotEmpty) {
      _addresses = List.from(initialAddresses);
    } else {
      _seed();
    }
  }

  late List<ShippingAddress> _addresses;

  void _seed() {
    _addresses = [
      const ShippingAddress(
        id: '1',
        country: Mk.countryYemen,
        address: 'صنعاء، شارع الزبيري، جوار بنك اليمن الدولي',
        city: 'أمانة العاصمة',
        postcode: 'الوحدة',
        isDefault: true,
        isServiceable: true,
        coverageStatus: 'in_district',
      ),
      const ShippingAddress(
        id: '2',
        country: Mk.countryYemen,
        address: 'عدن، خور مكسر، حي السفارات',
        city: 'عدن',
        postcode: 'خور مكسر',
        isDefault: false,
        isServiceable: true,
        coverageStatus: 'in_district',
      ),
    ];
  }

  @override
  Future<List<ShippingAddress>> getAddresses() async {
    return List.unmodifiable(_addresses);
  }

  @override
  Future<ShippingAddress> createAddress(ShippingAddress address) async {
    final isFirst = _addresses.isEmpty;
    final isPrimary = isFirst || address.isDefault;

    if (isPrimary) {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
    }

    final newAddr = address.copyWith(
      id: address.id.isNotEmpty
          ? address.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      isDefault: isPrimary,
      isServiceable: address.isServiceable,
      coverageStatus: address.coverageStatus,
    );

    _addresses.add(newAddr);
    return newAddr;
  }

  @override
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx == -1) {
      throw Exception('العنوان غير موجود');
    }

    if (address.isDefault) {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
    }

    _addresses[idx] = address;
    return address;
  }

  @override
  Future<void> deleteAddress(String id) async {
    final idx = _addresses.indexWhere((a) => a.id == id);
    if (idx == -1) return;

    final wasDefault = _addresses[idx].isDefault;
    _addresses.removeAt(idx);

    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
  }

  @override
  Future<ShippingAddress> setPrimaryAddress(String id) async {
    final idx = _addresses.indexWhere((a) => a.id == id);
    if (idx == -1) {
      throw Exception('العنوان غير موجود');
    }

    _addresses = _addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    return _addresses.firstWhere((a) => a.id == id);
  }

  /// مسح العناوين المحلية عند تسجيل الخروج
  void clear() {
    _addresses.clear();
  }
}

