import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/providers/fake_addresses_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/customer/models/addresses_state.dart';

/// مزود مستودع العناوين النقي [IAddressesRepository]
final addressesRepositoryProvider = Provider<IAddressesRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AddressesRepositoryImpl(
    apiClient: client,
    fallbackRepository: FakeAddressesRepository(),
  );
});

/// موفر حالة عناوين الشحن الرئيسي [AddressesNotifier]
final addressesProvider =
    NotifierProvider<AddressesNotifier, AddressesState>(
  AddressesNotifier.new,
);

/// موفر العنوان المختار حالياً للتوصيل
final selectedAddressProvider = Provider<ShippingAddress?>((ref) {
  return ref.watch(addressesProvider).selectedAddress;
});

/// موفر العنوان الافتراضي لحساب العميل
final defaultAddressProvider = Provider<ShippingAddress?>((ref) {
  return ref.watch(addressesProvider).defaultAddress;
});

/// موفر قائمة العناوين المحفوظة
final customerAddressesListProvider = Provider<List<ShippingAddress>>((ref) {
  return ref.watch(addressesProvider).addresses;
});

/// المتحكم الحصري والكاتب الأوحد لحالة عناوين الشحن [AddressesNotifier]
class AddressesNotifier extends Notifier<AddressesState> {
  @override
  AddressesState build() {
    return const AddressesState();
  }

  IAddressesRepository get _repo => ref.read(addressesRepositoryProvider);

  /// جلب كافة عناوين الشحن من الخادم مع الحماية ضد الاستجابات الشبكية المتأخرة
  Future<List<ShippingAddress>> loadAddresses() async {
    final currentGen = state.sessionGeneration;
    final currentUserId = state.activeUserId;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final list = await _repo.getAddresses();

      // التحقق من أن الجلسة لم تتبدل أثناء انتظار استجابة الشبكة
      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        debugPrint(
          '[AddressesNotifier] Stale loadAddresses response rejected for old session.',
        );
        return state.addresses;
      }

      state = state.copyWith(
        addresses: list,
        isLoading: false,
        clearErrorMessage: true,
      );
      return list;
    } catch (e) {
      if (currentGen < state.sessionGeneration) {
        return state.addresses;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// إضافة عنوان شحن جديد
  Future<ShippingAddress> addAddress(ShippingAddress address) async {
    final currentGen = state.sessionGeneration;
    final currentUserId = state.activeUserId;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final created = await _repo.createAddress(address);

      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        debugPrint(
          '[AddressesNotifier] Stale addAddress response rejected for old session.',
        );
        return created;
      }

      final currentList = List<ShippingAddress>.from(state.addresses);
      if (created.isDefault) {
        for (int i = 0; i < currentList.length; i++) {
          currentList[i] = currentList[i].copyWith(isDefault: false);
        }
        currentList.insert(0, created);
      } else {
        currentList.add(created);
      }

      state = state.copyWith(
        addresses: currentList,
        isLoading: false,
        clearErrorMessage: true,
      );
      return created;
    } catch (e) {
      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        return address;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// تعديل عنوان شحن موجود
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    final currentGen = state.sessionGeneration;
    final currentUserId = state.activeUserId;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final updated = await _repo.updateAddress(address);

      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        debugPrint(
          '[AddressesNotifier] Stale updateAddress response rejected for old session.',
        );
        return updated;
      }

      final currentList = List<ShippingAddress>.from(state.addresses);
      final idx = currentList.indexWhere((a) => a.id == updated.id);

      if (idx != -1) {
        if (updated.isDefault) {
          for (int i = 0; i < currentList.length; i++) {
            currentList[i] = currentList[i].copyWith(
              isDefault: currentList[i].id == updated.id,
            );
          }
        }
        currentList[idx] = updated;
      }

      state = state.copyWith(
        addresses: currentList,
        isLoading: false,
        clearErrorMessage: true,
      );
      return updated;
    } catch (e) {
      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        return address;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// حذف عنوان شحن
  Future<void> deleteAddress(String id) async {
    final currentGen = state.sessionGeneration;
    final currentUserId = state.activeUserId;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await _repo.deleteAddress(id);

      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        debugPrint(
          '[AddressesNotifier] Stale deleteAddress response rejected for old session.',
        );
        return;
      }

      final nextList = state.addresses.where((a) => a.id != id).toList();

      // سيادة الخادم (Laravel Authority): عدم تخمين عنوان افتراضي من طرف العميل
      final newSelectedId =
          state.selectedAddressId == id ? null : state.selectedAddressId;

      state = state.copyWith(
        addresses: nextList,
        selectedAddressId: newSelectedId,
        clearSelectedAddressId: newSelectedId == null,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (e) {
      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// تعيين عنوان محدد كعنوان افتراضي
  Future<ShippingAddress> setDefaultAddress(String id) async {
    final currentGen = state.sessionGeneration;
    final currentUserId = state.activeUserId;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final updated = await _repo.setPrimaryAddress(id);

      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        debugPrint(
          '[AddressesNotifier] Stale setDefaultAddress response rejected for old session.',
        );
        return updated;
      }

      final currentList = state.addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();

      state = state.copyWith(
        addresses: currentList,
        selectedAddressId: id,
        isLoading: false,
        clearErrorMessage: true,
      );
      return updated;
    } catch (e) {
      if (currentGen < state.sessionGeneration ||
          (currentUserId != null && currentUserId != state.activeUserId)) {
        return state.addresses.firstWhere(
          (a) => a.id == id,
          orElse: () => ShippingAddress.empty(),
        );
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// اختيار عنوان للتوصيل الحالي (في السلة أو إتمام الطلب)
  void selectAddress(String id) {
    if (state.addresses.any((a) => a.id == id)) {
      state = state.copyWith(selectedAddressId: id);
    }
  }

  /// تعيين العناوين يدوياً (للاختبارات أو التهيئة التجريبية)
  void setAddresses(List<ShippingAddress> list) {
    state = state.copyWith(addresses: list);
  }

  /// تفريغ قائمة العناوين بالكامل
  void clearAddresses({String? expectedUserId, int? expectedGeneration}) {
    if (expectedUserId != null &&
        state.activeUserId != null &&
        expectedUserId != state.activeUserId) {
      return;
    }

    if (expectedGeneration != null &&
        expectedGeneration < state.sessionGeneration) {
      return;
    }

    state = state.copyWith(
      addresses: const <ShippingAddress>[],
      clearSelectedAddressId: true,
      clearErrorMessage: true,
    );
  }

  /// المزامنة التلقائية مع دورة حياة الجلسة وعزل بيانات الحسابات
  void syncWithSession({
    required String? userId,
    required int generation,
  }) {
    // إذا تبدل الحساب (المستخدم أ إلى المستخدم ب، أو خروج لضيف)، مسح كافة العناوين فوراً
    if (state.activeUserId != null && state.activeUserId != userId) {
      state = state.copyWith(
        addresses: const <ShippingAddress>[],
        clearSelectedAddressId: true,
        activeUserId: userId,
        clearActiveUserId: userId == null,
        sessionGeneration: generation,
        clearErrorMessage: true,
      );
      return;
    }

    state = state.copyWith(
      activeUserId: userId,
      clearActiveUserId: userId == null,
      sessionGeneration: generation,
    );
  }
}

