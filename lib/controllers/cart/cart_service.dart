import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/models/shipping_address_model.dart';
import 'package:rwnaqk/models/shipping_option_model.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بمنظومة السلة.
///
/// نستخدمه لفصل:
/// - البيانات التجريبية
/// - خيارات الشحن
/// - بيانات التواصل
/// - الحسابات المساعدة
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان الطبيعي
/// لاستبدال الـ mock data بطلبات الشبكة.
class CartService {
  /// الدول المتاحة حاليًا في نموذج الشحن.
  List<String> get shippingCountries => const [
        'Yemen',
        'Saudi Arabia',
        'UAE',
        'India',
      ];

  /// خيارات الشحن المتاحة في صفحة الدفع.
  List<ShippingOptionModel> get shippingOptions => const [
        ShippingOptionModel(
          id: 'standard',
          title: 'Standard',
          eta: '5-7 days',
          priceText: 'FREE',
          note: 'Reliable delivery with no extra fees.',
        ),
        ShippingOptionModel(
          id: 'express',
          title: 'Express',
          eta: '1-2 days',
          priceText: '\$12.00',
          note: 'Fast delivery for urgent orders.',
        ),
      ];

  /// بيانات التواصل الحالية.
  ContactInfoModel get contactInfo => const ContactInfoModel(
        phone: '+91987654321',
        email: 'gmail@example.com',
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

    if (normalized.isEmpty || normalized == 'FREE') {
      return 0;
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (match == null) return 0;

    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  /// هذه الدالة تبني طلبًا جاهزًا بعد إتمام الدفع.
  OrderModel buildCheckoutOrder({
    required int itemsCount,
    required double total,
    required ShippingAddressModel address,
    required ContactInfoModel contact,
    String status = 'pending',
  }) {
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch.toString();
    final suffix = millis.substring(millis.length - 6);

    return OrderModel(
      id: 'ORD-$suffix',
      createdAt: now,
      total: total,
      itemsCount: itemsCount,
      status: status,
      addressLine: address.formatted,
      deliveryPhone: contact.phone.trim().isEmpty ? null : contact.phone.trim(),
      deliveryName: null,
    );
  }

  double _unitPrice(HomeProductItem item) {
    return item.hasDiscount ? item.salePrice : item.price;
  }

  /// هذه الدالة تعيد عناصر السلة التجريبية.
  List<HomeProductItem> seedCartItems() {
    return [
      HomeProductItem(
        id: '1',
        title: 'Pink Dress',
        imageUrl: 'https://picsum.photos/200',
        price: 17,
      ),
      HomeProductItem(
        id: '2',
        title: 'Summer Shirt',
        imageUrl: 'https://picsum.photos/201',
        price: 17,
      ),
    ];
  }

  /// هذه الدالة تعيد عناصر المفضلة التجريبية.
  List<HomeProductItem> seedWishlistItems() {
    return [
      HomeProductItem(
        id: '3',
        title: 'Wishlist Item',
        imageUrl: 'https://picsum.photos/202',
        price: 17,
      ),
    ];
  }

  /// هذه الدالة تعيد عنوان الشحن الابتدائي التجريبي.
  ShippingAddressModel seedShippingAddress() {
    return const ShippingAddressModel(
      country: 'India',
      addressLine: 'Magadi Main Rd, next to Prasanna Theatre',
      city: 'Bengaluru',
      postcode: '560023',
    );
  }
}
