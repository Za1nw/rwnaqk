import 'package:get/get.dart';
import '../../controllers/app_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppSearchController>(() => AppSearchController());
  }
}