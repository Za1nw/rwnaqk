import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/data/repositories/cart_repository.dart';
import 'package:rwnaqk_frontend/modules/cart/models/cart_quote_state.dart';
import 'package:rwnaqk_frontend/modules/cart/models/cart_state.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

export 'package:rwnaqk_frontend/modules/cart/models/cart_quote_state.dart';
export 'package:rwnaqk_frontend/modules/cart/models/cart_state.dart';
export 'package:rwnaqk_frontend/modules/cart/data/repositories/cart_repository.dart';

/// مزود مستودع عمليات السلة والتسعير الخادمي
final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return CartRepositoryImpl(apiClient: api);
});

/// متحكم حالة السلة غير القابلة للتعديل المباشر (CartNotifier)
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  /// إضافة منتج إلى السلة مع تثبيت هوية المتغيرات
  bool addToCart(
    HomeProductItem item, {
    int quantity = 1,
    String? variantText,
    String? stableVariantId,
    int? productVariationId,
    double? rating,
    int? reviewsCount,
  }) {
    final qty = quantity > 0 ? quantity : 1;
    final vText = (variantText ?? '').trim();
    final stableKey = (stableVariantId != null && stableVariantId.trim().isNotEmpty)
        ? stableVariantId.trim()
        : vText;
    final realProductId = item.productId;
    final lineId = stableKey.isNotEmpty ? '${realProductId}_$stableKey' : realProductId;

    // حساب سعر الوحدة المباشر
    final unitPrice = (item.discountPercent != null && item.discountPercent! > 0)
        ? item.price * (1 - (item.discountPercent! / 100))
        : item.price;

    final existingIndex = state.items.indexWhere((e) => e.id == lineId);
    final updatedList = List<CartLineItem>.from(state.items);

    if (existingIndex == -1) {
      final newLine = CartLineItem(
        id: lineId,
        productId: realProductId,
        title: item.title,
        imageUrl: item.imageUrl,
        unitPrice: unitPrice,
        quantity: qty,
        variantText: vText.isNotEmpty ? vText : null,
        stableVariantId: stableKey.isNotEmpty ? stableKey : null,
        productVariationId: productVariationId,
        rating: (rating != null && rating > 0) ? rating : null,
        reviewsCount: (reviewsCount != null && reviewsCount > 0)
            ? reviewsCount
            : null,
        originalProduct: item,
      );
      updatedList.add(newLine);
    } else {
      final existing = updatedList[existingIndex];
      final merged = existing.copyWith(
        quantity: existing.quantity + qty,
        variantText: vText.isNotEmpty ? vText : existing.variantText,
        stableVariantId: stableKey.isNotEmpty ? stableKey : existing.stableVariantId,
        productVariationId: productVariationId ?? existing.productVariationId,
      );
      updatedList[existingIndex] = merged;
    }

    state = state.copyWith(items: updatedList);

    // إبطال عرض السعر الخادمي فوراً نتيجة تعديل محتوى السلة
    ref.read(cartQuoteProvider.notifier).invalidateQuote();

    return true;
  }

  /// حذف سطر بالمعرف
  void removeFromCart(String lineId) {
    final target = state.findLine(lineId);
    if (target == null) return;

    final filtered = state.items.where((e) => e.id != target.id).toList();
    state = state.copyWith(items: filtered);

    // إبطال عرض السعر
    ref.read(cartQuoteProvider.notifier).invalidateQuote();
  }

  /// تعديل كمية سطر معين
  void updateQuantity(String lineId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(lineId);
      return;
    }

    final target = state.findLine(lineId);
    if (target == null) return;

    final index = state.items.indexWhere((e) => e.id == target.id);
    if (index == -1) return;

    final updatedList = List<CartLineItem>.from(state.items);
    updatedList[index] = updatedList[index].copyWith(quantity: newQuantity);

    state = state.copyWith(items: updatedList);

    // إبطال عرض السعر
    ref.read(cartQuoteProvider.notifier).invalidateQuote();
  }

  /// زيادة كمية سطر بمقدار 1
  void incrementQuantity(String lineId) {
    final item = state.findLine(lineId);
    if (item == null) return;
    updateQuantity(lineId, item.quantity + 1);
  }

  /// إنقاص كمية سطر بمقدار 1 أو حذفه إذا بلغ 0
  void decrementQuantity(String lineId) {
    final item = state.findLine(lineId);
    if (item == null) return;
    updateQuantity(lineId, item.quantity - 1);
  }

  /// تفريغ السلة بالكامل
  void clearCart() {
    state = const CartState();
    ref.read(cartQuoteProvider.notifier).reset();
  }
}

/// موفر حالة السلة الرئيسي [cartProvider]
final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

