import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بمنظومة البحث.
///
/// نستخدمه لفصل:
/// - البيانات التجريبية
/// - البحث المحلي
/// - تنظيم السجل history
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لاستبدال البحث المحلي بطلبات الشبكة بدون الحاجة لتعديل الشاشات.
class SearchService {
  /// هذه الدالة تعيد سجل البحث الابتدائي.
  List<String> initialHistory() {
    return ['Socks', 'Red Dress', 'Sunglasses', 'Mustard Pants', '80-s Skirt'];
  }

  /// هذه الدالة تعيد الاقتراحات الابتدائية.
  List<String> initialRecommendations() {
    return ['Skirt', 'Accessories', 'Black T-Shirt', 'Jeans', 'White Shoes'];
  }

  /// هذه الدالة تنشئ منتجات تجريبية لقسم Discover أو نتائج البحث.
  List<HomeProductItem> sampleProducts(int count, {required int seed}) {
    return List.generate(count, (index) {
      final id = '${seed}_$index';

      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 12 + (index * 5).toDouble(),
        discountPercent: index % 4 == 0 ? 15 : null,
        isNew: index % 3 == 0,
        tagKey: '',
      );
    });
  }

  /// هذه الدالة تطبق البحث المحلي على القائمة المرسلة.
  ///
  /// حاليًا نبحث داخل title فقط، ويمكن لاحقًا توسيعها
  /// أو استبدالها بطلب API.
  List<HomeProductItem> runLocalSearch({
    required List<HomeProductItem> source,
    required String rawQuery,
  }) {
    final q = rawQuery.trim().toLowerCase();

    if (q.isEmpty) {
      return <HomeProductItem>[];
    }

    return source.where((item) {
      return item.title.toLowerCase().contains(q);
    }).toList();
  }

  /// هذه الدالة تضيف النص إلى سجل البحث مع:
  /// - إزالة التكرار
  /// - إبقاء أحدث عنصر في البداية
  /// - تحديد حد أقصى لعدد العناصر
  List<String> commitToHistory({
    required List<String> currentHistory,
    required String query,
    int maxLength = 10,
  }) {
    final text = query.trim();
    if (text.isEmpty) return currentHistory;

    final updated = currentHistory.toList();
    updated.removeWhere((e) => e.toLowerCase() == text.toLowerCase());
    updated.insert(0, text);

    if (updated.length > maxLength) {
      updated.removeRange(maxLength, updated.length);
    }

    return updated;
  }
}