import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_color_option.dart';
import 'package:rwnaqk/models/product_review.dart';

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

    return const <ProductReview>[
      ProductReview(
        name: 'Veronika',
        rating: 4.0,
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam.',
        dateText: '2 days ago',
      ),
    ];
  }

  String resolveSelectedColorId({
    required dynamic incomingValue,
    required List<ProductColorOption> availableValues,
  }) {
    final incoming = (incomingValue ?? '').toString().trim();

    if (incoming.isNotEmpty) {
      for (final item in availableValues) {
        if (item.id == incoming) return item.id;
      }
    }

    if (availableValues.isNotEmpty) return availableValues.first.id;
    return '';
  }

  String resolveSelectedSize({
    required dynamic incomingValue,
    required List<String> availableValues,
  }) {
    final incoming = (incomingValue ?? '').toString().trim();

    if (incoming.isNotEmpty) return incoming;
    if (availableValues.isNotEmpty) return availableValues.first;
    return '';
  }
}