import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/core/widgets/app_bottom_nav.dart';

// استبدلهم بصفحاتك الحقيقية:
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileStore = Get.find<ProfileStoreService>();
    final pages = [
      HomeScreen(),
      WishlistScreen(),
      OrdersScreen(),
      CartScreen(),
      SettingsScreen(),
    ];

    return Obx(() {
      final i = controller.currentIndex.value;

      return Scaffold(
        body: IndexedStack(index: i, children: pages),
        bottomNavigationBar: AppBottomNav(
          currentIndex: i,
          onChanged: controller.changeTab,
          profileName: profileStore.displayName,
          profileAvatarPath: profileStore.avatarPath.value,
          profileAvatarUrl: profileStore.avatarUrl,
        ),
      );
    });
  }
}
