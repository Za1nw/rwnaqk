import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/shipping_option_model.dart';

class AppCheckoutUtils {
  AppCheckoutUtils._();

  static String paymentMethodLabel({required bool isWalletPayment}) {
    return isWalletPayment
        ? Tk.cartPaymentWalletTitle.tr
        : Tk.cartPaymentCodTitle.tr;
  }

  static String cartShippingTitle(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.cartShippingExpressTitle.tr;
      case 'standard':
      default:
        return Tk.cartShippingStandardTitle.tr;
    }
  }

  static String cartShippingEta(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.cartShippingExpressEta.tr;
      case 'standard':
      default:
        return Tk.cartShippingStandardEta.tr;
    }
  }

  static String cartShippingNote(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.cartShippingExpressNote.tr;
      case 'standard':
      default:
        return Tk.cartShippingStandardNote.tr;
    }
  }

  static String productDeliveryTitle(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.productDetailsDeliveryExpressTitle.tr;
      case 'standard':
      default:
        return Tk.productDetailsDeliveryStandardTitle.tr;
    }
  }

  static String productDeliveryEta(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.productDetailsDeliveryExpressEta.tr;
      case 'standard':
      default:
        return Tk.productDetailsDeliveryStandardEta.tr;
    }
  }

  static String productDeliveryNote(String shippingId) {
    switch (shippingId) {
      case 'express':
        return Tk.productDetailsDeliveryExpressNote.tr;
      case 'standard':
      default:
        return Tk.productDetailsDeliveryStandardNote.tr;
    }
  }

  static String paymentItemSubtitle(
    HomeProductItem item, {
    required int quantity,
  }) {
    final parts = <String>[];
    final variant = AppProductUtils.variantText(item);

    if (variant != null) {
      parts.add(variant);
    }

    parts.add(
      Tk.cartQty.trParams({
        'count': '$quantity',
      }),
    );

    return AppProductUtils.joinInline(parts);
  }

  static String inlineSummary(Iterable<String> parts) {
    return AppProductUtils.joinInline(parts);
  }

  static Map<String, dynamic> cartShippingTileData(
    ShippingOptionModel option,
  ) {
    return {
      'id': option.id,
      'title': cartShippingTitle(option.id),
      'eta': cartShippingEta(option.id),
      'price': option.priceText.toUpperCase() == 'FREE'
          ? Tk.cartFree.tr
          : option.priceText,
      'note': cartShippingNote(option.id),
      'icon': option.icon,
    };
  }

  static List<Map<String, dynamic>> productDeliveryOptions() {
    return [
      {
        'id': 'standard',
        'title': productDeliveryTitle('standard'),
        'eta': productDeliveryEta('standard'),
        'price': '\$3.00',
        'note': productDeliveryNote('standard'),
      },
      {
        'id': 'express',
        'title': productDeliveryTitle('express'),
        'eta': productDeliveryEta('express'),
        'price': '\$12.00',
        'note': productDeliveryNote('express'),
      },
    ];
  }
}
