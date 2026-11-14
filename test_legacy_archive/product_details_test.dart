import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/translations/app_translations.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/add_review_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_info.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_variants_sheet.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  test('ProductDetailsUiController handles quantity and size selection correctly', () {
    final ui = Get.put(ProductDetailsUiController());

    expect(ui.quantity.value, 1);

    ui.incrementQuantity();
    expect(ui.quantity.value, 2);

    ui.decrementQuantity();
    expect(ui.quantity.value, 1);

    // Should not decrement below 1
    ui.decrementQuantity();
    expect(ui.quantity.value, 1);

    ui.setSelectedSize('L');
    expect(ui.selectedSize.value, 'L');
  });

  testWidgets('ProductSizeGuideSheet renders and displays sizes and unit toggle', (tester) async {
    String? selectedSize;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ProductSizeGuideSheet.show(
                    context,
                    currentSelectedSize: 'M',
                    onSizeSelected: (size) => selectedSize = size,
                  );
                },
                child: const Text('Open Guide'),
              );
            },
          ),
        ),
      ),
    );

    // Open size guide bottom sheet
    await tester.tap(find.text('Open Guide'));
    await tester.pumpAndSettle();

    // Verify presence of size guide elements
    expect(find.byType(ProductSizeGuideSheet), findsOneWidget);
    expect(find.text('M'), findsWidgets);
    expect(find.text('L'), findsWidgets);

    // Verify callback assignment works when selecting a size
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    expect(selectedSize, 'M');
  });

  testWidgets('ProductDetailsHeaderInfo displays review count without @count placeholder bug', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar', 'YE'),
        home: const Scaffold(
          body: ProductDetailsHeaderInfo(
            title: 'فستان مخملي',
            description: 'وصف تجريبي',
            priceText: '\$14400',
            rating: 4.5,
            reviewsCount: 1,
            titleSize: 18,
            priceSize: 24,
            descSize: 13,
            rowGap: 10,
            isWide: false,
          ),
        ),
      ),
    );

    // Verify that the literal raw string "@count" does NOT appear anywhere
    expect(find.textContaining('@count'), findsNothing);
    // Verify that the formatted review count with number 1 appears
    expect(find.textContaining('1'), findsWidgets);
  });

  testWidgets('AddReviewSheet renders and submits review data', (tester) async {
    double? submittedRating;
    String? submittedComment;
    String? submittedName;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AddReviewSheet.show(
                    context,
                    onSubmit: (rating, comment, name) {
                      submittedRating = rating;
                      submittedComment = comment;
                      submittedName = name;
                    },
                  );
                },
                child: const Text('Write Review'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Write Review'));
    await tester.pumpAndSettle();

    expect(find.byType(AddReviewSheet), findsOneWidget);

    // Enter name and review comment
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'أحمد');
    await tester.enterText(textFields.last, 'منتج فخم جداً وخامة ممتازة');
    await tester.pumpAndSettle();

    // Tap submit button
    final submitBtn = find.text(Tk.reviewsSubmit.tr);
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(submittedRating, 5.0);
    expect(submittedComment, 'منتج فخم جداً وخامة ممتازة');
    expect(submittedName, 'أحمد');
  });

  testWidgets('ProductVariantsSheet renders dynamic attribute groups', (tester) async {
    Get.put(ProductDetailsUiController());
    final controller = Get.put(ProductDetailsController(ProductDetailsService()));
    controller.item.value = const HomeProductItem(
      id: 'p_1',
      title: 'فستان سهرة',
      description: 'فستان أنيق',
      imageUrl: 'https://example.com/test.jpg',
      price: 100,
    );
    controller.attributeGroups.assignAll([
      const ProductAttributeGroup(
        id: 'color',
        name: 'اللون',
        type: ProductAttributeType.color,
        options: [
          ProductAttributeOption(id: 'black', label: 'أسود', value: '#000000'),
          ProductAttributeOption(id: 'burgundy', label: 'عنابي', value: '#6E0131'),
        ],
      ),
      const ProductAttributeGroup(
        id: 'size',
        name: 'المقاس',
        type: ProductAttributeType.text,
        options: [
          ProductAttributeOption(id: 's', label: 'S'),
          ProductAttributeOption(id: 'm', label: 'M'),
        ],
      ),
    ]);
    controller.selectedAttributes['color'] = 'black';
    controller.selectedAttributes['size'] = 's';

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => ProductVariantsSheet.show(context),
                child: const Text('Open Variants'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Variants'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductVariantsSheet), findsOneWidget);
    expect(find.text('اللون'), findsOneWidget);
    expect(find.text('المقاس'), findsOneWidget);
    expect(find.text('أسود'), findsWidgets);
    expect(find.text('عنابي'), findsWidgets);
    expect(find.text('S'), findsWidgets);
    expect(find.text('M'), findsWidgets);

    // Select burgundy
    await tester.tap(find.text('عنابي'));
    await tester.pumpAndSettle();
    expect(controller.selectedAttributes['color'], 'burgundy');
  });
}
