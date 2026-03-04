import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isDark = false.obs;
  final lang = 'ar'.obs; // mock

  void setDarkMode(bool v) {
    isDark.value = v;
    // اربطها لاحقًا بـ AppSettingsController الحقيقي في مشروعك
  }

  String get langLabel => lang.value == 'ar' ? 'AR' : 'EN';

  void toggleLanguageMock() {
    lang.value = (lang.value == 'ar') ? 'en' : 'ar';
    // لاحقًا: Get.updateLocale(...) + حفظ في storage
  }
}