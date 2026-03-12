import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة عرض المنتجات.
/// نستخدمه لفصل تجهيز البيانات والـ mock data والمنطق المساعد
/// عن الكنترولر الرئيسي، حتى يسهل لاحقًا استبداله بـ API حقيقي.
class ProductsListingService {
  /// هذه الدالة تقوم بقراءة العناصر القادمة من route arguments
  /// وتحويلها إلى قائمة صحيحة من نوع HomeProductItem.
  List<HomeProductItem> resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) return raw.whereType<HomeProductItem>().toList();
    return [];
  }

  /// هذه الدالة تُنشئ بيانات تجريبية تُستخدم عندما لا تصل عناصر من الشاشة السابقة.
  /// الهدف منها إبقاء الشاشة قابلة للاختبار أثناء التطوير وقبل ربط الـ API.
  List<HomeProductItem> mockProducts({int seed = 1}) {
    return List.generate(10, (i) {
      final id = (seed * 1000 + i).toString();
      final discount = (i % 4 == 0) ? 20 : (i % 7 == 0 ? 35 : 0);

      return HomeProductItem(
        id: id,
        title: 'Product $id',
        imageUrl: 'https://picsum.photos/400/520?listing=$id',
        price: 12 + (i * 4).toDouble(),
        discountPercent: discount == 0 ? null : discount,
      );
    });
  }

  /// هذه الدالة تقوم بتطبيق الترتيب الحالي على القائمة.
  /// نستخدمها كلما تغير خيار الـ sort أو عند تجهيز القائمة لأول مرة.
  List<HomeProductItem> applySort({
    required List<HomeProductItem> list,
    required ListingSort sort,
  }) {
    final out = list.toList();

    switch (sort) {
      case ListingSort.newest:
        return out;

      case ListingSort.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
        return out;

      case ListingSort.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
        return out;

      case ListingSort.discountHigh:
        out.sort(
          (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
        );
        return out;
    }
  }

  /// هذه الدالة تقوم بتطبيق الفلاتر الحالية على القائمة.
  /// حاليًا الفلترة تعتمد على نطاق السعر فقط،
  /// ويمكن توسعتها لاحقًا بسهولة عند إضافة API أو خصائص جديدة.
  List<HomeProductItem> applyFilters({
    required List<HomeProductItem> list,
    required dynamic filterResult,
  }) {
    final f = filterResult;

    if (f == null) return list;

    final min = f.priceRange.start;
    final max = f.priceRange.end;

    return list.where((p) {
      if (p.price < min) return false;
      if (p.price > max) return false;
      return true;
    }).toList();
  }
}

/// هذا الـ enum يحدد أنواع الترتيب المتاحة في شاشة عرض المنتجات.
/// نستخدمه في الكنترولر وفي نافذة الترتيب للحفاظ على نفس القيم بشكل منظم.
enum ListingSort { newest, priceLow, priceHigh, discountHigh }