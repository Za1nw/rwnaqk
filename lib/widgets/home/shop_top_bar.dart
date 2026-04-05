import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class ShopTopBar extends StatelessWidget {
  final String title;
  final String searchHint;

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onCamera;

  /// لو تبي الضغط يفتح شاشة بحث بدل الكتابة هنا
  final VoidCallback? onTapField;

  /// مهم: إذا الصفحة عندها padding عام، خلّ هذا = EdgeInsets.zero
  final EdgeInsetsGeometry padding;

  const ShopTopBar({
    super.key,
    required this.title,
    required this.searchHint,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onCamera,
    this.onTapField,
    this.padding = const EdgeInsetsDirectional.fromSTEB(1, 10, 10, 1),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Title: لا تقصّه بقوة — خلّه ياخذ حجمه الطبيعي
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: context.foreground,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(width: 12),

            // ✅ Search: هو الـ primary CTA → لازم يكون Expanded
            Expanded(
              child: _SearchPill(
                controller: controller,
                hint: searchHint,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onCamera: onCamera,
                onTapField: onTapField,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onCamera;
  final VoidCallback? onTapField;

  const _SearchPill({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onCamera,
    this.onTapField,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ألوان “متجر” نظيفة مثل المرجع:
    // Light: رمادي فاتح جداً
    // Dark: سطح داكن خفيف
    final fieldColor = context.isDark
        ? context.card.withOpacity(0.45)
        : const Color(0xFFF3F4F6);

    final borderColor = context.isDark
        ? context.border.withOpacity(0.35)
        : Colors.transparent; // المرجع غالباً بدون border في light

    return Container(
      height: 36, // ✅ مهم: مثل المرجع، الحقل أصغر من البار
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark
              ? context.primary.withOpacity(0.75)
              : context.primary.withOpacity(0.65),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapField,
              child: AbsorbPointer(
                absorbing: onTapField != null,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textAlign: TextAlign.start, // ✅ Direction-safe
                  cursorColor: context.primary,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: context.foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,

                    hintStyle: TextStyle(
                      color: context.mutedForeground.withOpacity(0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          _CameraButton(onTap: onCamera),
        ],
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CameraButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ✅ زر صغير داخل الحقل مثل المرجع
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: context.background, // أبيض/خلفية
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.primary.withOpacity(0.75),
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(
            Icons.photo_camera_outlined,
            size: 16,
            color: context.primary,
          ),
        ),
      ),
    );
  }
}