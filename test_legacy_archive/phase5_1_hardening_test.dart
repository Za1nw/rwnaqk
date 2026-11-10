import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class MockHardeningAddressesRepository implements IAddressesRepository {
  List<ShippingAddress> memory = <ShippingAddress>[];
  bool shouldDelay = false;

  @override
  Future<List<ShippingAddress>> getAddresses() async {
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return List<ShippingAddress>.from(memory);
  }

  @override
  Future<ShippingAddress> createAddress(ShippingAddress address) async {
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    memory.add(address);
    return address;
  }

  @override
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    final idx = memory.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      memory[idx] = address;
    }
    return address;
  }

  @override
  Future<void> deleteAddress(String id) async {
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    memory.removeWhere((a) => a.id == id);
  }

  @override
  Future<ShippingAddress> setPrimaryAddress(String id) async {
    for (int i = 0; i < memory.length; i++) {
      memory[i] = memory[i].copyWith(isDefault: memory[i].id == id);
    }
    return memory.firstWhere((a) => a.id == id);
  }
}

class CrashingCartController extends CartController {
  CrashingCartController(super.service);
  bool crashOnClear = false;

  @override
  void clearCart() {
    if (crashOnClear) {
      throw StateError('Simulated crash inside CartController.clearCart');
    }
    super.clearCart();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  ProviderContainer createContainer({MockHardeningAddressesRepository? repo}) {
    return ProviderContainer(
      overrides: [
        if (repo != null) addressesRepositoryProvider.overrideWithValue(repo),
      ],
    );
  }

  group('Phase 05.1: Address Bridge & Single-Writer Protection', () {
    test('ProfileStoreService.addresses enforces ReadOnlyRxList: direct mutations throw UnsupportedError', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      profileStore.onInit();
      addTearDown(profileStore.onClose);

      const testAddress = ShippingAddress(
        id: 'addr_direct',
        country: 'YE',
        address: 'Direct St',
        city: 'Taiz',
        postcode: '000',
      );

      // 1. Direct add() attempt MUST throw UnsupportedError
      expect(() => profileStore.addresses.add(testAddress), throwsUnsupportedError);

      // 2. Direct clear() attempt MUST throw UnsupportedError
      expect(() => profileStore.addresses.clear(), throwsUnsupportedError);

      // 3. Direct assignAll() attempt MUST throw UnsupportedError
      expect(() => profileStore.addresses.assignAll([testAddress]), throwsUnsupportedError);

      // 4. Direct removeAt() attempt MUST throw UnsupportedError
      expect(() => profileStore.addresses.removeAt(0), throwsUnsupportedError);

      // 5. Direct operator []= attempt MUST throw UnsupportedError
      expect(() => profileStore.addresses[0] = testAddress, throwsUnsupportedError);

      // 6. Authorized Riverpod mutation updates the projection cleanly
      final notifier = container.read(addressesProvider.notifier);
      notifier.setAddresses([testAddress]);

      expect(profileStore.addresses.length, 1);
      expect(profileStore.addresses.first.id, 'addr_direct');
    });

    test('Reactive Obx compatibility: UI observes Riverpod updates through read-only projection', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      profileStore.onInit();
      addTearDown(profileStore.onClose);

      int listenCount = 0;
      final worker = ever<List<ShippingAddress>>(profileStore.addresses, (_) {
        listenCount++;
      });
      addTearDown(worker.dispose);

      final notifier = container.read(addressesProvider.notifier);
      notifier.setAddresses([
        const ShippingAddress(id: '1', country: 'YE', address: 'A1', city: 'Taiz', postcode: '0'),
      ]);

      expect(listenCount, 1);
      expect(profileStore.addresses.length, 1);
    });
  });

  group('Phase 05.1: Backend Authority on Default and Selected Address', () {
    test('Deleting default address does NOT fabricate a client-side default', () async {
      final repo = MockHardeningAddressesRepository()
        ..memory = [
          const ShippingAddress(id: '1', country: 'YE', address: 'St 1', city: 'Sana\'a', postcode: '11', isDefault: true),
          const ShippingAddress(id: '2', country: 'YE', address: 'St 2', city: 'Aden', postcode: '22', isDefault: false),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      await notifier.loadAddresses();

      // Verify initial state
      expect(container.read(addressesProvider).defaultAddress?.id, '1');

      // Delete default address '1'
      await notifier.deleteAddress('1');

      final state = container.read(addressesProvider);
      expect(state.addresses.length, 1);
      expect(state.addresses.first.id, '2');
      // Address 2 must remain false until Laravel confirms a new primary address!
      expect(state.addresses.first.isDefault, isFalse);
      expect(state.defaultAddress, isNull);
    });

    test('Deleting selected checkout address clears selection instead of silently picking arbitrary address', () async {
      final repo = MockHardeningAddressesRepository()
        ..memory = [
          const ShippingAddress(id: 'sel_1', country: 'YE', address: 'St 1', city: 'C1', postcode: '11', isDefault: false),
          const ShippingAddress(id: 'other_2', country: 'YE', address: 'St 2', city: 'C2', postcode: '22', isDefault: false),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      await notifier.loadAddresses();

      notifier.selectAddress('sel_1');
      expect(container.read(selectedAddressProvider)?.id, 'sel_1');

      // Delete selected address
      await notifier.deleteAddress('sel_1');

      // Selection must be cleared rather than arbitrarily falling back
      expect(container.read(selectedAddressProvider), isNull);
      expect(container.read(addressesProvider).selectedAddressId, isNull);
    });
  });

  group('Phase 05.1: Session Stale Mutation Protection & Delayed Request Dropping', () {
    test('User A delayed updateAddress is rejected if session switches to User B', () async {
      final repo = MockHardeningAddressesRepository()
        ..shouldDelay = true
        ..memory = [
          const ShippingAddress(id: 'A1', country: 'YE', address: 'Original St', city: 'Taiz', postcode: '0'),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);

      // 1. User A starts session
      notifier.syncWithSession(userId: 'user_A', generation: 1);
      await notifier.loadAddresses();

      // 2. User A begins updateAddress (delayed 50ms)
      const modifiedByA = ShippingAddress(id: 'A1', country: 'YE', address: 'Modified by User A', city: 'Taiz', postcode: '0');
      final updateFuture = notifier.updateAddress(modifiedByA);

      // 3. User A logs out, User B logs in immediately
      notifier.syncWithSession(userId: 'user_B', generation: 2);

      // 4. Await delayed response from User A
      await updateFuture;

      // 5. User B state MUST remain clean and NOT contain User A's delayed write!
      final stateB = container.read(addressesProvider);
      expect(stateB.addresses, isEmpty);
      expect(stateB.activeUserId, 'user_B');
    });

    test('User A delayed deleteAddress is rejected under User B session', () async {
      final repo = MockHardeningAddressesRepository()
        ..shouldDelay = true
        ..memory = [
          const ShippingAddress(id: 'A1', country: 'YE', address: 'St A', city: 'City A', postcode: '0'),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);

      // User A session
      notifier.syncWithSession(userId: 'user_A', generation: 1);
      await notifier.loadAddresses();

      // Fire delayed deletion
      final deleteFuture = notifier.deleteAddress('A1');

      // Switch to User B
      notifier.syncWithSession(userId: 'user_B', generation: 2);

      await deleteFuture;

      expect(container.read(addressesProvider).activeUserId, 'user_B');
      expect(container.read(addressesProvider).addresses, isEmpty);
    });
  });

  group('Phase 05.1: Residual Reference Safety & Aggressive Cache Fencing', () {
    test('Widget retaining controller reference cannot access stale private items even on clearCart failure', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      profileStore.onInit();
      addTearDown(profileStore.onClose);
      Get.put<ProfileStoreService>(profileStore);

      Get.put<CartUiController>(CartUiController());
      final cartService = CartService(profileStore);
      final cartController = CrashingCartController(cartService)..crashOnClear = true;
      Get.put<CartController>(cartController);

      // User A populates cart
      cartController.cartItems.add(const HomeProductItem(id: 'A_SECRET_ITEM', title: 'User A Cart Item', imageUrl: '', price: 99));
      cartController.itemQuantities['A_SECRET_ITEM'] = 1;

      expect(cartController.cartItems, isNotEmpty);

      // Simulate account boundary transition (User A -> User B)
      final notifier = container.read(authSessionProvider.notifier);
      notifier.startSession(accessToken: 'token_A', customerPayload: const CustomerModel(id: 101, firstName: 'A', lastName: 'A', fullName: 'User A', email: 'a@test.com'));

      // Switch to User B: triggers _purgeLegacyGetXStores which hits simulated crash in clearCart
      notifier.startSession(accessToken: 'token_B', customerPayload: const CustomerModel(id: 202, firstName: 'B', lastName: 'B', fullName: 'User B', email: 'b@test.com'));

      // 1. Controller is forcefully evicted from GetX
      expect(Get.isRegistered<CartController>(), isFalse);

      // 2. Even the existing local reference retained by the widget has its underlying cartItems cleared in finally!
      expect(cartController.cartItems, isEmpty);
      expect(cartController.itemQuantities, isEmpty);
    });
  });
}
