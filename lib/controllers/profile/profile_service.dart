import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';

class ProfileStatsItem {
  final String value;
  final String labelKey;

  const ProfileStatsItem({
    required this.value,
    required this.labelKey,
  });
}

class ProfileInfoItem {
  final String titleKey;
  final String value;

  const ProfileInfoItem({
    required this.titleKey,
    required this.value,
  });
}

class ProfileService {
  ProfileService(this._store);

  final ProfileStoreService _store;

  String profileName() => _store.name.value;
  String profilePhone() => _store.phone.value;
  String profileEmail() => _store.email.value;
  String profileLocation() => _store.location;

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
      ProfileStatsItem(value: ordersCount(), labelKey: Tk.profileViewOrdersCount),
      ProfileStatsItem(
        value: addressesCount(),
        labelKey: Tk.profileViewAddressesCount,
      ),
      ProfileStatsItem(
        value: wishlistCount(),
        labelKey: Tk.profileViewWishlistCount,
      ),
    ];
  }

  List<ProfileInfoItem> infoItems() {
    return [
      ProfileInfoItem(
        titleKey: Tk.profileViewEmail,
        value: profileEmail(),
      ),
      ProfileInfoItem(
        titleKey: Tk.profileViewPhone,
        value: profilePhone(),
      ),
      ProfileInfoItem(
        titleKey: Tk.profileViewLocation,
        value: profileLocation(),
      ),
    ];
  }
}
