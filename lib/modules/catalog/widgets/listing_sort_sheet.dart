import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';

void openListingSortSheet({
  required BuildContext context,
  required ListingSort currentSort,
  required ValueChanged<ListingSort> onSelectSort,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
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
                    color: ctx.foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: ctx.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _SortTile(
              title: Tk.listingSortNewest.tr,
              selected: currentSort == ListingSort.newest,
              onTap: () {
                onSelectSort(ListingSort.newest);
                Navigator.of(ctx).pop();
              },
            ),
            _SortTile(
              title: Tk.listingSortPriceLow.tr,
              selected: currentSort == ListingSort.priceLow,
              onTap: () {
                onSelectSort(ListingSort.priceLow);
                Navigator.of(ctx).pop();
              },
            ),
            _SortTile(
              title: Tk.listingSortPriceHigh.tr,
              selected: currentSort == ListingSort.priceHigh,
              onTap: () {
                onSelectSort(ListingSort.priceHigh);
                Navigator.of(ctx).pop();
              },
            ),
            _SortTile(
              title: Tk.listingSortDiscountHigh.tr,
              selected: currentSort == ListingSort.discountHigh,
              onTap: () {
                onSelectSort(ListingSort.discountHigh);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
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
            color: context.background.withValues(alpha: context.isDark ? 0.18 : 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? context.primary
                  : context.border.withValues(alpha: 0.35),
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
