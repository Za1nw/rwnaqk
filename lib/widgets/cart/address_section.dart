import 'package:flutter/material.dart';
import 'package:rwnaqk/widgets/cart/editable_info_card.dart';
import 'package:rwnaqk/widgets/cart/add_info_card.dart';

/// قسم مرن لعرض بيانات قابلة للتعديل (Edit)
/// - يدعم عرض "عنوان" كنص واحد (address)
/// - أو "معلومات" كقائمة أسطر (lines) مثل: الهاتف + البريد
///
/// السلوك:
/// - إذا فيه بيانات -> EditableInfoCard
/// - إذا ما فيه بيانات:
///   - allowAddWhenEmpty = true  -> AddInfoCard (زر إضافة)
///   - allowAddWhenEmpty = false -> EditableInfoCard (بدون إضافة)
class AddressSection extends StatelessWidget {
  /// عنوان القسم (Shipping Address / Contact Information)
  final String title;

  /// خيار 1: عنوان نصي واحد
  final String? address;

  /// خيار 2: قائمة أسطر (مثل التواصل)
  final List<String>? lines;

  /// زر التعديل / الإضافة
  final VoidCallback? onEdit;

  /// عدد الأسطر الظاهرة كحد أقصى داخل الكرت
  final int maxLines;

  /// عندما تكون البيانات فارغة:
  /// - true  => يعرض AddInfoCard (مناسب للـ Shipping)
  /// - false => يعرض EditableInfoCard فقط (مناسب للـ Contact عندك)
  final bool allowAddWhenEmpty;

  /// نص مساعد يظهر داخل AddInfoCard عند الفراغ
  final String emptyHint;

  const AddressSection({
    super.key,
    required this.title,
    this.address,
    this.lines,
    required this.onEdit,
    this.maxLines = 2,
    this.allowAddWhenEmpty = true,
    this.emptyHint = 'اضف عنوان الشحن',
  }) : assert(
          (address != null) ^ (lines != null),
          'لازم تمرر واحد فقط: address أو lines',
        );

  @override
  Widget build(BuildContext context) {
    // حوّل المدخلات لقائمة أسطر موحّدة
    final normalizedLines = lines ??
        (address != null && address!.trim().isNotEmpty ? [address!] : <String>[]);

    final hasData = normalizedLines.any((e) => e.trim().isNotEmpty);

    // عند وجود بيانات -> Editable
    if (hasData) {
      return EditableInfoCard(
        title: title,
        lines: normalizedLines,
        maxLines: maxLines,
        onEdit: onEdit,
      );
    }

    // عند عدم وجود بيانات
    if (allowAddWhenEmpty) {
      return AddInfoCard(
        title: title,
        hint: emptyHint,
        onAdd: onEdit,
      );
    }

    // لا نريد Add (Edit فقط حتى لو فاضي)
    return EditableInfoCard(
      title: title,
      lines: const [],
      maxLines: maxLines,
      onEdit: onEdit,
    );
  }
}