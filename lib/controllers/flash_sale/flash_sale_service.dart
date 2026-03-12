import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة العروض السريعة.
///
/// نستخدمه لفصل:
/// - نسب الخصومات المتاحة
/// - إنشاء البيانات التجريبية
/// - تجهيز قائمة المنتجات حسب الخصم المختار
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان الطبيعي
/// لجلب منتجات العروض من السيرفر بدل البيانات التجريبية.
class FlashSaleService {
  /// نسب الخصومات المتاحة داخل تبويبات العروض.
  /// القيمة 0 تعني عرض جميع الخصومات.
  List<int> get discounts => const [0, 10, 20, 30, 40, 50];

  /// هذه الدالة تقوم بجلب قائمة منتجات العروض حسب الخصم المختار.
  ///
  /// حاليًا نستخدم بيانات تجريبية، ولاحقًا يمكن استبدالها بطلب API.
  List<HomeProductItem> loadFlashSaleProducts({
    required int selectedDiscount,
  }) {
    return sampleProducts(
      10,
      seed: 1000,
      discount: selectedDiscount,
    );
  }

  /// هذه الدالة تنشئ قائمة منتجات تجريبية.
  ///
  /// نستخدمها أثناء التطوير وحتى يتم ربط البيانات الحقيقية لاحقًا.
  List<HomeProductItem> sampleProducts(
    int count, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return List.generate(count, (index) {
      final id = '${seed}_$index';

      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17 + (index * 5).toDouble(),
        discountPercent: discount,
        isNew: index % 3 == 0,
        tagKey: tagKey,
      );
    });
  }
}