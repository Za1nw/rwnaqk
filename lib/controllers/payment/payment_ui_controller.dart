import 'package:get/get.dart';

/// كنترولر حالات واجهة الدفع (UI)
class PaymentUiController extends GetxController {
  // أضف هنا أي متغيرات حالة خاصة بالواجهة (مثلاً: تحميل، رسائل، إلخ)
  final isLoading = false.obs;
  final receiptImagePath = ''.obs;

  void setLoading(bool value) => isLoading.value = value;
  void setReceiptImagePath(String path) => receiptImagePath.value = path;
}
