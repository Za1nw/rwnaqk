import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/wallet_transfer_account.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_confirmation_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_success_view.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// كنترولر إدارة وإتمام عملية الدفع والشحن (Checkout & Payment Controller)
///
/// يربط بين بيانات السلة، تفاصيل الشحن، المحافظ، وصورة سند التحويل،
/// ومرحلة التأكيد وشاشة النجاح.
class PaymentController extends GetxController {
  final _profileStore = Get.find<ProfileStoreService>();

  /// طريقة الدفع المختارة: 'cod' (عند الاستلام) أو 'wallet' (محفظة إلكترونية)
  final paymentMethodId = 'cod'.obs;

  /// مؤشر المحفظة/الشركة المختارة ضمن قائمة المحافظ المتاحة
  final selectedWalletAccountIndex = 0.obs;

  /// حالة صورة سند التحويل البنكي
  final receiptImage = Rx<File?>(null);

  /// ملاحظات إضافية على الطلب للمندوب
  final orderNotes = ''.obs;

  /// حالة جاري إرسال وتأكيد الطلب
  final isSubmitting = false.obs;

  /// المحافظ المتاحة من إدارة النظام
  RxList<WalletTransferAccount> get walletAccounts =>
      _profileStore.walletAccounts;

  /// هل طريقة الدفع المختارة هي محفظة إلكترونية؟
  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  /// هل تم رفع سند التحويل؟
  bool get hasReceipt => receiptImage.value != null;

  /// اسم طريقة الدفع المترجم
  String get paymentMethodLabel =>
      AppCheckoutUtils.paymentMethodLabel(isWalletPayment: isWalletPayment);

  /// المحفظة المختارة حالياً
  WalletTransferAccount? get selectedWalletAccount {
    final accounts = walletAccounts;
    if (accounts.isEmpty) return null;
    final i = selectedWalletAccountIndex.value;
    final clamped = i < 0
        ? 0
        : (i >= accounts.length ? accounts.length - 1 : i);
    return accounts[clamped];
  }

  /// هل الطلب جاهز للانتقال لمرحلة التأكيد أو الاعتماد؟
  bool get canProceedToConfirmation {
    if (isSubmitting.value) return false;
    if (!Get.isRegistered<CartController>()) return false;
    final cart = Get.find<CartController>();
    if (!cart.canCheckout) return false;
    if (isWalletPayment && !hasReceipt) return false;
    return true;
  }

  /// مرادف للتوافق البرمجي
  bool get canConfirmOrder => canProceedToConfirmation;

  void setPaymentMethodId(String id) {
    paymentMethodId.value = id;
  }

  void setSelectedWalletAccountIndex(int index) {
    selectedWalletAccountIndex.value = index;
  }

  /// اختيار صورة السند من المعرض
  Future<void> pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        receiptImage.value = File(picked.path);
      }
    } catch (e) {
      AppToast.error('تعذر اختيار الصورة: $e', title: 'خطأ');
    }
  }

  /// حذف صورة السند الحالية
  void removeReceiptImage() {
    receiptImage.value = null;
  }

  /// التحقق من اكتمال المتطلبات الأساسية للشحن والدفع
  bool validateCheckoutPrerequisites() {
    if (!Get.isRegistered<CartController>()) return false;
    final cart = Get.find<CartController>();

    if (cart.cartItems.isEmpty) {
      AppToast.warning(
        Tk.cartValidationCartEmpty.tr,
        title: Tk.cartValidationCartTitle.tr,
      );
      return false;
    }

    if (!cart.hasShippingAddress) {
      AppToast.warning(
        Tk.cartValidationShippingMissing.tr,
        title: Tk.cartValidationShippingTitle.tr,
      );
      return false;
    }

    if (cart.contactInfo.value.isEmpty) {
      AppToast.warning(
        Tk.cartValidationContactMissing.tr,
        title: Tk.cartValidationContactTitle.tr,
      );
      return false;
    }

    if (isWalletPayment) {
      if (!hasReceipt) {
        AppToast.warning(
          'يرجى إرفاق صورة سند أو إشعار التحويل للانتقال لمرحلة التأكيد',
          title: 'سند التحويل مطلوب',
        );
        return false;
      }
      final acc = selectedWalletAccount;
      if (acc == null ||
          acc.receiverName.trim().isEmpty ||
          acc.walletNumber.trim().isEmpty) {
        AppToast.warning(
          Tk.cartValidationWalletMissing.tr,
          title: Tk.cartValidationWalletTitle.tr,
        );
        return false;
      }
    }

    return true;
  }

  /// الانتقال إلى شاشة مرحلة التأكيد (Step 3: التأكيد)
  void proceedToConfirmation() {
    if (!validateCheckoutPrerequisites()) return;
    Get.to(
      () => const OrderConfirmationScreen(),
      routeName: AppRoutes.orderConfirmation,
    );
  }

  /// تأكيد وإرسال الطلب نهائياً من شاشة التأكيد والانتقال إلى شاشة النجاح
  Future<void> confirmAndSubmitOrder() async {
    if (!validateCheckoutPrerequisites()) return;

    final cart = Get.find<CartController>();

    try {
      isSubmitting.value = true;
      final order = cart.payNow();

      if (order != null) {
        removeReceiptImage();
        orderNotes.value = '';

        // الانتقال الفوري والمبهج لشاشة النجاح بدلاً من شاشة التتبع المباشرة
        Get.off(
          () => const OrderSuccessScreen(),
          arguments: order,
          routeName: AppRoutes.orderSuccess,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    // التأكد من صحة الفهرس عند تحديث قائمة المحافظ
    ever<List<WalletTransferAccount>>(walletAccounts, (accounts) {
      if (accounts.isEmpty) {
        selectedWalletAccountIndex.value = 0;
        return;
      }
      final i = selectedWalletAccountIndex.value;
      if (i < 0 || i >= accounts.length) {
        selectedWalletAccountIndex.value = 0;
      }
    });
  }
}
