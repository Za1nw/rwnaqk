import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/wallet_transfer_account.dart';
import 'package:rwnaqk_frontend/modules/checkout/models/checkout_state.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/contact_info_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';

export 'package:rwnaqk_frontend/modules/checkout/models/checkout_state.dart';

/// موفر معلومات التواصل الخاصة بالعميل لإتمام الطلب
final customerContactInfoProvider = Provider<ContactInfoModel>((ref) {
  final session = ref.watch(authSessionProvider);
  final customer = session.customer;
  final fullName = customer?.fullName;
  final firstName = customer?.firstName;
  final displayName = (fullName != null && fullName.isNotEmpty)
      ? fullName
      : ((firstName != null && firstName.isNotEmpty) ? firstName : '');
  return ContactInfoModel(
    name: displayName,
    phone: customer?.phone ?? '',
    email: customer?.email ?? '',
  );
});

/// متحكم تدفق إتمام الشراء والدفع المعتمد في Riverpod 3 [CheckoutFlowNotifier]
class CheckoutFlowNotifier extends Notifier<CheckoutState> {
  IOrdersRepository get _ordersRepo => ref.read(ordersRepositoryProvider);

  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  /// تحديد طريقة الدفع
  void setPaymentMethod(String id) {
    state = state.copyWith(paymentMethodId: id);
  }

  /// اختيار المحفظة
  void selectWalletAccount(int index) {
    state = state.copyWith(selectedWalletAccountIndex: index);
  }

  /// تحديد صورة السند
  void setReceiptImage(File? file) {
    state = state.copyWith(
      receiptImage: () => file,
      receiptImageUrl: () => null,
    );
  }

  /// تحديد رابط صورة السند
  void setReceiptImageUrl(String? url) {
    state = state.copyWith(receiptImageUrl: () => url);
  }

  /// حذف صورة السند
  void clearReceipt() {
    state = state.copyWith(
      receiptImage: () => null,
      receiptImageUrl: () => null,
    );
  }

  /// تسجيل ملاحظات على الطلب
  void setOrderNotes(String notes) {
    state = state.copyWith(orderNotes: notes);
  }

  /// تصفير حالة الدفع
  void reset() {
    state = const CheckoutState();
  }

  /// إرسال وتأكيد الطلب المالي مع الحماية التامة من التكرار والنقر المزدوج
  Future<OrderModel?> submitCheckout({
    required CartState cart,
    required CartQuoteState quote,
    required ShippingAddress address,
    required ContactInfoModel contact,
    WalletTransferAccount? walletAccount,
    String? customIdempotencyKey,
  }) async {
    // 1. حارس فوري مانع للنقر المزدوج (Double-Submission Guard)
    if (state.isSubmitting) return null;

    // 2. التحقق من اكتمال المتطلبات والشروط المالية
    if (cart.isEmpty) {
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => 'السلة فارغة، لا يمكن إتمام الشراء.',
      );
      return null;
    }

    if (address.isEmpty || !address.isServiceable) {
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => 'عنوان التوصيل غير صالح أو خارج نطاق التغطية.',
      );
      return null;
    }

    if (contact.isEmpty) {
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => 'يرجى استكمال بيانات التواصل (رقم الهاتف).',
      );
      return null;
    }

    if (!quote.isValid) {
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => 'عرض السعر غير صالح أو قيد التحديث من الخادم.',
      );
      return null;
    }

    if (state.isWalletPayment && !state.hasReceipt) {
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => 'يرجى إرفاق صورة سند التحويل البنكي.',
      );
      return null;
    }

    // 3. تثبيت مفتاح منع التكرار المالي للاحتفاظ به أثناء إعادة المحاولة
    final idempotencyKey = customIdempotencyKey ??
        state.activeIdempotencyKey ??
        const Uuid().v4();

    state = state.copyWith(
      submissionStatus: CheckoutSubmissionStatus.submitting,
      activeIdempotencyKey: () => idempotencyKey,
      errorMessage: () => null,
    );

    try {
      // 4. رفع صورة السند إن وُجدت
      String? uploadedReceiptUrl = state.receiptImageUrl;
      if (state.isWalletPayment &&
          state.receiptImage != null &&
          (uploadedReceiptUrl == null || uploadedReceiptUrl.isEmpty)) {
        if (!AppEnv.enableMockData) {
          final apiClient = ref.read(apiClientProvider);
          final uploadRes = await apiClient.uploadFile<Map<String, dynamic>>(
            ApiEndpoints.temporaryImages,
            filePath: state.receiptImage!.path,
            fieldName: 'image',
          );
          uploadedReceiptUrl = uploadRes.data?['url']?.toString();
        } else {
          uploadedReceiptUrl =
              'https://rwnaqk.com/storage/temporary/images/receipt_mock.jpg';
        }
      }

      // 5. تجهيز بنود الطلب
      final quoteItems = cart.items.map((line) {
        final prodId = int.tryParse(line.productId) ??
            int.tryParse(line.productId.replaceAll(RegExp(r'[^0-9]'), ''));
        final varId = line.productVariationId ?? int.tryParse(line.id);
        return <String, dynamic>{
          if (varId != null && varId > 0) 'product_variation_id': varId,
          if (prodId != null && prodId > 0) 'product_id': prodId,
          'qty': line.quantity,
        };
      }).toList();

      final backendPaymentMethod =
          state.isWalletPayment ? 'wallet' : 'cash_on_delivery';

      Map<String, dynamic>? backendWalletAccount;
      if (state.isWalletPayment && walletAccount != null) {
        backendWalletAccount = {
          'company': walletAccount.companyName,
          'number': walletAccount.walletNumber,
          'name': walletAccount.receiverName,
        };
      }

      final addressId = int.tryParse(address.id) ?? quote.addressId ?? 1;

      // 6. الإرسال إلى المستودع المعتمد
      final order = await _ordersRepo.submitCheckout(
        addressId: addressId,
        items: quoteItems,
        paymentMethod: backendPaymentMethod,
        couponCode: quote.couponCode,
        shippingOptionId: quote.shippingOptionId,
        expectedGrandTotal: quote.grandTotal,
        walletAccount: backendWalletAccount,
        receiptImageUrl: uploadedReceiptUrl,
        notes: state.orderNotes.isNotEmpty ? state.orderNotes : null,
        idempotencyKey: idempotencyKey,
      );

      // 7. النجاح: تحديث الحالة وتفريغ السلة وإضافة الطلب لقائمة الطلبات
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.success,
        createdOrder: () => order,
        activeIdempotencyKey: () => null,
        receiptImage: () => null,
        receiptImageUrl: () => null,
        orderNotes: '',
      );

      ref.read(ordersProvider.notifier).addOrder(order);
      ref.read(cartProvider.notifier).clearCart();

      return order;
    } catch (e) {
      debugPrint('[CheckoutFlowNotifier.submitCheckout] error: $e');
      state = state.copyWith(
        submissionStatus: CheckoutSubmissionStatus.failed,
        errorMessage: () => e.toString(),
      );
      return null;
    }
  }
}

/// موفر تدفق إتمام الشراء والدفع الرئيسي [checkoutFlowProvider]
final checkoutFlowProvider =
    NotifierProvider<CheckoutFlowNotifier, CheckoutState>(
        CheckoutFlowNotifier.new);

/// موفر حالة جاري الإرسال
final isCheckoutSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(checkoutFlowProvider).isSubmitting;
});
