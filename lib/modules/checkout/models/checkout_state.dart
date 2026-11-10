import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_service.dart';
import 'package:rwnaqk_frontend/modules/checkout/data/models/wallet_transfer_account.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

/// حالات إرسال وتأكيد الطلب المالي
enum CheckoutSubmissionStatus {
  /// في وضع الاستعداد
  idle,

  /// جاري معالجة وتأكيد الطلب مع خادم Laravel
  submitting,

  /// تم اعتماد الطلب بنجاح وخصم المخزون
  success,

  /// فشل اعتماد الطلب (خطأ تحقق، انقطاع اتصال، نفاذ كمية)
  failed,
}

/// حالة إتمام الشراء والدفع غير القابلة للتغيير المباشر (Immutable Checkout Flow State)
@immutable
class CheckoutState {
  const CheckoutState({
    this.paymentMethodId = 'cod',
    this.selectedWalletAccountIndex = 0,
    this.receiptImage,
    this.receiptImageUrl,
    this.orderNotes = '',
    this.submissionStatus = CheckoutSubmissionStatus.idle,
    this.activeIdempotencyKey,
    this.createdOrder,
    this.errorMessage,
  });

  /// طريقة الدفع المختارة: 'cod' (عند الاستلام) أو 'wallet' (محفظة إلكترونية)
  final String paymentMethodId;

  /// مؤشر المحفظة/الشركة المختارة
  final int selectedWalletAccountIndex;

  /// ملف صورة سند التحويل البنكي
  final File? receiptImage;

  /// الرابط السحابي لصورة السند المؤقتة
  final String? receiptImageUrl;

  /// ملاحظات العميل للمندوب
  final String orderNotes;

  /// حالة الإرسال الحالية
  final CheckoutSubmissionStatus submissionStatus;

  /// مفتاح منع التكرار المالي المستقر لعملية الشراء
  final String? activeIdempotencyKey;

  /// كائن الطلب المعتمد عند النجاح
  final OrderModel? createdOrder;

  /// رسالة الخطأ في حال الفشل
  final String? errorMessage;

  /// هل الطلب قيد المعالجة والإرسال؟
  bool get isSubmitting =>
      submissionStatus == CheckoutSubmissionStatus.submitting;

  /// هل تم اعتماد الطلب بنجاح؟
  bool get isSuccess => submissionStatus == CheckoutSubmissionStatus.success;

  /// هل فشل اعتماد الطلب؟
  bool get isFailed => submissionStatus == CheckoutSubmissionStatus.failed;

  /// هل طريقة الدفع محفظة إلكترونية تتطلب سنداً بنكياً؟
  bool get isWalletPayment => paymentMethodId == 'wallet';

  String get paymentMethodLabel {
    return isWalletPayment ? 'محفظة إلكترونية' : 'الدفع عند الاستلام';
  }

  List<WalletTransferAccount> get walletAccounts =>
      PaymentService().getWalletAccounts();

  WalletTransferAccount get selectedWalletAccount {
    final accounts = walletAccounts;
    if (selectedWalletAccountIndex >= 0 && selectedWalletAccountIndex < accounts.length) {
      return accounts[selectedWalletAccountIndex];
    }
    return accounts.first;
  }

  /// هل تم إرفاق سند التحويل؟
  bool get hasReceipt =>
      receiptImage != null ||
      (receiptImageUrl != null && receiptImageUrl!.isNotEmpty);

  CheckoutState copyWith({
    String? paymentMethodId,
    int? selectedWalletAccountIndex,
    File? Function()? receiptImage,
    String? Function()? receiptImageUrl,
    String? orderNotes,
    CheckoutSubmissionStatus? submissionStatus,
    String? Function()? activeIdempotencyKey,
    OrderModel? Function()? createdOrder,
    String? Function()? errorMessage,
  }) {
    return CheckoutState(
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      selectedWalletAccountIndex:
          selectedWalletAccountIndex ?? this.selectedWalletAccountIndex,
      receiptImage: receiptImage != null ? receiptImage() : this.receiptImage,
      receiptImageUrl:
          receiptImageUrl != null ? receiptImageUrl() : this.receiptImageUrl,
      orderNotes: orderNotes ?? this.orderNotes,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      activeIdempotencyKey: activeIdempotencyKey != null
          ? activeIdempotencyKey()
          : this.activeIdempotencyKey,
      createdOrder: createdOrder != null ? createdOrder() : this.createdOrder,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutState &&
          runtimeType == other.runtimeType &&
          paymentMethodId == other.paymentMethodId &&
          selectedWalletAccountIndex == other.selectedWalletAccountIndex &&
          receiptImage?.path == other.receiptImage?.path &&
          receiptImageUrl == other.receiptImageUrl &&
          orderNotes == other.orderNotes &&
          submissionStatus == other.submissionStatus &&
          activeIdempotencyKey == other.activeIdempotencyKey &&
          createdOrder == other.createdOrder &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        paymentMethodId,
        selectedWalletAccountIndex,
        receiptImage?.path,
        receiptImageUrl,
        orderNotes,
        submissionStatus,
        activeIdempotencyKey,
        createdOrder,
        errorMessage,
      );
}

