import 'package:rwnaqk/models/contact_info_model.dart';
import 'package:rwnaqk/models/home_product_item.dart';
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
        ),
        ShippingOptionModel(
          id: 'express',
          title: 'Express',
          eta: '1-2 days',
          priceText: '\$12.00',
          note: 'Fast delivery (extra fees may apply)',
        ),
      ];

  /// بيانات التواصل الحالية.
  ContactInfoModel get contactInfo => const ContactInfoModel(
        phone: '+91987654321',
        email: 'gmail@example.com',
      );

  /// هذه الدالة تحسب إجمالي أسعار العناصر داخل السلة.
  double computeTotal(List<HomeProductItem> items) {
    return items.fold(0.0, (sum, e) => sum + e.price);
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