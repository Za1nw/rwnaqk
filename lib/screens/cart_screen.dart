import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../controllers/cart/cart_controller.dart';
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

            Expanded(
              child: Obx(() {
                final isEmpty = controller.cartItems.isEmpty;
                final hasWishlist = wishlistController.wishlist.isNotEmpty;

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
                        const AppEmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Your cart is empty',
                          subtitle: 'Add items from your wishlist',
                        )
                      else
                        CartItemsList(
                          items: controller.cartItems,
                          onRemove: controller.removeFromCart,
                        ),

                      if (hasWishlist) ...[
                        const SizedBox(height: 16),
                        CartWishlistSection(
                          onAdd: controller.addToCart,
                        ),
                      ],

                      const SizedBox(height: 90),
                    ],
                  ),
                );
              }),
            ),

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