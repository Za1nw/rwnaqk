import 'package:rwnaqk/models/wallet_transfer_account.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/models/shipping_address.dart';

class ProfileStoreService extends GetxService {
  /// قائمة حسابات المحافظ للتحويل (يتم التحكم فيها من الأدمن)
  final walletAccounts = <WalletTransferAccount>[
    WalletTransferAccount(
      id: 'jib',
      companyName: 'Jib',
      receiverName: 'Rwnaqk Store',
      walletNumber: '777123456',
      icon: Icons.account_balance_wallet_outlined,
    ),
    WalletTransferAccount(
      id: 'onecash',
      companyName: 'OneCash',
      receiverName: 'Rwnaqk Store',
      walletNumber: '775987654',
      icon: Icons.payments_outlined,
    ),
    WalletTransferAccount(
      id: 'kuraimi',
      companyName: 'Kuraimi',
      receiverName: 'Rwnaqk Store',
      walletNumber: '782456123',
      icon: Icons.account_balance,
    ),
  ].obs;

  WalletTransferAccount? get defaultWalletAccount {
    if (walletAccounts.isEmpty) return null;
    return walletAccounts.first;
  }

  final name = 'Zain Al-Zubair'.obs;
  final phone = '+967 772923592'.obs;
  final email = 'zain@rwnaq.app'.obs;
  final passwordPreview = '************'.obs;
  final avatarPath = ''.obs;
  final avatarUrl = ''.obs;
  final addresses = <ShippingAddress>[].obs;

  ShippingAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  String get location {
    final current = defaultAddress;
    if (current == null) return _localizedValue(ar: 'تعز', en: 'Taiz');
    return [current.district, current.governorate]
        .where((item) => item.trim().isNotEmpty)
        .join(', ');
  }

  void seedAddressesIfNeeded() {
    if (addresses.isNotEmpty) return;

    addresses.assignAll([
      ShippingAddress(
        id: '1',
        governorate: _localizedValue(ar: 'تعز', en: 'Taiz'),
        district: _localizedValue(ar: 'القاهرة', en: 'Al Qahirah'),
        street: _localizedValue(ar: 'شارع جمال', en: 'Jamal Street'),
        addressDetails: _localizedValue(
            ar: 'عمارة السلام، أمام الجامعة',
            en: 'Al Salam Building, in front of the university'),
        isDefault: true,
      ),
      ShippingAddress(
        id: '2',
        governorate: _localizedValue(ar: 'عدن', en: 'Aden'),
        district: _localizedValue(ar: 'المنصورة', en: 'Al Mansoura'),
        street: _localizedValue(ar: 'شارع الكورنيش', en: 'Corniche Street'),
        addressDetails: _localizedValue(
            ar: 'بجوار مول الخليج', en: 'Next to Al Khalij Mall'),
      ),
    ]);
  }

  void updateProfile({
    required String nextName,
    required String nextEmail,
  }) {
    name.value = nextName;
    email.value = nextEmail;
  }

  void updateAvatarPath(String? path) {
    avatarPath.value = (path ?? '').trim();
  }

  ShippingAddress currentShippingAddress() {
    final current = defaultAddress;
    if (current == null) {
      return ShippingAddress.empty();
    }
    return current;
  }

  void saveDefaultShippingAddress(ShippingAddress model) {
    final next = ShippingAddress(
      id: defaultAddress?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      governorate: model.governorate,
      district: model.district,
      street: model.street,
      addressDetails: model.addressDetails,
      isDefault: true,
    );

    if (addresses.isEmpty) {
      addresses.assignAll([next]);
      return;
    }

    final currentDefault = defaultAddress;
    final existingIndex = currentDefault == null
        ? -1
        : addresses.indexWhere((item) => item.id == currentDefault.id);

    final updated = addresses
        .map((item) => item.copyWith(isDefault: false))
        .toList(growable: true);

    if (existingIndex != -1) {
      updated[existingIndex] = next;
    } else {
      updated.insert(0, next);
    }

    addresses.assignAll(updated);
  }

  String _localizedValue({
    required String ar,
    required String en,
  }) {
    return (Get.locale?.languageCode ?? 'en') == 'ar' ? ar : en;
  }
}
