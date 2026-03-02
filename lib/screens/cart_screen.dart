import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../../controllers/cart_controller.dart';

import '../../widgets/cart/cart_header.dart';
import '../../widgets/cart/address_section.dart';

import '../../widgets/cart/cart_items_list.dart';
import '../../widgets/cart/cart_total_bar.dart';
import '../../widgets/cart/cart_wishlist_section.dart';

import '../../widgets/common/app_empty_state.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            /// TOP (Header + Address)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Obx(
                    () => CartHeader(
                      title: 'Cart',
                      count: controller.cartItems.length,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Address Section (Edit إذا موجود / Add إذا فاضي)
                  AddressSection(
                    title: 'Shipping Address',

                    // خليها فاضية عشان يظهر AddInfoCard
                    address: '',

                    // عند الضغط على زر (+) يفتح الفورم مباشرة
                    onEdit: () {
                      ShippingAddressSheet.showShipping(
                        context,
                        addressController: TextEditingController(),
                        cityController: TextEditingController(),
                        postcodeController: TextEditingController(),
                        country: 'Yemen',
                        countries: const [
                          'Yemen',
                          'Saudi Arabia',
                          'UAE',
                          'India',
                        ],
                        onCountryChanged: (_) {},
                        onSave: () => Navigator.pop(context),
                      );
                    },
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
                      /// CART ITEMS
                      CartItemsList(
                        items: controller.cartItems,
                        onRemove: controller.removeFromCart,
                      ),

                      const SizedBox(height: 16),

                      /// FROM WISHLIST
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
                onCheckout: controller.goCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
