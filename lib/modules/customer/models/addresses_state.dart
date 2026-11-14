import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';

/// كائن الحالة النقي غير القابل للتعديل الخاص بعناوين شحن العميل [AddressesState]
@immutable
class AddressesState {
  const AddressesState({
    this.addresses = const <ShippingAddress>[],
    this.selectedAddressId,
    this.activeUserId,
    this.sessionGeneration = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  /// قائمة عناوين الشحن المحفوظة للعميل
  final List<ShippingAddress> addresses;

  /// معرف العنوان المختار للشحن حالياً
  final String? selectedAddressId;

  /// معرف العميل صاحب العناوين (لعزل الحسابات ومنع تسرب البيانات)
  final String? activeUserId;

  /// رقم جيل الجلسة لمنع الردود الشبكية المتأخرة من تلويث الحالة
  final int sessionGeneration;

  /// حالة تحميل البيانات من الخادم
  final bool isLoading;

  /// رسالة الخطأ إن وُجدت
  final String? errorMessage;

  /// العنوان المختار حالياً (أو الافتراضي إن لم يُحدد يدويّاً)
  ShippingAddress? get selectedAddress {
    if (selectedAddressId != null) {
      for (final a in addresses) {
        if (a.id == selectedAddressId) return a;
      }
    }
    return defaultAddress;
  }

  /// العنوان الافتراضي لتوصيل الطلبات (مرجعية الخادم Laravel حصرية دون تخمين)
  ShippingAddress? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return null;
  }

  /// هل القائمة فارغة؟
  bool get isEmpty => addresses.isEmpty;

  /// هل القائمة تحتوي على عناوين؟
  bool get isNotEmpty => addresses.isNotEmpty;

  AddressesState copyWith({
    List<ShippingAddress>? addresses,
    String? selectedAddressId,
    bool clearSelectedAddressId = false,
    String? activeUserId,
    bool clearActiveUserId = false,
    int? sessionGeneration,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AddressesState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: clearSelectedAddressId
          ? null
          : (selectedAddressId ?? this.selectedAddressId),
      activeUserId: clearActiveUserId
          ? null
          : (activeUserId ?? this.activeUserId),
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressesState &&
        listEquals(other.addresses, addresses) &&
        other.selectedAddressId == selectedAddressId &&
        other.activeUserId == activeUserId &&
        other.sessionGeneration == sessionGeneration &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(addresses),
        selectedAddressId,
        activeUserId,
        sessionGeneration,
        isLoading,
        errorMessage,
      );
}

