import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/cart/data/models/cart_quote_model.dart';

/// حالات آلة حالة عرض السعر الخادمي
enum CartQuoteStatus {
  /// السلة فارغة أو لم يتم طلب عرض سعر بعد
  idle,

  /// جاري احتساب عرض السعر من خادم Laravel
  loading,

  /// تم احتساب عرض السعر بنجاح وتوثيقه من الخادم
  valid,

  /// طرأ تغيير على السلة (كمية أو عنصر أو كوبون أو عنوان) مما أبطل صلاحية عرض السعر الحالي
  stale,

  /// فشل احتساب عرض السعر من الخادم (خطأ شبكة، عدم تغطية، أو خطأ تحقق)
  failed,
}

/// حالة تسعير وعرض أسعار السلة الخادمية المعتمدة (Authoritative Server Pricing State)
@immutable
class CartQuoteState {
  const CartQuoteState({
    this.status = CartQuoteStatus.idle,
    this.quote,
    this.requestFingerprint,
    this.generation = 0,
    this.errorMessage,
    this.couponCode,
    this.addressId,
    this.shippingOptionId,
  });

  /// الحالة التشغيلية الحالية لعرض السعر
  final CartQuoteStatus status;

  /// كائن عرض السعر الموثق الصادر من Laravel
  final CartQuoteModel? quote;

  /// البصمة الفريدة للطلب لمنع استجابات السباق الزمني
  final String? requestFingerprint;

  /// رقم الجيل التصاعدي للطلب
  final int generation;

  /// رسالة الخطأ في حال الفشل
  final String? errorMessage;

  /// كود الكوبون المطبق
  final String? couponCode;

  /// معرف عنوان الشحن المعتمد في الحساب
  final int? addressId;

  /// معرف خيار الشحن المختار
  final String? shippingOptionId;

  /// هل عرض السعر صالح وموثق من الخادم؟
  bool get isValid => status == CartQuoteStatus.valid && quote != null;

  /// هل جاري تحميل عرض السعر؟
  bool get isLoading => status == CartQuoteStatus.loading;

  /// هل أصبح عرض السعر غير صالح نتيجة تعديل السلة؟
  bool get isStale => status == CartQuoteStatus.stale;

  /// هل فشل جلب عرض السعر؟
  bool get isFailed => status == CartQuoteStatus.failed;

  /// هل العنوان مغطى بخدمة التوصيل؟
  bool get isServiceable => quote?.isServiceable ?? true;

  /// إجمالي المنتجات الصادر من السيرفر
  double get subtotal => quote?.subtotal ?? 0.0;

  /// إجمالي الخصومات على المنتجات من السيرفر
  double get productDiscountTotal => quote?.productDiscountTotal ?? 0.0;

  /// الخصم المطبق عبر الكوبون من السيرفر
  double get couponDiscountTotal => quote?.couponDiscountTotal ?? 0.0;
  double get discountAmount => couponDiscountTotal;

  /// رسوم الشحن الخادمي المعتمد
  double get shippingFee => quote?.shippingFee ?? 0.0;

  /// الإجمالي النهائي المعتمد للدفع من الخادم (Laravel Grand Total)
  double get grandTotal => quote?.grandTotal ?? 0.0;

  /// رسالة التنبيه أو عدم التغطية
  String? get message => quote?.message ?? errorMessage;

  CartQuoteState copyWith({
    CartQuoteStatus? status,
    CartQuoteModel? Function()? quote,
    String? Function()? requestFingerprint,
    int? generation,
    String? Function()? errorMessage,
    String? Function()? couponCode,
    int? Function()? addressId,
    String? Function()? shippingOptionId,
  }) {
    return CartQuoteState(
      status: status ?? this.status,
      quote: quote != null ? quote() : this.quote,
      requestFingerprint: requestFingerprint != null
          ? requestFingerprint()
          : this.requestFingerprint,
      generation: generation ?? this.generation,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
      couponCode: couponCode != null ? couponCode() : this.couponCode,
      addressId: addressId != null ? addressId() : this.addressId,
      shippingOptionId: shippingOptionId != null
          ? shippingOptionId()
          : this.shippingOptionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartQuoteState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          quote == other.quote &&
          requestFingerprint == other.requestFingerprint &&
          generation == other.generation &&
          errorMessage == other.errorMessage &&
          couponCode == other.couponCode &&
          addressId == other.addressId &&
          shippingOptionId == other.shippingOptionId;

  @override
  int get hashCode => Object.hash(
        status,
        quote,
        requestFingerprint,
        generation,
        errorMessage,
        couponCode,
        addressId,
        shippingOptionId,
      );
}

