import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
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
    getSessionTokenContext: (options) {
      try {
        if (ApiClient.isPublicAuthEndpoint(options.method, options.path)) {
          return const SessionTokenContext.denied();
        }

        final session = ref.read(authSessionProvider);
        final isBanned = session.isBanned;

        // الحساب المحظور ممنوع دائماً من حقن أي توكن
        if (isBanned) {
          return SessionTokenContext.denied(
            generation: session.sessionGeneration,
            status: session.status,
            banned: true,
          );
        }

        // استثناء محدد بالمسار والغرض لطلب استعادة الجلسة في bootstrapSession / retryBootstrap
        final isMePath = ApiClient.isMeEndpoint(options.method, options.path);
        if (session.isBootstrapping &&
            isMePath &&
            session.token != null &&
            session.token!.trim().isNotEmpty) {
          return SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: session.token!.trim(),
            sessionGeneration: session.sessionGeneration,
            sessionStatus: session.status,
            isBanned: false,
          );
        }

        // الحالات المسموح لها: فقط عندما تكون الجلسة authenticated مع توكن صالح وغير محظورة
        if (session.status == AuthSessionStatus.authenticated &&
            session.token != null &&
            session.token!.trim().isNotEmpty &&
            !isBanned) {
          return SessionTokenContext(
            policy: TokenInjectionPolicy.allowed,
            currentSessionToken: session.token!.trim(),
            sessionGeneration: session.sessionGeneration,
            sessionStatus: session.status,
            isBanned: false,
          );
        }

        // باقي الحالات: unauthenticated, guest, twoFactor, serverError, authenticating العادية
        return SessionTokenContext.denied(
          generation: session.sessionGeneration,
          status: session.status,
          banned: isBanned,
        );
      } catch (e, st) {
        debugPrint(
          '[ApiClient Provider] Error evaluating session token context: $e\n$st',
        );
        return const SessionTokenContext.unknown();
      }
    },
    getSessionGeneration: () {
      try {
        return ref.read(authSessionProvider).sessionGeneration;
      } catch (e) {
        debugPrint('[ApiClient Provider] Error reading session generation: $e');
        return 0;
      }
    },
    onUnauthorizedWithDetails: (failedToken, staleGen) {
      try {
        ref
            .read(authSessionProvider.notifier)
            .handleUnauthorized(
              failedToken: failedToken,
              staleGeneration: staleGen,
            )
            .catchError((Object e, StackTrace st) {
          debugPrint('[ApiClient Provider] Async error in handleUnauthorized: $e\n$st');
        });
      } catch (e, st) {
        debugPrint('[ApiClient Provider] Error in onUnauthorizedWithDetails: $e\n$st');
      }
    },
    onUnauthorizedWithToken: (failedToken) {
      try {
        ref
            .read(authSessionProvider.notifier)
            .handleUnauthorized(
              failedToken: failedToken,
            )
            .catchError((Object e, StackTrace st) {
          debugPrint('[ApiClient Provider] Async error in handleUnauthorized: $e\n$st');
        });
      } catch (e, st) {
        debugPrint('[ApiClient Provider] Error in onUnauthorizedWithToken: $e\n$st');
      }
    },
    onUnauthorized: () {
      try {
        ref
            .read(authSessionProvider.notifier)
            .handleUnauthorized()
            .catchError((Object e, StackTrace st) {
          debugPrint('[ApiClient Provider] Async error in handleUnauthorized: $e\n$st');
        });
      } catch (e, st) {
        debugPrint('[ApiClient Provider] Error in onUnauthorized: $e\n$st');
      }
    },
    onAccountBanned: (customerData, reason) {
      CustomerModel? customer;
      if (customerData != null) {
        try {
          customer = CustomerModel.fromJson(customerData);
        } catch (e) {
          debugPrint('[ApiClient Provider] Could not parse banned customer data: $e');
        }
      }
      try {
        unawaited(
          ref.read(authSessionProvider.notifier).markAsBanned(
                customerPayload: customer,
                reason: reason,
              ),
        );
      } catch (e, st) {
        debugPrint('[ApiClient Provider] Error in onAccountBanned: $e\n$st');
      }
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
