import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk/models/customer_model.dart';
import 'package:rwnaqk/models/shipping_address.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';

class ProfileStoreService extends GetxService {
  ProfileStoreService(this._authSession);

  final AuthSessionService _authSession;
  late final Worker _customerWorker;

  final customer = Rxn<CustomerModel>();
  final avatarPath = ''.obs;

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

  final addresses = <ShippingAddress>[].obs;

  String get displayName {
    final current = customer.value;
    if (current == null) {
      return '';
    }

    return current.displayName;
  }

  String get phone {
    final current = customer.value;
    return (current?.mobile ?? '').trim();
  }

  String get email {
    final current = customer.value;
    return (current?.email ?? '').trim();
  }

  String get gender {
    return (customer.value?.gender ?? '').trim();
  }

  String get avatarUrl {
    return (customer.value?.avatarUrl ?? '').trim();
  }

  double get walletBalance {
    return customer.value?.walletBalance ?? 0;
  }

  bool get isEmailVerified {
    return customer.value?.hasVerifiedEmail ?? false;
  }

  bool get isBanned {
    return customer.value?.isBanned ?? false;
  }

  WalletTransferAccount? get defaultWalletAccount {
    if (walletAccounts.isEmpty) return null;
    return walletAccounts.first;
  }

  ShippingAddress? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  String get location {
    final current = defaultAddress;
    if (current == null) return 'Taiz';
    return '${current.city}, ${current.localizedCountry}';
  }

  @override
  void onInit() {
    super.onInit();
    _syncFromSession(_authSession.customer.value);
    _customerWorker = ever<CustomerModel?>(
      _authSession.customer,
      _syncFromSession,
    );
  }

  @override
  void onClose() {
    _customerWorker.dispose();
    super.onClose();
  }

  void _syncFromSession(CustomerModel? nextCustomer) {
    customer.value = nextCustomer;
  }

  void seedAddressesIfNeeded() {
    if (addresses.isNotEmpty) return;

    addresses.assignAll([
      ShippingAddress(
        id: '1',
        country: Mk.countryYemen,
        address: Mk.addressStreetMall.tr,
        city: Mk.cityTaiz.tr,
        postcode: '12345',
        isDefault: true,
      ),
      ShippingAddress(
        id: '2',
        country: Mk.countrySaudiArabia,
        address: Mk.addressKingRoad.tr,
        city: Mk.cityRiyadh.tr,
        postcode: '65432',
      ),
    ]);
  }

  void updateProfile({
    required String nextName,
    required String nextEmail,
    String? nextPhone,
  }) {
    _authSession.updateCustomer((current) {
      final updated = (current ?? const CustomerModel()).copyWith(
        fullName: nextName,
        email: nextEmail,
        mobile: nextPhone,
      );

      return updated;
    });
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
      id:
          defaultAddress?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      country: model.country,
      address: model.address,
      city: model.city,
      postcode: model.postcode,
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
}
