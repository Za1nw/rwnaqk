import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة تسجيل الدخول.
///
/// نستخدمه لعزل:
/// - مفتاح الفورم
/// - متحكمات الحقول
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن التنقل وتنفيذ تسجيل الدخول،
/// بينما تبقى تفاصيل الحقول والفورم هنا.
class LoginUiController extends GetxController {
  /// مفتاح الفورم المستخدم للتحقق من صحة الحقول.
  final formKey = GlobalKey<FormState>();

  /// متحكم حقل البريد الإلكتروني.
  final emailController = TextEditingController();

  /// متحكم حقل كلمة المرور.
  final passwordController = TextEditingController();

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير متحكمات الحقول.
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}