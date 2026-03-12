import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة تعديل الملف الشخصي.
///
/// نستخدمه لعزل:
/// - متحكمات الحقول
/// - القيم المعروضة داخل الفورم
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن الحفظ والتنقل،
/// بينما تبقى تفاصيل الحقول النصية هنا.
class EditProfileUiController extends GetxController {
  /// متحكم حقل الاسم.
  late final TextEditingController nameCtrl;

  /// متحكم حقل البريد الإلكتروني.
  late final TextEditingController emailCtrl;

  /// متحكم حقل معاينة كلمة المرور.
  ///
  /// هذا الحقل للعرض فقط في الشاشة الحالية.
  late final TextEditingController passwordPreviewCtrl;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر.
  /// نستخدمها لتهيئة متحكمات الحقول بقيم ابتدائية.
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    passwordPreviewCtrl = TextEditingController();
  }

  /// هذه الدالة تعبئ الحقول بقيم ابتدائية جاهزة.
  void fillInitialValues({
    required String name,
    required String email,
    required String passwordPreview,
  }) {
    nameCtrl.text = name;
    emailCtrl.text = email;
    passwordPreviewCtrl.text = passwordPreview;
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير متحكمات الحقول.
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordPreviewCtrl.dispose();
    super.onClose();
  }
}