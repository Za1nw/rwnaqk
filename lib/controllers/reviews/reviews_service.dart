import 'package:rwnaqk/models/product_review.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة المراجعات.
///
/// نستخدمه لفصل:
/// - تحليل البيانات القادمة من route arguments
/// - بناء المراجعات التجريبية
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لجلب المراجعات من السيرفر أو إرسال مراجعة جديدة.
class ReviewsService {
  /// هذه الدالة تقوم بتحليل البيانات القادمة إلى شاشة المراجعات.
  ///
  /// وتدعم الحالات التالية:
  /// - وصول قائمة مباشرة من ProductReview
  /// - وصول Map يحتوي على reviews
  /// - وصول List من Map
  /// - عدم وصول بيانات، فنرجع بيانات تجريبية
  List<ProductReview> resolveReviews(dynamic arg) {
    if (arg == null) return staticReviews();

    if (arg is List<ProductReview> && arg.isNotEmpty) {
      return arg;
    }

    if (arg is Map && arg['reviews'] != null) {
      return resolveReviews(arg['reviews']);
    }

    if (arg is List && arg.isNotEmpty) {
      return arg.map((e) {
        if (e is ProductReview) return e;
        if (e is Map<String, dynamic>) return ProductReview.fromMap(e);
        if (e is Map) return ProductReview.fromMap(Map<String, dynamic>.from(e));

        return const ProductReview(
          name: 'Unknown',
          rating: 0,
          text: '',
        );
      }).toList();
    }

    return staticReviews();
  }

  /// هذه الدالة تعيد بيانات مراجعات تجريبية.
  ///
  /// نستخدمها كقيمة افتراضية عندما لا تصل مراجعات من الشاشة السابقة.
  List<ProductReview> staticReviews() => const [
        ProductReview(
          name: 'Anna',
          rating: 4.5,
          text: 'Nice product, great quality and fast shipping.',
          dateText: '2 days ago',
        ),
        ProductReview(
          name: 'John',
          rating: 5,
          text: 'Perfect! Exactly as described.',
          dateText: '1 week ago',
        ),
        ProductReview(
          name: 'Sara',
          rating: 4,
          text: 'Good overall, but the packaging can be better.',
          dateText: '3 weeks ago',
        ),
        ProductReview(
          name: 'Khaled',
          rating: 3.5,
          text: 'It is okay, could be improved.',
          dateText: '1 month ago',
        ),
      ];
}