import 'package:rwnaqk/widgets/app_filter_sheet.dart';

class AppFilterUtils {
  AppFilterUtils._();

  static int countActive(AppFilterResult result) {
    int count = 0;

    if (result.selectedCategories.isNotEmpty) count++;

    if (result.selectedSizeIndex != 2) count++;

    if (result.segment != FilterSegment.clothes) count++;

    if (result.selectedColorIndex != 0) count++;

    if (result.priceRange.start != 10 || result.priceRange.end != 150) {
      count++;
    }

    if (result.sort != FilterSort.popular) count++;

    return count;
  }
}