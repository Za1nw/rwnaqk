import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة فقط الخاصة بمنظومة البحث.
///
/// نستخدمه لعزل العناصر التفاعلية المرتبطة بالواجهة مثل:
/// - حقل البحث
/// - النص الحالي المكتوب
///
/// الهدف من هذا الفصل هو أن يبقى الكنترولر الرئيسي مسؤولًا عن
/// منطق البيانات والتنقل والنتائج، بينما تبقى تفاصيل الواجهة هنا فقط.
class SearchUiController extends GetxController {
  /// متحكم حقل البحث المستخدم في شاشة البحث وشاشة نتائج البحث.
  final searchC = TextEditingController();

  /// النص الحالي المكتوب داخل حقل البحث.
  final query = ''.obs;

  /// هذه الدالة تحدث قيمة النص الحالي أثناء الكتابة.
  void onChanged(String value) {
    query.value = value;
  }

  /// هذه الدالة تحدث قيمة النص الحالي عند تنفيذ البحث.
  void onSubmitted(String value) {
    query.value = value;
  }

  /// هذه الدالة تضع قيمة جاهزة داخل حقل البحث
  /// مثل الضغط على history أو recommendation.
  void setQueryText(String value) {
    searchC.text = value;
    searchC.selection = TextSelection.collapsed(offset: value.length);
    query.value = value;
  }

  /// هذه الدالة تمسح النص الحالي من الحقل.
  void clearQuery() {
    searchC.clear();
    query.value = '';
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير TextEditingController.
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}