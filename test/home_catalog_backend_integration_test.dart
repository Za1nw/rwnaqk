import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/products_models.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/product_details_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';

class MockTestProductsRepository extends FakeProductsRepository {
  final List<HomeCategoryItem> categoriesToReturn;
  final List<HomeProductItem> productsToReturn;
  final HomeProductItem? productByIdToReturn;

  MockTestProductsRepository({
    this.categoriesToReturn = const [],
    this.productsToReturn = const [],
    this.productByIdToReturn,
  });

  @override
  Future<List<HomeCategoryItem>> getCategories({
    String? parentId,
    bool? isFeatured,
    bool? isTop,
  }) async {
    return categoriesToReturn;
  }

  @override
  Future<List<HomeProductItem>> getProducts({
    int seed = 1,
    int limit = 10,
    dynamic sort,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    String? search,
    bool? isFeatured,
  }) async {
    return productsToReturn;
  }

  @override
  Future<HomeProductItem?> getProductById(String id) async {
    return productByIdToReturn;
  }
}

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: 'ENABLE_MOCK_DATA=false\nAPP_ENV=development\nAPI_BASE_URL=http://127.0.0.1:8000',
    );
  });

  group('Home & Catalog Backend Integration Tests', () {
    test(
      'HomeCategoryItem parses real Laravel CategoryPublicResource JSON',
      () {
        final json = {
          'id': 1,
          'name': 'النساء',
          'slug': 'alnsaaa',
          'parent_id': null,
          'sorting_order_level': 0,
          'is_featured': false,
          'is_top': true,
          'feature_image': 'http://127.0.0.1:8000/images/defaults/category.png',
        };

        final item = HomeCategoryItem.fromJson(json);

        expect(item.id, equals('1'));
        expect(item.name, equals('النساء'));
        expect(item.parentId, isNull);
        expect(item.isTop, isTrue);
        expect(item.isFeatured, isFalse);
        expect(item.imageUrls, isNotEmpty);
      },
    );

    test('HomeContentNotifier loads categories and products from IProductsRepository', () async {
      final fakeCategories = [
        const HomeCategoryItem(
          id: '1',
          name: 'النساء',
          count: 10,
          imageUrls: ['http://example.com/women.jpg'],
          parentId: null,
          isTop: true,
        ),
        const HomeCategoryItem(
          id: '2',
          name: 'الرجال',
          count: 8,
          imageUrls: ['http://example.com/men.jpg'],
          parentId: null,
          isTop: true,
        ),
      ];

      final fakeProducts = [
        const HomeProductItem(
          id: '101',
          title: 'قميص صيفي كاجوال',
          imageUrl: 'http://example.com/shirt.jpg',
          price: 15000,
          discountPercent: 20,
        ),
        const HomeProductItem(
          id: '102',
          title: 'بنطال جينز كلاسيك',
          imageUrl: 'http://example.com/jeans.jpg',
          price: 22000,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(
            MockTestProductsRepository(
              categoriesToReturn: fakeCategories,
              productsToReturn: fakeProducts,
            ),
          ),
        ],
      );

      addTearDown(container.dispose);

      // Trigger build
      final notifier = container.read(homeContentProvider.notifier);
      await notifier.loadHomeData();

      final state = container.read(homeContentProvider);

      expect(state.categories, equals(fakeCategories));
      expect(state.topProducts.map((p) => p.id), contains('101'));
      expect(state.newItems.map((p) => p.id), contains('101'));
      expect(state.flashSale.map((p) => p.id), contains('101'));
    });

    test(
      'HomeProductItem parses real Laravel ProductDetailsPublicResource JSON',
      () {
        final json = {
          'id': 1,
          'title': 'بنطال تشينو كاجوال بقصة عادية للرجال',
          'short_description': 'بنطال قطني مريح وعصري مناسب للارتداء اليومي',
          'description': '<p>تم تصميم هذا البنطال ليوفر <strong>أقصى درجات الراحة</strong> طوال اليوم.</p>',
          'feature_image': 'http://127.0.0.1:8000/storage/1/chino.jpg',
          'price': 15000,
          'discount': 10,
          'sku': 'CHINO-001',
          'stock_status': 'in_stock',
          'images': [
            'http://127.0.0.1:8000/storage/1/chino.jpg',
            'http://127.0.0.1:8000/storage/2/chino_back.jpg',
            'http://127.0.0.1:8000/storage/3/chino_side.jpg',
          ],
          'variations': [
            {
              'id': 11,
              'sku': 'CHINO-RED-L',
              'price': 15000,
              'stock_qty': 5,
              'combinations': [
                {
                  'variation_name': 'color',
                  'value_name': 'Red',
                  'value_id': '10',
                },
                {
                  'variation_name': 'size',
                  'value_name': 'Large',
                  'value_id': '20',
                },
              ],
            },
            {
              'id': 12,
              'sku': 'CHINO-RED-XL',
              'price': 14000,
              'stock_qty': 8,
              'combinations': [
                {
                  'variation_name': 'color',
                  'value_name': 'Red',
                  'value_id': '10',
                },
                {
                  'variation_name': 'size',
                  'value_name': 'XLarge',
                  'value_id': '21',
                },
              ],
            },
            {
              'id': 13,
              'sku': 'CHINO-GRN-XL',
              'price': 16000,
              'stock_qty': 3,
              'combinations': [
                {
                  'variation_name': 'color',
                  'value_name': 'Green',
                  'value_id': '11',
                },
                {
                  'variation_name': 'size',
                  'value_name': 'XLarge',
                  'value_id': '21',
                },
              ],
            },
          ],
        };

        final product = HomeProductItem.fromJson(json);

        expect(product.id, equals('1'));
        expect(product.title, equals('بنطال تشينو كاجوال بقصة عادية للرجال'));
        expect(
          product.shortDescription,
          equals('بنطال قطني مريح وعصري مناسب للارتداء اليومي'),
        );
        expect(product.description, contains('أقصى درجات الراحة'));
        expect(product.images.length, equals(3));
        expect(product.variations.length, equals(3));
        expect(product.variations.first.sku, equals('CHINO-RED-L'));
        expect(product.variations.first.price, equals(15000));
      },
    );

    test('ProductDetailsState dynamically updates price, SKU, and stock based on selected variations', () {
      final variations = [
        const ProductVariationItem(
          id: 11,
          sku: 'CHINO-RED-L',
          price: 15000,
          stockQty: 5,
          combinations: [
            ProductVariationCombination(
              variationId: 1,
              variationName: 'color',
              valueId: 10,
              valueName: 'Red',
              valueColor: '#FF0000',
            ),
            ProductVariationCombination(
              variationId: 2,
              variationName: 'size',
              valueId: 20,
              valueName: 'Large',
              valueColor: '',
            ),
          ],
        ),
        const ProductVariationItem(
          id: 12,
          sku: 'CHINO-RED-XL',
          price: 14000,
          stockQty: 8,
          combinations: [
            ProductVariationCombination(
              variationId: 1,
              variationName: 'color',
              valueId: 10,
              valueName: 'Red',
              valueColor: '#FF0000',
            ),
            ProductVariationCombination(
              variationId: 2,
              variationName: 'size',
              valueId: 21,
              valueName: 'XLarge',
              valueColor: '',
            ),
          ],
        ),
        const ProductVariationItem(
          id: 13,
          sku: 'CHINO-GRN-XL',
          price: 16000,
          stockQty: 3,
          combinations: [
            ProductVariationCombination(
              variationId: 1,
              variationName: 'color',
              valueId: 11,
              valueName: 'Green',
              valueColor: '#00FF00',
            ),
            ProductVariationCombination(
              variationId: 2,
              variationName: 'size',
              valueId: 21,
              valueName: 'XLarge',
              valueColor: '',
            ),
          ],
        ),
      ];

      final baseProduct = HomeProductItem(
        id: '1',
        title: 'بنطال تشينو كاجوال بقصة عادية للرجال',
        shortDescription: 'وصف قصير للبنطال',
        description: 'محتوى تفصيلي كامل للبنطال',
        price: 15000,
        sku: 'CHINO-BASE',
        stockText: '10 متوفر',
        imageUrl: 'http://example.com/chino.jpg',
        images: const [
          'http://example.com/chino.jpg',
          'http://example.com/chino2.jpg',
        ],
        variations: variations,
      );

      // Initial state without specific variation selected
      var state = ProductDetailsState(product: baseProduct);
      expect(state.price, equals(15000));
      expect(state.shortDescription, equals('وصف قصير للبنطال'));
      expect(state.description, equals('محتوى تفصيلي كامل للبنطال'));
      expect(state.sku, equals('CHINO-BASE'));

      // Select Red + XLarge (price 14000, SKU CHINO-RED-XL)
      state = state.copyWith(selectedColorId: '10', selectedSize: 'XLarge');
      expect(state.selectedVariation, isNotNull);
      expect(state.selectedVariation!.id, equals(12));
      expect(state.price, equals(14000));
      expect(state.sku, equals('CHINO-RED-XL'));
      expect(state.stockText, equals('8 متوفر'));

      // Select Green + XLarge (price 16000, SKU CHINO-GRN-XL)
      state = state.copyWith(selectedColorId: '11', selectedSize: 'XLarge');
      expect(state.selectedVariation, isNotNull);
      expect(state.selectedVariation!.id, equals(13));
      expect(state.price, equals(16000));
      expect(state.sku, equals('CHINO-GRN-XL'));
      expect(state.stockText, equals('3 متوفر'));

      // Select an un-configured combination -> falls back to base price
      state = state.copyWith(selectedColorId: '99', selectedSize: 'Small');
      expect(state.selectedVariation, isNull);
      expect(state.price, equals(15000));
      expect(state.sku, equals('CHINO-BASE'));
    });

    test('ProductDetailsNotifier loads full product details with variations from repository', () async {
      const detailedProduct = HomeProductItem(
        id: '1',
        title: 'بنطال تشينو كاجوال',
        imageUrl: 'http://example.com/1.jpg',
        shortDescription: 'وصف ملخص',
        description: '<p>وصف طويل من الباك اند</p>',
        price: 12000,
        images: ['http://example.com/1.jpg', 'http://example.com/2.jpg'],
        variations: [
          ProductVariationItem(
            id: 100,
            sku: 'CHINO-100',
            price: 13500,
            stockQty: 4,
            combinations: [
              ProductVariationCombination(
                variationId: 2,
                variationName: 'size',
                valueId: 5,
                valueName: 'Medium',
                valueColor: '',
              ),
            ],
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(
            MockTestProductsRepository(productByIdToReturn: detailedProduct),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productDetailsFamily('1').notifier);
      await notifier.loadProduct(
        initialItem: const HomeProductItem(
          id: '1',
          title: 'بنطال',
          imageUrl: 'http://example.com/1.jpg',
          price: 12000,
        ),
      );

      final state = container.read(productDetailsFamily('1'));
      expect(state.product?.shortDescription, equals('وصف ملخص'));
      expect(
        state.product?.description,
        equals('<p>وصف طويل من الباك اند</p>'),
      );
      expect(state.product?.images.length, equals(2));
      expect(state.product?.variations.length, equals(1));
      // First variation is adopted as default automatically
      expect(state.selectedSize, equals('Medium'));
      expect(state.price, equals(13500));
      expect(state.sku, equals('CHINO-100'));
    });

    test('Size Guide parses server JSON and accurately sets hasSizeGuide', () {
      final withGuideJson = {
        'id': '10',
        'title': 'فستان سهرة',
        'imageUrl': 'http://example.com/dress.jpg',
        'price': 25000,
        'size_guide': '{"headers":["المقاس","محيط الصدر"],"rows":[["S","84cm"],["M","88cm"]]}',
      };

      final productWithGuide = HomeProductItem.fromJson(withGuideJson);
      final stateWithGuide = ProductDetailsState(product: productWithGuide);

      expect(stateWithGuide.hasSizeGuide, isTrue);
      expect(stateWithGuide.sizeGuide, isNotNull);
      expect(stateWithGuide.sizeGuide!.columns.length, equals(1));
      expect(
        stateWithGuide.sizeGuide!.columns.first.label,
        equals('محيط الصدر'),
      );
      expect(stateWithGuide.sizeGuide!.rows.length, equals(2));
      expect(stateWithGuide.sizeGuide!.rows.first.size, equals('S'));

      final withoutGuideJson = {
        'id': '11',
        'title': 'عطر فاخر',
        'imageUrl': 'http://example.com/perfume.jpg',
        'price': 30000,
        'size_guide': null,
      };

      final productWithoutGuide = HomeProductItem.fromJson(withoutGuideJson);
      final stateWithoutGuide = ProductDetailsState(
        product: productWithoutGuide,
      );

      expect(stateWithoutGuide.hasSizeGuide, isFalse);
      expect(stateWithoutGuide.sizeGuide, isNull);
    });

    test('Products without variations show correct hasVariations and quantity calculation', () {
      const simpleProduct = HomeProductItem(
        id: '99',
        title: 'حقيبة يد جلدية',
        imageUrl: 'http://example.com/bag.jpg',
        price: 8000,
      );

      final state = ProductDetailsState(product: simpleProduct);
      expect(state.hasVariations, isFalse);
      expect(state.price, equals(8000));
      expect(state.totalPrice, equals(8000));

      final stateQty3 = state.copyWith(quantity: 3);
      expect(stateQty3.quantity, equals(3));
      expect(stateQty3.totalPrice, equals(24000));
    });
  });
}