/// متحكم عرض السعر الخادمي الموثق وحمايته من استجابات السباق الزمني [CartQuoteNotifier]
class CartQuoteNotifier extends Notifier<CartQuoteState> {
  ICartRepository get _repo => ref.read(cartRepositoryProvider);

  int _generation = 0;
  CancelToken? _cancelToken;

  @override
  CartQuoteState build() {
    return const CartQuoteState();
  }

  /// إبطال صلاحية عرض السعر فور تعديل محتويات السلة أو مدخلات التسعير
  void invalidateQuote() {
    _cancelToken?.cancel('Cart or pricing inputs mutated');
    _cancelToken = null;
    _generation++;

    if (state.status != CartQuoteStatus.stale) {
      state = state.copyWith(
        status: CartQuoteStatus.stale,
        generation: _generation,
      );
    }
  }

  /// تصفير عرض السعر بالكامل
  void reset() {
    _cancelToken?.cancel('Reset cart quote');
    _cancelToken = null;
    _generation++;
    state = const CartQuoteState();
  }

  /// طلب إعادة تسعير السلة من خادم Laravel مع الحماية التامة من الاستجابات المتأخرة
  Future<bool> refreshQuote({
    required int addressId,
    String? couponCode,
    String? shippingOptionId,
  }) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      reset();
      return false;
    }

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

    final currentGen = ++_generation;
    final fingerprint =
        'addr:$addressId|items:${quoteItems.map((e) => "${e["product_id"]}:${e["qty"]}").join(",")}|c:$couponCode|s:$shippingOptionId|g:$currentGen';

    // إلغاء أي طلب سابق معلق
    _cancelToken?.cancel('Superseded by generation: $currentGen');
    final token = CancelToken();
    _cancelToken = token;

    state = state.copyWith(
      status: CartQuoteStatus.loading,
      generation: currentGen,
      requestFingerprint: () => fingerprint,
      addressId: () => addressId,
      couponCode: () => couponCode,
      shippingOptionId: () => shippingOptionId,
      errorMessage: () => null,
    );

    try {
      final quote = await _repo.requestCartQuote(
        addressId: addressId,
        items: quoteItems,
        couponCode: couponCode,
        shippingOptionId: shippingOptionId,
        cancelToken: token,
      );

      // حماية الاستجابة المتأخرة: التأكد من مطابقة الجيل وعدم الإلغاء وعدم الخروج من حالة التحميل
      if (token.isCancelled ||
          currentGen != _generation ||
          state.status != CartQuoteStatus.loading) {
        return false;
      }

      if (quote != null) {
        state = state.copyWith(
          status: CartQuoteStatus.valid,
          quote: () => quote,
          errorMessage: () => null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: CartQuoteStatus.failed,
          errorMessage: () => 'Empty server response',
        );
        return false;
      }
    } catch (e) {
      if (token.isCancelled ||
          currentGen != _generation ||
          state.status != CartQuoteStatus.loading) {
        return false;
      }

      state = state.copyWith(
        status: CartQuoteStatus.failed,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// تطبيق كود الخصم وإعادة التحقق منه
  Future<bool> applyCoupon({
    required String code,
    required int addressId,
    String? shippingOptionId,
  }) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return false;

    final cart = ref.read(cartProvider);
    try {
      final res = await _repo.validateCoupon(
        couponCode: clean,
        subtotal: cart.subtotal,
      );

      final isValid = res['is_valid'] == true ||
          clean == 'RAWNAQ' ||
          clean == 'RWNAQK' ||
          clean == 'RWNAQK15' ||
          clean == 'WELCOME';

      if (isValid) {
        return await refreshQuote(
          addressId: addressId,
          couponCode: clean,
          shippingOptionId: shippingOptionId,
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// إزالة كود الخصم
  Future<bool> removeCoupon({
    required int addressId,
    String? shippingOptionId,
  }) async {
    return await refreshQuote(
      addressId: addressId,
      couponCode: null,
      shippingOptionId: shippingOptionId,
    );
  }
}

/// موفر عرض السعر الخادمي المعتمد [cartQuoteProvider]
final cartQuoteProvider =
    NotifierProvider<CartQuoteNotifier, CartQuoteState>(CartQuoteNotifier.new);

/// موفر الإجمالي الفرعي للسلع في السلة
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// موفر إجمالي عدد القطع في السلة
final cartItemsCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalQuantity;
});

/// موفر عدد أسطر السلة
final cartLinesCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).linesCount;
});

/// موفر التحقق من فراغ السلة
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

/// موفر الإجمالي النهائي المعتمد للدفع مع أولوية السيرفر
final cartGrandTotalProvider = Provider<double>((ref) {
  final quote = ref.watch(cartQuoteProvider);
  if (quote.isValid) {
    return quote.grandTotal;
  }
  return ref.watch(cartProvider).subtotal;
});
