import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة إنشاء الحساب.
///
/// نستخدمه لعزل:
/// - مفتاح الفورم
/// - متحكمات الحقول
/// - حالة المحافظة المختارة
/// - حالة الموافقة على الشروط
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن تنفيذ التسجيل والتنقل،
/// بينما تبقى تفاصيل الحقول والفورم هنا.
class RegisterUiController extends GetxController {
  /// مفتاح الفورم المستخدم للتحقق من صحة المدخلات.
  final formKey = GlobalKey<FormState>();

  /// متحكم حقل الاسم الأول.
  final firstNameController = TextEditingController();

  /// متحكم حقل الاسم الأخير.
  final lastNameController = TextEditingController();

  /// متحكم حقل رقم الهاتف.
  final phoneController = TextEditingController();

  /// متحكم حقل البريد الإلكتروني.
  final emailController = TextEditingController();

  /// متحكم حقل كلمة المرور.
  final passwordController = TextEditingController();

  /// المحافظة المختارة حاليًا.
  final governorate = RxnString();

  /// حالة الموافقة على الشروط.
  final agreed = false.obs;

  /// هذه الدالة تبدّل حالة الموافقة على الشروط.
  void toggleAgreed() {
    agreed.value = !agreed.value;
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير متحكمات الحقول.
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}