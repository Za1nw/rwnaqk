import 'package:get/get.dart';

class ProductDetailsUiController extends GetxController {
  final RxInt selectedThumb = 0.obs;
  final RxBool isFavorite = false.obs;
  final RxString deliverySelected = 'standard'.obs;
  final RxString selectedColorId = ''.obs;
  final RxString selectedSize = ''.obs;

  void selectThumb({
    required int index,
    required int maxLength,
  }) {
    if (maxLength <= 0) {
      selectedThumb.value = 0;
      return;
    }

    selectedThumb.value = index.clamp(0, maxLength - 1);
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void setDelivery(String id) {
    deliverySelected.value = id;
  }

  void setSelectedColor(String colorId) {
    selectedColorId.value = colorId.trim();
  }

  void setSelectedSize(String value) {
    selectedSize.value = value.trim();
  }

  void setResolvedSelections({
    required String colorId,
    required String size,
    required int thumbIndex,
    required int variationImagesLength,
  }) {
    selectedColorId.value = colorId;
    selectedSize.value = size;

    if (variationImagesLength <= 0) {
      selectedThumb.value = 0;
    } else {
      selectedThumb.value = thumbIndex.clamp(0, variationImagesLength - 1);
    }
  }
}