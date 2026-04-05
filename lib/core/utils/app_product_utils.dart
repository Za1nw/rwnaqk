import 'package:get/get.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class AppProductUtils {
  AppProductUtils._();

  static const String inlineSeparator = ' - ';

  static String? variantText(
    HomeProductItem item, {
    String separator = inlineSeparator,
  }) {
    final parts = <String>[];

    if (item.availableColors.isNotEmpty) {
      final colorName = item.availableColors.first.name.trim();
      if (colorName.isNotEmpty) {
        parts.add(colorName.tr);
      }
    }

    if (item.availableSizes.isNotEmpty) {
      final size = item.availableSizes.first.trim();
      if (size.isNotEmpty) {
        parts.add(size);
      }
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(separator);
  }

  static String joinInline(
    Iterable<String> parts, {
    String separator = inlineSeparator,
  }) {
    final values = parts
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    return values.join(separator);
  }
}
