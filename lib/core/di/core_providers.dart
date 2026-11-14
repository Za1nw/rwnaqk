import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';

export 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
export 'package:rwnaqk_frontend/modules/customer/providers/addresses_providers.dart';
export 'package:rwnaqk_frontend/modules/customer/providers/geo_providers.dart';

/// حاوية الموفرات الموحدة في Riverpod
ProviderContainer? _globalProviderContainer;

ProviderContainer get globalProviderContainer =>
    _globalProviderContainer ??= ProviderContainer();

set globalProviderContainer(ProviderContainer container) {
  _globalProviderContainer = container;
}

/// مزود خدمة التخزين الآمن لبيانات توكن المصادقة [IAuthTokenStorage].
final authTokenStorageProvider = Provider<IAuthTokenStorage>((ref) {
  return SecureAuthTokenStorage();
});

/// مزود عميل الشبكة الموحد [ApiClient] المبني على Dio مع حماية الجلسة وتطهير التوكن
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authTokenStorageProvider);
  return ApiClient(
    tokenStorage: storage,
    getSessionGeneration: () => ref.read(authSessionProvider).sessionGeneration,
    onUnauthorizedWithDetails: (failedToken, staleGen) {
      ref.read(authSessionProvider.notifier).handleUnauthorized(
            failedToken: failedToken,
            staleGeneration: staleGen,
          );
    },
    onUnauthorizedWithToken: (failedToken) {
      ref.read(authSessionProvider.notifier).handleUnauthorized(
            failedToken: failedToken,
          );
    },
    onUnauthorized: () {
      ref.read(authSessionProvider.notifier).handleUnauthorized();
    },
    onAccountBanned: (customerData, reason) {
      CustomerModel? customer;
      if (customerData != null) {
        try {
          customer = CustomerModel.fromJson(customerData);
        } catch (_) {}
      }
      ref.read(authSessionProvider.notifier).markAsBanned(
            customerPayload: customer,
            reason: reason,
          );
    },
  );
});

/// مزود مستودع المصادقة النقي [IAuthRepository].
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(authTokenStorageProvider);
  return AuthRepositoryImpl(apiClient: client, tokenStorage: storage);
});

/// مزود مستودع منتجات وكتالوج المتجر [IProductsRepository].
final productsRepositoryProvider = Provider<IProductsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductsRepositoryImpl(apiClient: client);
});

/// مزود مستودع الطلبات وعمليات الشراء [IOrdersRepository].
final ordersRepositoryProvider = Provider<IOrdersRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrdersRepositoryImpl(apiClient: client);
});
