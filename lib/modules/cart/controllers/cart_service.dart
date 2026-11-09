import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/shipping_option_model.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بمنظومة السلة.
///
/// نستخدمه لفصل:
/// - البيانات التجريبية
/// - خيارات الشحن
/// - بيانات التواصل
/// - الحسابات المساعدة
/// - الاتصال مع واجهات Laravel API لإعادة التسعير الجغرافي والكوبونات
class CartService {
  CartService(this._profileStore, {this.apiClient});

  final ProfileStoreService _profileStore;
  final ApiClient? apiClient;

  ApiClient get _api =>
      apiClient ??
      (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient());

  /// طلب إعادة تسعير وعرض سعر السلة من خادم Laravel
  Future<CartQuoteModel?> requestCartQuote({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingOptionId,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.cartQuote,
        data: {
          'address_id': addressId,
          'items': items,
          if (couponCode != null && couponCode.isNotEmpty)
            'coupon_code': couponCode,
          if (shippingOptionId != null && shippingOptionId.isNotEmpty)
            'shipping_option_id': shippingOptionId,
        },
      );

      final data = response.data;
      if (data != null && data['data'] is Map<String, dynamic>) {
        return CartQuoteModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartService.requestCartQuote] Error: $e');
      }
      rethrow;
    }
  }

  /// التحقق من كود الكوبون مع خادم Laravel
  Future<Map<String, dynamic>> validateCouponOnline({
    required String couponCode,
    double subtotal = 0.0,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.validateCoupon,
      data: {
        'coupon_code': couponCode,
        'subtotal': subtotal,
      },
    );
    return response.data ?? {};
  }

  /// الدول المتاحة حاليًا في نموذج الشحن.
  List<String> get shippingCountries =>
      AppMockContentUtils.localizedCountries();

  String localizedCountryLabel(String value) =>
      AppMockContentUtils.localizedCountryLabel(value);

  /// خيارات الشحن المتاحة في صفحة الدفع.
  List<ShippingOptionModel> get shippingOptions => [
    ShippingOptionModel(id: 'standard', priceText: Tk.cartFree.tr),
    ShippingOptionModel(id: 'express', priceText: '2,000 ر.ي'),
  ];

  /// بيانات التواصل الحالية.
  ContactInfoModel get contactInfo => ContactInfoModel(
    phone: _profileStore.phone.trim(),
    email: _profileStore.email.trim(),
  );

  /// هذه الدالة تحسب إجمالي أسعار العناصر داخل السلة.
  double computeTotal(List<HomeProductItem> items) {
    return items.fold(0.0, (sum, e) => sum + _unitPrice(e));
  }

  /// هذه الدالة تحسب إجمالي عناصر السلة مع الكميات.
  double computeItemsTotal(
    List<HomeProductItem> items,
    Map<String, int> quantities,
  ) {
    return items.fold(0.0, (sum, e) {
      final qty = (quantities[e.id] ?? 1).clamp(1, 999);
      return sum + (_unitPrice(e) * qty);
    });
  }

  /// هذه الدالة تعيد رسوم الشحن للخيار المختار.
  double shippingFeeFor({
    required List<ShippingOptionModel> options,
    required String selectedId,
  }) {
    for (final option in options) {
      if (option.id == selectedId) {
        return parsePriceText(option.priceText);
      }
    }

    return 0;
  }

  /// هذه الدالة تحول النص السعري إلى قيمة رقمية.
  double parsePriceText(String text) {
    final normalized = text.trim().toUpperCase();

    if (normalized.isEmpty ||
        normalized == 'FREE' ||
        normalized == Tk.cartFree.tr.toUpperCase()) {
      return 0;
    }

    // تنظيف الفواصل العادية والعربية حتى لا يتم اقتطاع الأرقام الكبيرة مثل 2,000
    final sanitized = text.replaceAll(',', '').replaceAll('،', '');
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(sanitized);
    if (match == null) return 0;

    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  /// هذه الدالة تبني طلبًا جاهزًا بعد إتمام الدفع.
  OrderModel buildCheckoutOrder({
    required List<HomeProductItem> items,
    required Map<String, int> quantities,
    required int itemsCount,
    required double shippingFee,
    double discountAmount = 0.0,
    required double total,
    required ShippingAddress address,
    required ContactInfoModel contact,
    required String shippingMethodKey,
    required String paymentMethodKey,
    String status = 'pending',
  }) {
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch.toString();
    final suffix = millis.substring(millis.length - 6);
    final subtotal = computeItemsTotal(items, quantities);
    final deliveryName = _profileStore.displayName.trim();
    final deliveryPhone = contact.phone.trim();

    final details = OrderDetailsModel(
      items: items
          .map(
            (item) => OrderDetailsItem(
              title: item.title,
              subtitle: _buildItemSubtitle(item),
              quantity: quantities[item.id] ?? 1,
              unitPrice: _unitPrice(item),
            ),
          )
          .toList(growable: false),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      shippingMethodKey: shippingMethodKey,
      paymentMethodKey: paymentMethodKey,
      deliveryName: deliveryName.isEmpty ? contact.email.trim() : deliveryName,
      deliveryPhone: deliveryPhone,
      addressLine: address.formatted,
    );

    return OrderModel(
      id: 'ORD-$suffix',
      createdAt: now,
      total: total,
      itemsCount: itemsCount,
      status: status,
      addressLine: address.formatted,
      deliveryPhone: deliveryPhone.isEmpty ? null : deliveryPhone,
      deliveryName: details.deliveryName.trim().isEmpty
          ? null
          : details.deliveryName,
      details: details,
    );
  }

  double _unitPrice(HomeProductItem item) {
    return item.hasDiscount ? item.salePrice : item.price;
  }

  String _buildItemSubtitle(HomeProductItem item) {
    final parts = <String>[
      if (item.brand.trim().isNotEmpty) item.brand.trim(),
      if (item.sku.trim().isNotEmpty) 'SKU: ${item.sku.trim()}',
    ];

    if (parts.isEmpty) {
      return item.hasDiscount
          ? '${item.discountPercent}% OFF'
          : 'Standard item';
    }

    return parts.join(' - ');
  }

  /// هذه الدالة تعيد عناصر السلة التجريبية.
  List<HomeProductItem> seedCartItems() {
    return [
      const HomeProductItem(
        id: '1',
        title: 'فستان سهرة مخملي راقي',
        brand: 'رَوْنَقُك',
        imageUrl: 'https://picsum.photos/200',
        price: 24000,
        discountPercent: 20,
        stockText: 'متوفر في المخزون',
      ),
      const HomeProductItem(
        id: '2',
        title: 'قميص حرير كلاسيكي أنيق',
        brand: 'شانيل',
        imageUrl: 'https://picsum.photos/201',
        price: 14500,
        discountPercent: 15,
        stockText: 'متبقي 2 فقط',
      ),
    ];
  }

  /// هذه الدالة تعيد عناصر المفضلة التجريبية.
  List<HomeProductItem> seedWishlistItems() {
    return [
      const HomeProductItem(
        id: '3',
        title: 'حقيبة يد جلدية فاخرة رَوْنَقُك',
        brand: 'رَوْنَقُك',
        imageUrl: 'https://picsum.photos/202',
        price: 19500,
        discountPercent: 10,
        stockText: 'متوفر في المخزون',
      ),
    ];
  }

  /// هذه الدالة تعيد عنوان الشحن الابتدائي التجريبي.
  ShippingAddress seedShippingAddress() =>
      _profileStore.currentShippingAddress();
}
