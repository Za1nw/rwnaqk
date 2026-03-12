import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة المفضلة.
///
/// نستخدمه لإدارة:
/// - قائمة المفضلة
/// - قائمة العناصر التي تمت مشاهدتها مؤخرًا
/// - الإضافة والإزالة من المفضلة
/// - فتح صفحة المنتج
/// - الإضافة إلى السلة
///
/// كما أنه يعمل كحلقة ربط بين:
/// - WishlistUiController الخاص بحالات الواجهة
/// - WishlistService الخاص بالبيانات التجريبية والمنطق المساعد
class WishlistController extends GetxController {
  WishlistController(this._service);

  final WishlistService _service;

  late final WishlistUiController ui;

  /// قائمة المنتجات المضافة إلى المفضلة.
  final RxList<HomeProductItem> wishlist = <HomeProductItem>[].obs;

  /// قائمة المنتجات التي تمت مشاهدتها مؤخرًا.
  final RxList<HomeProductItem> recentlyViewed = <HomeProductItem>[].obs;

  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الواجهة.
  RxInt get tabIndex => ui.tabIndex;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الواجهة.
  Rx<RecentFilter> get recentFilter => ui.recentFilter;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الواجهة.
  Rxn<DateTime> get selectedDate => ui.selectedDate;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();

    ui = Get.find<WishlistUiController>();
    seedMockData();
  }

  /// هذه الدالة تغيّر التبويب الحالي.
  void setTab(int index) {
    ui.setTab(index);
  }

  /// هذه الدالة تغيّر فلتر العناصر التي تمت مشاهدتها مؤخرًا.
  void setRecentFilter(RecentFilter filter) {
    ui.setRecentFilter(filter);
  }

  /// هذه الدالة تختار تاريخًا مخصصًا للفلتر.
  void chooseDate(DateTime date) {
    ui.chooseDate(date);
  }

  /// هذه الدالة تعيد النص المناسب للفلتر الحالي.
  String recentFilterLabel() {
    return ui.recentFilterLabel();
  }

  /// هذه الدالة تتحقق هل المنتج موجود داخل المفضلة أم لا.
  bool isInWishlist(String id) {
    return wishlist.any((item) => item.id == id);
  }

  /// هذه الدالة تضيف المنتج إلى المفضلة أو تحذفه منها إذا كان موجودًا.
  void toggleWishlist(HomeProductItem item) {
    final exists = isInWishlist(item.id);

    if (exists) {
      wishlist.removeWhere((e) => e.id == item.id);
    } else {
      wishlist.add(item);
    }
  }

  /// هذه الدالة تحذف المنتج من المفضلة مباشرة حسب المعرّف.
  void removeFromWishlist(String id) {
    wishlist.removeWhere((item) => item.id == id);
  }

  /// هذه الدالة تفتح صفحة تفاصيل المنتج.
  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;

    Get.toNamed(
      AppRoutes.product,
      arguments: {
        'item': item,
        'forceSale': isSale,
      },
    );
  }

  /// هذه الدالة تضيف المنتج إلى السلة بشكل تجريبي حاليًا.
  void addToCart(HomeProductItem item) {
    Get.snackbar(
      'Cart',
      'Added "${item.title}" to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// هذه الدالة تهيئ البيانات التجريبية الخاصة بشاشة المفضلة.
  void seedMockData() {
    wishlist.assignAll(_service.seedWishlist());
    recentlyViewed.assignAll(_service.seedRecentlyViewed());
  }
}