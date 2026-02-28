import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/cart/shipping_address_sheet.dart';

import '../../controllers/cart_controller.dart';

import '../../widgets/cart/cart_app_bar.dart';
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
            /// TOP BAR
            CartAppBar(
                count: 2,
                shippingTitle: "Shipping Address",
                shippingAddress:
                    "26, Duong So 2, Thao Dien Ward\nHo Chi Minh city 70000",
                onEditAddress: () {
                  /// بيانات مؤقتة
                  String? selectedCountry = "Vietnam";

                  final addressCtrl = TextEditingController(
                    text: "26, Duong So 2, Thao Dien Ward",
                  );

                  final cityCtrl = TextEditingController(
                    text: "Ho Chi Minh city",
                  );

                  final postcodeCtrl = TextEditingController(text: "70000");

                  ShippingAddressSheet.show(
                    context,

                    country: selectedCountry,

                    countries: const [
                      "Vietnam",
                      "Yemen",
                      "Saudi Arabia",
                      "UAE",
                      "Egypt",
                    ],

                    onCountryChanged: (value) {
                      selectedCountry = value;
                    },

                    addressController: addressCtrl,
                    cityController: cityCtrl,
                    postcodeController: postcodeCtrl,

                    onSave: () {
                      debugPrint(selectedCountry ?? "");
                      debugPrint(addressCtrl.text);
                      debugPrint(cityCtrl.text);
                      debugPrint(postcodeCtrl.text);

                      Navigator.pop(context);
                    },
                  );
                },
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
