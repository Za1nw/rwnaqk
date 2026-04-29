import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';
import 'package:rwnaqk/widgets/common/app_page_header.dart';

import '../controllers/cart/cart_controller.dart';
import '../../widgets/cart/address_section.dart';
import '../../widgets/cart/cart_items_list.dart';
import '../../widgets/cart/cart_total_bar.dart';
import '../../widgets/cart/cart_wishlist_section.dart';
import '../../widgets/common/app_empty_state.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  void _openShippingSheet(BuildContext context, {required bool isEdit}) {
    if (isEdit) {
      controller.prepareEditShipping();
    } else {
      controller.prepareAddShipping();
    }

    ShippingAddressSheet.showShipping(
      context,
      governorateController: controller.shippingGovernorateCtrl,
      districtController: controller.shippingDistrictCtrl,
      streetController: controller.shippingStreetCtrl,
      addressDetailsController: controller.shippingAddressDetailsCtrl,
      governorates: controller.shippingGovernorates,
      districtsForGovernorate: controller.shippingDistrictsForGovernorate,
      onSave: () {
        controller.saveShippingFromForm();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => AppPageHeader(
                      title: Tk.cartTitle.tr,
                      count: controller.itemsCount,
                      onNotificationsTap: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => AddressSection(
                      title: Tk.cartShippingAddress.tr,
                      address: controller.hasShippingAddress
                          ? controller.shippingAddressText
                          : '',
                      onEdit: () => _openShippingSheet(
                        context,
                        isEdit: controller.hasShippingAddress,
                      ),
                      allowAddWhenEmpty: true,
                      emptyHint: Tk.cartAddShippingDetails.tr,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final isEmpty = controller.cartItems.isEmpty;
                final hasWishlist = wishlistController.wishlist.isNotEmpty;
                final quantities =
                    Map<String, int>.from(controller.itemQuantities);
                final variantTexts =
                    Map<String, String>.from(controller.itemVariantTexts);
                final ratings =
                    Map<String, double>.from(controller.itemRatings);
                final reviewsCounts =
                    Map<String, int>.from(controller.itemReviewsCounts);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsetsDirectional.fromSTEB(
                    18,
                    isEmpty ? 16 : 8,
                    18,
                    16,
                  ),
                  child: Column(
                    children: [
                      if (isEmpty)
                        AppEmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: Tk.cartEmptyTitle.tr,
                          subtitle: Tk.cartEmptySubtitle.tr,
                        )
                      else
                        CartItemsList(
                          items: controller.cartItems,
                          quantities: quantities,
                          variantTexts: variantTexts,
                          ratings: ratings,
                          reviewsCounts: reviewsCounts,
                          onRemove: controller.removeFromCart,
                          onIncrement: controller.incrementQuantity,
                          onDecrement: controller.decrementQuantity,
                        ),
                      if (hasWishlist) ...[
                        const SizedBox(height: 16),
                        CartWishlistSection(
                          onAdd: controller.addToCart,
                        ),
                      ],
                      const SizedBox(height: 104),
                    ],
                  ),
                );
              }),
            ),
            Obx(
              () => CartTotalBar(
                total: controller.itemsSubtotal,
                enabled: controller.canCheckout,
                totalLabel: Tk.cartSubtotal.tr,
                helperText: controller.cartItems.isEmpty
                    ? Tk.cartStartCheckout.tr
                    : Tk.cartCheckoutReady.trParams({
                        'count': '${controller.itemsCount}',
                      }),
                checkoutText: Tk.cartCheckout.tr,
                checkoutIcon: Icons.arrow_forward_rounded,
                onCheckout: controller.openPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
