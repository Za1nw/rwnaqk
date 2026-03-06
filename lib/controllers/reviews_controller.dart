import 'package:get/get.dart';
import 'package:rwnaqk/models/product_review.dart';

class ReviewsController extends GetxController {
  final reviews = <ProductReview>[].obs;

  @override
  void onInit() {
    super.onInit();
    reviews.assignAll(_resolveReviews(Get.arguments));
  }

  List<ProductReview> _resolveReviews(dynamic arg) {
    if (arg == null) return _staticReviews();

    if (arg is List<ProductReview> && arg.isNotEmpty) return arg;

    if (arg is Map && arg['reviews'] != null) {
      return _resolveReviews(arg['reviews']);
    }

    if (arg is List && arg.isNotEmpty) {
      return arg.map((e) {
        if (e is ProductReview) return e;
        if (e is Map<String, dynamic>) return ProductReview.fromMap(e);
        if (e is Map) return ProductReview.fromMap(Map<String, dynamic>.from(e));
        return const ProductReview(name: 'Unknown', rating: 0, text: '');
      }).toList();
    }

    return _staticReviews();
  }

  List<ProductReview> _staticReviews() => const [
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