import 'package:get/get.dart';
import 'package:rwnaqk/controllers/search/app_search_controller.dart';
import 'package:rwnaqk/controllers/search/search_service.dart';
import 'package:rwnaqk/controllers/search/search_ui_controller.dart';

/// هذا الملف مسؤول عن حقن جميع تبعيات منظومة البحث.
///
/// نستخدم Binding واحد فقط لأن:
/// - شاشة البحث
/// - شاشة نتائج البحث
///
/// يعتمدان على نفس الكنترولر ونفس المنظومة.
class SearchBinding extends Bindings {
  @override
  /// هذه الدالة تسجل جميع التبعيات المطلوبة للبحث.
  void dependencies() {
    Get.lazyPut<SearchUiController>(() => SearchUiController(), fenix: true);
    Get.lazyPut<SearchService>(() => SearchService(), fenix: true);
    Get.lazyPut<AppSearchController>(
      () => AppSearchController(Get.find<SearchService>()),
      fenix: true,
    );
  }
}
