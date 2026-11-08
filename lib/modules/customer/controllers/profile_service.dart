import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class ProfileStatsItem {
  final String value;
  final String labelKey;
  final IconData icon;
  final VoidCallback? onTap;

  const ProfileStatsItem({
    required this.value,
    required this.labelKey,
    this.icon = Icons.insights_rounded,
    this.onTap,
  });
}

class ProfileInfoItem {
  final String titleKey;
  final String value;
  final IconData icon;
  final bool isCopyable;
  final bool isVerified;
  final VoidCallback? onTap;

  const ProfileInfoItem({
    required this.titleKey,
    required this.value,
    this.icon = Icons.info_outline_rounded,
    this.isCopyable = false,
    this.isVerified = false,
    this.onTap,
  });
}

class ProfileService {
  ProfileService(this._store);

  final ProfileStoreService _store;

  String profileName() => _store.displayName;
  String profilePhone() => _store.phone;
  String profileEmail() => _store.email;
  String profileLocation() => _store.location;
  String profileAvatarPath() => _store.avatarPath.value;
  String profileAvatarUrl() => _store.avatarUrl;
  String profileWalletBalance() => AppMoneyUtils.riyal(_store.walletBalance);
  bool isEmailVerified() => _store.isEmailVerified;

  String membershipTier() => 'عضوية التميز الملكية';
  String membershipBadge() => 'VIP GOLD';
  String membershipPerk() => 'شحن سريع مجاني وخصم 15% إضافي';

  String ordersCount() {
    if (!Get.isRegistered<OrdersController>()) return '0';
    return Get.find<OrdersController>().orders.length.toString();
  }

  String addressesCount() => _store.addresses.length.toString();

  String wishlistCount() {
    if (!Get.isRegistered<WishlistController>()) return '0';
    return Get.find<WishlistController>().wishlist.length.toString();
  }

  List<ProfileStatsItem> stats() {
    return [
      ProfileStatsItem(
        value: ordersCount(),
        labelKey: Tk.profileViewOrdersCount,
        icon: Icons.local_shipping_outlined,
        onTap: () => Get.toNamed(AppRoutes.orders),
      ),
      ProfileStatsItem(
        value: addressesCount(),
        labelKey: Tk.profileViewAddressesCount,
        icon: Icons.location_on_outlined,
        onTap: () => Get.toNamed(AppRoutes.addresses),
      ),
      ProfileStatsItem(
        value: wishlistCount(),
        labelKey: Tk.profileViewWishlistCount,
        icon: Icons.favorite_outline_rounded,
        onTap: () => Get.toNamed(AppRoutes.wishlist),
      ),
    ];
  }

  List<ProfileInfoItem> infoItems() {
    final email = profileEmail();
    final phone = profilePhone();

    return [
      ProfileInfoItem(
        titleKey: Tk.profileViewEmail,
        value: email.isEmpty ? 'لم يتم إضافة بريد' : email,
        icon: Icons.alternate_email_rounded,
        isCopyable: email.isNotEmpty,
        isVerified: isEmailVerified(),
      ),
      ProfileInfoItem(
        titleKey: Tk.profileViewMobile,
        value: phone.isEmpty ? 'لم يتم إضافة رقم' : phone,
        icon: Icons.phone_android_rounded,
        isCopyable: phone.isNotEmpty,
        isVerified: phone.isNotEmpty,
      ),
      ProfileInfoItem(
        titleKey: 'الموقع الافتراضي',
        value: profileLocation(),
        icon: Icons.location_on_outlined,
        isCopyable: false,
      ),
      ProfileInfoItem(
        titleKey: Tk.profileViewWalletBalance,
        value: profileWalletBalance(),
        icon: Icons.account_balance_wallet_outlined,
        isCopyable: false,
      ),
    ];
  }
}
