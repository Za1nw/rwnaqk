import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_controller.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_service.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

void openListingSortSheet(
  BuildContext context,
  ProductsListingController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) {
      return Obx(() {
        final current = controller.sort.value;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    Tk.listingSortBy.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              _SortTile(
                title: Tk.listingSortNewest.tr,
                selected: current == ListingSort.newest,
                onTap: () {
                  controller.setSort(ListingSort.newest);
                  Get.back();
                },
              ),
              _SortTile(
                title: Tk.listingSortPriceLow.tr,
                selected: current == ListingSort.priceLow,
                onTap: () {
                  controller.setSort(ListingSort.priceLow);
                  Get.back();
                },
              ),
              _SortTile(
                title: Tk.listingSortPriceHigh.tr,
                selected: current == ListingSort.priceHigh,
                onTap: () {
                  controller.setSort(ListingSort.priceHigh);
                  Get.back();
                },
              ),
              _SortTile(
                title: Tk.listingSortDiscountHigh.tr,
                selected: current == ListingSort.discountHigh,
                onTap: () {
                  controller.setSort(ListingSort.discountHigh);
                  Get.back();
                },
              ),
            ],
          ),
        );
      });
    },
  );
}

class _SortTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SortTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: context.background.withOpacity(context.isDark ? 0.18 : 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? context.primary
                  : context.border.withOpacity(0.35),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  color: context.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
