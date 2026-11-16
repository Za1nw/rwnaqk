import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';

class ProductDetailsService {
  List<HomeProductItem> resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) return raw.whereType<HomeProductItem>().toList();
    return <HomeProductItem>[];
  }

  List<ProductReview> resolveReviews(dynamic raw) {
    if (raw is List<ProductReview>) return raw;

    if (raw is List) {
      final out = <ProductReview>[];

      for (final e in raw) {
        if (e is ProductReview) {
          out.add(e);
        } else if (e is Map<String, dynamic>) {
          out.add(ProductReview.fromMap(e));
        } else if (e is Map) {
          out.add(ProductReview.fromMap(Map<String, dynamic>.from(e)));
        }
      }

      if (out.isNotEmpty) return out;
    }

    return AppMockContentUtils.previewReviews;
  }
}
