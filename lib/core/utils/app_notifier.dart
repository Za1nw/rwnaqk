import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/api_error_utils.dart';

class AppNotifier {
  const AppNotifier._();

  static void success(String messageKeyOrText, {bool isKey = true}) {
    Get.snackbar(
      Tk.commonSuccess.tr,
      isKey ? messageKeyOrText.tr : messageKeyOrText,
    );
  }

  static void error(String messageKeyOrText, {bool isKey = true}) {
    Get.snackbar(
      Tk.commonError.tr,
      isKey ? messageKeyOrText.tr : messageKeyOrText,
    );
  }

  static void errorFrom(Object exception) {
    AppNotifier.error(ApiErrorUtils.toLocaleKey(exception));
  }
}
