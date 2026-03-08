import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';

enum RecentFilter { today, yesterday, date }

class WishlistController extends GetxController {
  // 0 => Wishlist , 1 => Recently viewed
  final RxInt tabIndex = 0.obs;

  // Recent filter
  final Rx<RecentFilter> recentFilter = RecentFilter.today.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // بيانات المفضلة والمشاهدة مؤخراً
  final RxList<HomeProductItem> wishlist = <HomeProductItem>[].obs;
  final RxList<HomeProductItem> recentlyViewed = <HomeProductItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedMock();
  }

  void setTab(int i) => tabIndex.value = i;

  /// هل المنتج موجود داخل المفضلة؟
  bool isInWishlist(String id) {
    return wishlist.any((e) => e.id == id);
  }

  /// إضافة أو إزالة المنتج من المفضلة
  void toggleWishlist(HomeProductItem item) {
    final exists = isInWishlist(item.id);

    if (exists) {
      wishlist.removeWhere((e) => e.id == item.id);
    } else {
      wishlist.add(item);
    }
  }

  /// حذف مباشر من المفضلة
  void removeFromWishlist(String id) {
    wishlist.removeWhere((e) => e.id == id);
  }

  void setRecentFilter(RecentFilter f) {
    recentFilter.value = f;
    if (f != RecentFilter.date) selectedDate.value = null;
  }

  void chooseDate(DateTime d) {
    selectedDate.value = DateTime(d.year, d.month, d.day);
    recentFilter.value = RecentFilter.date;
  }

  String recentFilterLabel() {
    switch (recentFilter.value) {
      case RecentFilter.today:
        return 'Today';
      case RecentFilter.yesterday:
        return 'Yesterday';
      case RecentFilter.date:
        final d = selectedDate.value;
        if (d == null) return 'Choose date';
        return '${_monthName(d.month)}, ${d.day}';
    }
  }

  void openProduct(HomeProductItem p) {
    final isSale = (p.discountPercent ?? 0) > 0;
    Get.toNamed(
      AppRoutes.product,
      arguments: {'item': p, 'forceSale': isSale},
    );
  }

  void addToCart(HomeProductItem p) {
    Get.snackbar(
      'Cart',
      'Added "${p.title}" to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // -----------------------------
  // Mock data
  // -----------------------------
  void _seedMock() {
    wishlist.assignAll(
      _sampleProducts(4, seed: 900, discount: 20, tagKey: 'Pink'),
    );
    recentlyViewed.assignAll(_sampleProducts(6, seed: 800));
  }

  List<HomeProductItem> _sampleProducts(
    int n, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return List.generate(n, (i) {
      final id = '${seed}_$i';
      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17 + (i * 5).toDouble(),
        discountPercent: discount,
        isNew: i % 3 == 0,
        tagKey: tagKey,
      );
    });
  }

  String _monthName(int m) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}