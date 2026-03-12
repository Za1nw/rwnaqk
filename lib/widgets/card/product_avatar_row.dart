import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import '../../models/home_product_item.dart';

class ProductAvatarRow extends StatelessWidget {
  final List<HomeProductItem> items;
  final ValueChanged<HomeProductItem> onTap;

  /// ✅ هنا تحدد ألوان الإطار يدويًا حسب الـ index
  /// مثال: {0: Colors.red, 3: Colors.green}
  /// إذا ما حطيت شيء -> يطلع لون تلقائي من chart1..chart5
  final Map<int, Color> customRingByIndex;

  /// مقاسات
  final double outerSize; // حجم الدائرة كاملة
  final double ringThickness; // سماكة الإطار
  final double spacing; // المسافة بين الدوائر

  const ProductAvatarRow({
    super.key,
    required this.items,
    required this.onTap,
    this.customRingByIndex = const {},
    this.outerSize = 54,
    this.ringThickness = 3,
    this.spacing = 10,
  });

  /// ✅ لون تلقائي من ثيمك (يتغير تلقائي Light/Dark)
  Color _autoRingColor(BuildContext context, int index) {
    final palette = <Color>[
      context.chart1,
      context.chart2,
      context.chart3,
      context.chart4,
      context.chart5,
      context.ring,
      context.primary,
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final innerSize = outerSize - (ringThickness * 2);

    return SizedBox(
      height: outerSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (_, i) {
          final p = items[i];

          // ✅ إذا أنت محدد لون لهذا الـ index استخدمه، غير كذا تلقائي
          final ringColor = customRingByIndex[i] ?? _autoRingColor(context, i);

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onTap(p),
            child: Container(
              width: outerSize,
              height: outerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ringColor, // ✅ الإطار الملون
                boxShadow: [
                  BoxShadow(
                    color: context.shadow.withOpacity(context.isDark ? 0.16 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(ringThickness), // ✅ سماكة الإطار
              child: Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.border.withOpacity(0.65),
                    width: 1,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(p.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}