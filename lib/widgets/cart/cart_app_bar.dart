import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class CartAppBar extends StatelessWidget {
  final int count;

  // optional callbacks/values (بدون ما نكسر الاستدعاء القديم)
  final String? shippingTitle;
  final String? shippingAddress;
  final VoidCallback? onEditAddress;

  const CartAppBar({
    super.key,
    required this.count,
    this.shippingTitle,
    this.shippingAddress,
    this.onEditAddress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final compact = w < 360;

        final titleSize = compact ? 22.0 : 26.0;
        final badgeFont = compact ? 12.5 : 13.5;

        final cardRadius = 16.0;
        final cardPad = compact ? 12.0 : 14.0;

        final editSize = compact ? 36.0 : 40.0;
        final editIcon = compact ? 18.0 : 20.0;

        final addressTitle =
            shippingTitle ?? 'Shipping Address';
        final addressText = shippingAddress ??
            '26, Duong So 2, Thao Dien Ward, An Phu, District 2,\nHo Chi Minh city';

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// عنوان Cart + Badge
              Row(
                children: [
                  Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      color: context.foreground,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: compact ? 8 : 10,
                      vertical: compact ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.primary.withOpacity(.22),
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: badgeFont,
                        color: context.primary,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Shipping Address Card
              Container(
                width: double.infinity,
                padding: EdgeInsetsDirectional.all(cardPad),
                decoration: BoxDecoration(
                  color: context.card.withOpacity(context.isDark ? 0.92 : 1.0),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(
                    color: context.border.withOpacity(.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow.withOpacity(
                        context.isDark ? .10 : .06,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// النص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addressTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: compact ? 14 : 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            addressText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 12.5 : 13,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// زر تعديل
                    InkWell(
                      onTap: onEditAddress,
                      borderRadius: BorderRadius.circular(999),
                      child: Ink(
                        width: editSize,
                        height: editSize,
                        decoration: BoxDecoration(
                          color: context.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.primary.withOpacity(.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: editIcon,
                          color: context.accentForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}