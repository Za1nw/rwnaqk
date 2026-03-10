import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../../controllers/cart_controller.dart';
import '../../widgets/cart/address_section.dart';
import '../../widgets/cart/cart_header.dart';
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
      addressController: controller.shippingAddressCtrl,
      cityController: controller.shippingCityCtrl,
      postcodeController: controller.shippingPostcodeCtrl,
      country: controller.shippingAddress.value.country,
      countries: controller.shippingCountries,
      onCountryChanged: (value) {
        if (value != null) {
          controller.setShippingCountry(value);
        }
      },
      onSave: () {
        controller.saveShippingFromForm();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            /// TOP
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => CartHeader(
                      title: 'Cart',
                      count: controller.cartItems.length,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => AddressSection(
                      title: 'Shipping Address',
                      address: controller.hasShippingAddress
                          ? controller.shippingAddressText
                          : '',
                      onEdit: () => _openShippingSheet(
                        context,
                        isEdit: controller.hasShippingAddress,
                      ),
                      allowAddWhenEmpty: true,
                      emptyHint: 'اضف عنوان الشحن',
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: Obx(() {
                final isEmpty = controller.cartItems.isEmpty;

                if (isEmpty) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      16,
                      16,
                      16,
                    ),
                    child: Column(
                      children: [
                        AppEmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: "Your cart is empty",
                          subtitle: "Add items from your wishlist",
                        ),
                        const SizedBox(height: 16),
                        if (controller.wishlistItems.isNotEmpty)
                          CartWishlistSection(
                            items: controller.wishlistItems,
                            onAdd: controller.addToCart,
                          ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      CartItemsList(
                        items: controller.cartItems,
                        onRemove: controller.removeFromCart,
                      ),
                      const SizedBox(height: 16),
                      if (controller.wishlistItems.isNotEmpty)
                        CartWishlistSection(
                          items: controller.wishlistItems,
                          onAdd: controller.addToCart,
                        ),
                      const SizedBox(height: 90),
                    ],
                  ),
                );
              }),
            ),

            /// TOTAL BAR
            Obx(
              () => CartTotalBar(
                total: controller.total,
                enabled: controller.cartItems.isNotEmpty,
                onCheckout: controller.openPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}