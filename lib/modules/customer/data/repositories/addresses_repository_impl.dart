import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/providers/fake_addresses_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';

/// تطبيق مستودع العناوين النقي المتصل بخادم Laravel API عبر [ApiClient]
/// مع إمكانية التبديل مع [FakeAddressesRepository] عند تفعيل وضع Mock Data.
class AddressesRepositoryImpl implements IAddressesRepository {
  AddressesRepositoryImpl({
    required ApiClient apiClient,
    FakeAddressesRepository? fallbackRepository,
  })  : _api = apiClient,
        _fallback = fallbackRepository ?? FakeAddressesRepository();

  final ApiClient _api;
  final FakeAddressesRepository _fallback;

  @override
  Future<List<ShippingAddress>> getAddresses() async {
    if (AppEnv.enableMockData) {
      return _fallback.getAddresses();
    }

    try {
      final response = await _api.get<dynamic>(ApiEndpoints.customerAddresses);
      final data = response.data;
      final rawList = data is Map<String, dynamic> && data['data'] is List
          ? data['data'] as List
          : data is List
              ? data
              : const [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => ShippingAddress.fromJson(json))
          .toList();
    } catch (_) {
      // لا تفعّل الـ Mock Fallback تلقائياً عند فشل API لضمان ظهور الخطأ الفعلي
      rethrow;
    }
  }

  @override
  Future<ShippingAddress> createAddress(ShippingAddress address) async {
    if (AppEnv.enableMockData) {
      return _fallback.createAddress(address);
    }

    try {
      final response = await _api.post<dynamic>(
        ApiEndpoints.customerAddresses,
        data: address.toJson(),
      );

      final data = response.data;
      final json = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : <String, dynamic>{});

      return ShippingAddress.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ShippingAddress> updateAddress(ShippingAddress address) async {
    if (AppEnv.enableMockData) {
      return _fallback.updateAddress(address);
    }

    try {
      final response = await _api.put<dynamic>(
        ApiEndpoints.customerAddressDetails(address.id),
        data: address.toJson(),
      );

      final data = response.data;
      final json = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : <String, dynamic>{});

      return ShippingAddress.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    if (AppEnv.enableMockData) {
      return _fallback.deleteAddress(id);
    }

    try {
      await _api.delete<dynamic>(ApiEndpoints.customerAddressDetails(id));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ShippingAddress> setPrimaryAddress(String id) async {
    if (AppEnv.enableMockData) {
      return _fallback.setPrimaryAddress(id);
    }

    try {
      final response = await _api.patch<dynamic>(
        ApiEndpoints.customerAddressPrimary(id),
      );

      final data = response.data;
      final json = (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>)
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : <String, dynamic>{});

      return ShippingAddress.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }
}
