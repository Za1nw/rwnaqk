import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  // مفتاح الفورم للتحقق من المدخلات
  final formKey = GlobalKey<FormState>();

  // Controllers للحقول
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // المحافظة (Select) قيمة قابلة لأن تكون null
  final governorate = RxnString();

  // الموافقة على الشروط
  final agreed = false.obs;

  // قائمة المحافظات (تقدر تعدلها براحتك)
  final governorates = <String>[
    'صنعاء','عدن','تعز','الحديدة','إب','ذمار','حضرموت','مأرب','شبوة','لحج','أبين',
    'الضالع','البيضاء','حجة','المحويت','عمران','صعدة','الجوف','ريمة','سقطرى','المهرة',
  ];

  void toggleAgreed() => agreed.value = !agreed.value;

  void register() {
    // 1) تحقق من الفورم
    if (!(formKey.currentState?.validate() ?? false)) return;

    // 2) تحقق من اختيار المحافظة
    if (governorate.value == null) {
      Get.snackbar('register.title'.tr, 'register.governorate.required'.tr);
      return;
    }

    // 3) تحقق من الشروط
    if (!agreed.value) {
      Get.snackbar('register.title'.tr, 'register.terms.required'.tr);
      return;
    }

    // TODO: هنا لاحقًا API call
    Get.snackbar('OK', 'register.submit'.tr);
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    // تنظيف الموارد
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
