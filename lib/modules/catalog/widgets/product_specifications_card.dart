import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

/// بطاقة مواصفات المنتج ومحتوى الوصف التفصيلي
///
/// تم تحسين المنطق لإزالة زرار دليل المقاسات ورمز الـ SKU، مع معالجة ذكية
/// للنصوص ووسوم HTML وتحويل البنود والخصائص إلى عناصر منسقة ومرتبة.
class ProductSpecificationsCard extends StatefulWidget {
  final String description;

  const ProductSpecificationsCard({
    super.key,
    required this.description,
  });

  @override
  State<ProductSpecificationsCard> createState() =>
      _ProductSpecificationsCardState();
}

class _ProductSpecificationsCardState extends State<ProductSpecificationsCard> {
  bool _isExpanded = true;
  bool _isTextExpanded = false;

  /// تنظيف وتحليل نصوص الـ HTML واستخراج الأسطر المنظمة
  String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&rlm;', '')
        .replaceAll('&lrm;', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// تحليل الأسطر إلى أزواج (مفتاح: قيمة) أو بنود نقطية أو فقرات عادية
  List<_SpecLineItem> _parseSpecificationLines(String text) {
    final lines = text.split('\n');
    final List<_SpecLineItem> items = [];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // فحص البنود النقطية (Bullet points)
      if (line.startsWith('•') || line.startsWith('-') || line.startsWith('*')) {
        final content = line.substring(1).trim();
        if (content.isNotEmpty) {
          items.add(_SpecLineItem(
            type: _SpecLineType.bullet,
            text: content,
          ));
          continue;
        }
      }

      // فحص أزواج المواصفات (مفتاح: قيمة) مثل "الخامة: قطن 100%"
      final colonIndex = line.contains(':') ? line.indexOf(':') : line.indexOf('：');
      if (colonIndex > 0 && colonIndex < line.length - 1) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        // تأكد من أن المفتاح قصير وليس جملة طويلة أو رابط
        if (key.length <= 35 && !key.contains('http') && value.isNotEmpty) {
          items.add(_SpecLineItem(
            type: _SpecLineType.keyValue,
            key: key,
            value: value,
          ));
          continue;
        }
      }

      // فقرة نصية عامة
      items.add(_SpecLineItem(
        type: _SpecLineType.paragraph,
        text: line,
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cleanDesc = _cleanHtml(widget.description);
    final specItems = _parseSpecificationLines(cleanDesc);

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(
              alpha: context.isDark ? 0.12 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header مع إمكانية الطي والتوسيع
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.format_list_bulleted_rounded,
                      color: context.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Tk.productDetailsSpecifications.tr,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.mutedForeground,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(
              height: 1,
              thickness: 0.7,
              color: context.border.withValues(alpha: 0.35),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: specItems.isEmpty
                  ? Text(
                      'لا توجد مواصفات إضافية لهذا المنتج.',
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpecificationsContent(context, specItems),
                        if (specItems.length > 5 || cleanDesc.length > 220) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => setState(
                              () => _isTextExpanded = !_isTextExpanded,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isTextExpanded
                                        ? Tk.productDetailsReadLess.tr
                                        : Tk.productDetailsReadMore.tr,
                                    style: TextStyle(
                                      color: context.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _isTextExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: context.primary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecificationsContent(
    BuildContext context,
    List<_SpecLineItem> items,
  ) {
    final displayedItems =
        _isTextExpanded ? items : items.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        switch (item.type) {
          case _SpecLineType.keyValue:
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? context.background
                      : context.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.border.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.key ?? '',
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.value ?? '',
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

          case _SpecLineType.bullet:
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.text ?? '',
                      style: TextStyle(
                        color: context.foreground.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );

          case _SpecLineType.paragraph:
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item.text ?? '',
                style: TextStyle(
                  color: context.foreground.withValues(alpha: 0.88),
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            );
        }
      }).toList(),
    );
  }
}

enum _SpecLineType { keyValue, bullet, paragraph }

class _SpecLineItem {
  final _SpecLineType type;
  final String? key;
  final String? value;
  final String? text;

  const _SpecLineItem({
    required this.type,
    this.key,
    this.value,
    this.text,
  });
}
