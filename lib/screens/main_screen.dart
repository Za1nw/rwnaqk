import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/main_controller.dart';
import 'package:rwnaqk/screens/cart_screen.dart';
import 'package:rwnaqk/widgets/app_bottom_nav.dart';

// استبدلهم بصفحاتك الحقيقية:
import 'package:rwnaqk/screens/home_screen.dart';
import 'package:rwnaqk/screens/wishlist_screen.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages =  [
      HomeScreen(),
      WishlistScreen(),
      Placeholder(),
      CartScreen(),
      Placeholder(),
    ];

    return Obx(() {
      final i = controller.currentIndex.value;

      return Scaffold(
        body: IndexedStack(
          index: i,
          children: pages,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: i,
          onChanged: controller.changeTab,
        ),
      );
    });
  }
}