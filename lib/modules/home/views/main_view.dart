import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/widgets/app_bottom_nav.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavigationProvider);
    final navNotifier = ref.read(mainNavigationProvider.notifier);

    final cartCount = ref.watch(cartProvider).itemCount;
    final wishlistCount = ref.watch(wishlistProvider).itemCount;
    final customer = ref.watch(currentCustomerProvider);

    final pages = [
      const HomeScreen(),
      const WishlistScreen(),
      const OrdersScreen(),
      const CartScreen(),
      const SettingsScreen(),
    ];

    final fullName = customer?.fullName;
    final firstName = customer?.firstName;
    final String displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : ((firstName != null && firstName.isNotEmpty)
            ? firstName
            : 'رَوْنَقُك');

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onChanged: navNotifier.changeTab,
        profileName: displayName,
        profileAvatarPath: '',
        profileAvatarUrl: customer?.avatarUrl ?? '',
        cartBadgeCount: cartCount,
        wishlistBadgeCount: wishlistCount,
      ),
    );
  }
}
