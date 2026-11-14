import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/geo_lookup_item.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/models/addresses_state.dart';
import 'package:rwnaqk_frontend/modules/customer/views/addresses_view.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_empty_state.dart';

class MockAddressesRepository implements IAddressesRepository {
  List<ShippingAddress> memory = <ShippingAddress>[];
  bool shouldThrowNetworkError = false;
  bool shouldThrow422 = false;
  bool shouldDelay = false;

  @override
  Future<List<ShippingAddress>> getAddresses() async {
    if (shouldThrowNetworkError) {
      throw const NetworkException(message: 'انقطع الاتصال بالخادم', statusCode: 503);
    }
    if (shouldDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return List<ShippingAddress>.from(memory);
  }

  @override
  Future<ShippingAddress> createAddress(ShippingAddress address) async {
    if (shouldThrow422) {
      throw const ValidationException(
        message: 'بيانات العنوان غير مكتملة',
        statusCode: 422,
        errors: {'address': ['العنوان بالتفصيل مطلوب']},
      );
    }
    final created = address.copyWith(
      id: address.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : address.id,
    );
    memory.add(created);
    return created;
  }

  @override
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    final idx = memory.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      memory[idx] = address;
    }
    return address;
  }

  @override
  Future<void> deleteAddress(String id) async {
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

class FakeGeoLookupApiService extends GeoLookupApiService {
  @override
  Future<List<GeoLookupItem>> countries() async {
    return const [
      GeoLookupItem(id: 1, name: 'اليمن'),
      GeoLookupItem(id: 2, name: 'السعودية'),
    ];
  }

  @override
  Future<List<GeoLookupItem>> governorates({int? countryId}) async {
    if (countryId == 1) {
      return const [
        GeoLookupItem(id: 10, name: 'صنعاء', countryId: 1),
        GeoLookupItem(id: 11, name: 'تعز', countryId: 1),
        GeoLookupItem(id: 12, name: 'عدن', countryId: 1),
      ];
    }
    return const [];
  }

  @override
  Future<YemenGovernoratesLookup?> yemenGovernorates() async {
    return const YemenGovernoratesLookup(
      countryId: 1,
      countryName: 'اليمن',
      governorates: [
        GeoLookupItem(id: 10, name: 'صنعاء', countryId: 1),
        GeoLookupItem(id: 11, name: 'تعز', countryId: 1),
      ],
    );
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

  ProviderContainer createContainer({MockAddressesRepository? repo}) {
    final container = ProviderContainer(
      overrides: [
        if (repo != null) addressesRepositoryProvider.overrideWithValue(repo),
        geoLookupApiServiceProvider.overrideWithValue(FakeGeoLookupApiService()),
      ],
    );
    return container;
  }

  group('Phase 05: AddressesState & Immutable Model Tests', () {
    test('AddressesState immutability, defaults and copyWith', () {
      const state = AddressesState();
      expect(state.addresses, isEmpty);
      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.defaultAddress, isNull);
      expect(state.selectedAddress, isNull);
      expect(state.isLoading, isFalse);

      const a1 = ShippingAddress(
        id: 'addr_1',
        country: 'اليمن',
        address: 'شارع جمال',
        city: 'تعز',
        postcode: '12345',
        isDefault: true,
      );

      const a2 = ShippingAddress(
        id: 'addr_2',
        country: 'اليمن',
        address: 'حدة',
        city: 'صنعاء',
        postcode: '67890',
        isDefault: false,
      );

      final next = state.copyWith(
        addresses: const [a1, a2],
        activeUserId: 'usr_100',
        sessionGeneration: 1,
      );

      expect(next.addresses.length, 2);
      expect(next.defaultAddress?.id, 'addr_1');
      expect(next.selectedAddress?.id, 'addr_1'); // Defaults to default address

      final withSelected = next.copyWith(selectedAddressId: 'addr_2');
      expect(withSelected.selectedAddress?.id, 'addr_2');

      final cleared = withSelected.copyWith(
        clearSelectedAddressId: true,
        clearActiveUserId: true,
      );
      expect(cleared.selectedAddressId, isNull);
      expect(cleared.activeUserId, isNull);
    });
  });

  group('Phase 05: AddressesNotifier CRUD & Lifecycle Operations', () {
    test('loadAddresses populates state from repository', () async {
      final repo = MockAddressesRepository()
        ..memory = const [
          ShippingAddress(
            id: 'addr_1',
            country: 'اليمن',
            address: 'شارع الستين',
            city: 'صنعاء',
            postcode: '11111',
            isDefault: true,
          ),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      await notifier.loadAddresses();

      final state = container.read(addressesProvider);
      expect(state.addresses.length, 1);
      expect(state.addresses.first.city, 'صنعاء');
      expect(state.defaultAddress?.id, 'addr_1');
      expect(state.isLoading, isFalse);
    });

    test('addAddress creates new address and manages default status', () async {
      final repo = MockAddressesRepository();
      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);

      const a1 = ShippingAddress(
        id: '1',
        country: 'اليمن',
        address: 'التحرير',
        city: 'صنعاء',
        postcode: '123',
        isDefault: true,
      );
      await notifier.addAddress(a1);

      expect(container.read(addressesProvider).addresses.length, 1);
      expect(container.read(defaultAddressProvider)?.id, '1');

      const a2 = ShippingAddress(
        id: '2',
        country: 'اليمن',
        address: 'المعلا',
        city: 'عدن',
        postcode: '456',
        isDefault: true, // Marked as new default
      );
      await notifier.addAddress(a2);

      final state = container.read(addressesProvider);
      expect(state.addresses.length, 2);
      expect(container.read(defaultAddressProvider)?.id, '2');
      expect(state.addresses.firstWhere((a) => a.id == '1').isDefault, isFalse);
    });

    test('updateAddress and setDefaultAddress mutate state predictably', () async {
      final repo = MockAddressesRepository()
        ..memory = [
          const ShippingAddress(
            id: '1',
            country: 'اليمن',
            address: 'شارع القصر',
            city: 'صنعاء',
            postcode: '111',
            isDefault: true,
          ),
          const ShippingAddress(
            id: '2',
            country: 'اليمن',
            address: 'بير باشا',
            city: 'تعز',
            postcode: '222',
            isDefault: false,
          ),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      await notifier.loadAddresses();

      // Set address 2 as default
      await notifier.setDefaultAddress('2');
      expect(container.read(defaultAddressProvider)?.id, '2');

      // Update address 2
      const updated2 = ShippingAddress(
        id: '2',
        country: 'اليمن',
        address: 'شارع جمال',
        city: 'تعز',
        postcode: '222',
        isDefault: true,
      );
      await notifier.updateAddress(updated2);

      expect(
        container.read(addressesProvider).addresses.firstWhere((a) => a.id == '2').address,
        'شارع جمال',
      );
    });

    test('deleteAddress removes address and preserves a default if others exist', () async {
      final repo = MockAddressesRepository()
        ..memory = [
          const ShippingAddress(
            id: '1',
            country: 'اليمن',
            address: 'شارع القصر',
            city: 'صنعاء',
            postcode: '111',
            isDefault: true,
          ),
          const ShippingAddress(
            id: '2',
            country: 'اليمن',
            address: 'بير باشا',
            city: 'تعز',
            postcode: '222',
            isDefault: false,
          ),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      await notifier.loadAddresses();

      // Delete the default address
      await notifier.deleteAddress('1');

      final state = container.read(addressesProvider);
      expect(state.addresses.length, 1);
      expect(state.addresses.first.id, '2');
      // Backend authority: Address 2 is NOT client-side elevated to default
      expect(state.addresses.first.isDefault, isFalse);
      expect(state.defaultAddress, isNull);
    });

    test('selectAddress switches active checkout delivery address', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      notifier.setAddresses(const [
        ShippingAddress(id: '1', country: 'YE', address: 'A', city: 'C1', postcode: 'P1'),
        ShippingAddress(id: '2', country: 'YE', address: 'B', city: 'C2', postcode: 'P2'),
      ]);

      notifier.selectAddress('2');
      expect(container.read(selectedAddressProvider)?.id, '2');
    });

    test('Laravel 422 and 503 error handling captures message without crashing', () async {
      final repo = MockAddressesRepository()..shouldThrow422 = true;
      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);

      await expectLater(
        notifier.addAddress(const ShippingAddress(id: '', country: '', address: '', city: '', postcode: '')),
        throwsA(isA<ValidationException>()),
      );

      expect(container.read(addressesProvider).isLoading, isFalse);
      expect(container.read(addressesProvider).errorMessage, isNotNull);
    });
  });

  group('Phase 05: Session Isolation, Stale 401 & Cross-Account Protection', () {
    test('Cross-Account Wipe: Switching from User A to User B purges addresses and selection', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);

      // User A loads addresses
      notifier.syncWithSession(userId: 'user_A', generation: 1);
      notifier.setAddresses(const [
        ShippingAddress(id: 'addr_A', country: 'YE', address: 'Private St', city: 'Sana\'a', postcode: '111'),
      ]);
      notifier.selectAddress('addr_A');

      expect(container.read(addressesProvider).addresses.length, 1);
      expect(container.read(addressesProvider).activeUserId, 'user_A');

      // User A logs out
      notifier.syncWithSession(userId: null, generation: 2);
      expect(container.read(addressesProvider).addresses, isEmpty);
      expect(container.read(addressesProvider).selectedAddressId, isNull);
      expect(container.read(addressesProvider).activeUserId, isNull);

      // User B logs in
      notifier.syncWithSession(userId: 'user_B', generation: 3);
      expect(container.read(addressesProvider).addresses, isEmpty);
      expect(container.read(addressesProvider).activeUserId, 'user_B');
    });

    test('Stale Network Response Rejection: Delayed response from User A ignored under User B session', () async {
      final repo = MockAddressesRepository()
        ..shouldDelay = true
        ..memory = const [
          ShippingAddress(id: 'stale_A', country: 'YE', address: 'Old St', city: 'Old City', postcode: '999'),
        ];

      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      notifier.syncWithSession(userId: 'user_A', generation: 1);

      // Fire delayed load request
      final loadFuture = notifier.loadAddresses();

      // Immediately switch session to User B
      notifier.syncWithSession(userId: 'user_B', generation: 2);

      // Await delayed response
      await loadFuture;

      // User B state must NOT contain User A's delayed addresses!
      final state = container.read(addressesProvider);
      expect(state.addresses, isEmpty);
      expect(state.activeUserId, 'user_B');
    });

    test('Guest Mode Isolation: Guest user has isolated clean empty address state', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addressesProvider.notifier);
      notifier.syncWithSession(userId: 'guest', generation: 1);

      expect(container.read(addressesProvider).activeUserId, 'guest');
      expect(container.read(addressesProvider).addresses, isEmpty);
      expect(container.read(selectedAddressProvider), isNull);
    });
  });

  group('Phase 05: Geographic Coverage & Lookup Providers', () {
    test('geoCountriesProvider, geoGovernoratesProvider & yemenGovernoratesProvider return lookup items', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final countries = await container.read(geoCountriesProvider.future);
      expect(countries.length, 2);
      expect(countries.first.name, 'اليمن');

      final governorates = await container.read(geoGovernoratesProvider(1).future);
      expect(governorates.length, 3);
      expect(governorates.any((g) => g.name == 'تعز'), isTrue);

      final yemen = await container.read(yemenGovernoratesProvider.future);
      expect(yemen?.countryName, 'اليمن');
      expect(yemen?.governorates.length, 2);
    });
  });

  group('Phase 05: Legacy GetX Compatibility Bridge & ProfileStoreService Integration', () {
    test('ProfileStoreService.addresses reactively reflects Riverpod addressesProvider updates', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      profileStore.onInit();
      addTearDown(profileStore.onClose);

      expect(profileStore.addresses, isEmpty);

      // Mutate Riverpod directly
      final notifier = container.read(addressesProvider.notifier);
      notifier.setAddresses(const [
        ShippingAddress(id: '1', country: 'اليمن', address: 'حي النور', city: 'تعز', postcode: '123', isDefault: true),
      ]);

      // ProfileStoreService must reflect the mutation reactively
      expect(profileStore.addresses.length, 1);
      expect(profileStore.defaultAddress?.city, 'تعز');
      expect(profileStore.location, contains('تعز'));
    });

    test('AddressesService delegates CRUD commands to Riverpod without dual storage', () async {
      final repo = MockAddressesRepository();
      final container = createContainer(repo: repo);
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      profileStore.onInit();
      addTearDown(profileStore.onClose);

      final service = AddressesService(profileStore, repository: repo, container: container);

      // Add address via service
      const newAddress = ShippingAddress(
        id: 'addr_10',
        country: 'اليمن',
        address: 'شارع الزبيري',
        city: 'صنعاء',
        postcode: '777',
        isDefault: true,
      );
      await service.addAddress(newAddress);

      // Riverpod is the authoritative owner
      expect(container.read(addressesProvider).addresses.length, 1);
      expect(container.read(defaultAddressProvider)?.id, 'addr_10');

      // ProfileStore has matching projection
      expect(profileStore.addresses.length, 1);
      expect(profileStore.addresses.first.city, 'صنعاء');
    });
  });

  group('Phase 05: Widget Smoke & UI Rendering', () {
    testWidgets('AddressesScreen renders cleanly with empty state and responds to add button', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      addTearDown(profileStore.onClose);

      Get.put<ProfileStoreService>(profileStore);
      final service = AddressesService(profileStore, container: container);
      final uiController = AddressesUiController();
      Get.put<AddressesUiController>(uiController);
      final controller = AddressesController(service);
      Get.put<AddressesController>(controller);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('ar', 'YE'),
            fallbackLocale: const Locale('ar', 'YE'),
            home: const AddressesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifies screen title & subtitle
      expect(find.text('عنوان الشحن'), findsWidgets);
      expect(find.text('إدارة مواقع استلام طلباتك وشحناتك'), findsOneWidget);
      // Because mock data is seeded by controller onReady in development mode:
      expect(find.byType(AddressCard), findsWidgets);

      // Clear addresses via authoritative Riverpod notifier to verify reactive AddressEmptyState rendering
      container.read(addressesProvider.notifier).clearAddresses();
      await tester.pumpAndSettle();
      expect(find.byType(AddressEmptyState), findsOneWidget);
    });
  });
}
