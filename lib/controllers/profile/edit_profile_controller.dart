import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';


class EditProfileController extends GetxController {
  final nameCtrl = TextEditingController(text: 'Romina');
  final emailCtrl = TextEditingController(text: 'gmail@example.com');

  // ✅ عرض فقط
  final passwordPreviewCtrl = TextEditingController(text: '************');

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordPreviewCtrl.dispose();
    super.onClose();
  }

  void pickAvatar() {
    // لاحقاً: Image Picker
  }

  void save() {
    // احفظ بيانات الاسم/الايميل
    Get.snackbar('Saved'.tr, 'Profile updated'.tr);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgot); // ✅ روت شاشة تغيير كلمة السر
  }
}