import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/product_details_state.dart';

void main() {
  test('Test variation selection and price update', () {
    final json = {
      'id': 1,
      'title': 'بنطال تشينو كاجوال بقصة عادية للرجال',
      'price': 14000.0,
      'min_price': 14000.0,
      'max_price': 16000.0,
      'has_variation': true,
      'availableColors': [
        {'id': '1', 'name': 'Red', 'color_code': '#FF0000'},
        {'id': '2', 'name': 'Green', 'color_code': '#00FF00'},
      ],
      'availableSizes': ['Large', 'Extra Large'],
      'variations': [
        {
          'id': 104,
          'sku': 'red-Large',
          'price': 15000.0,
          'stock_qty': 125,
          'combinations': [
            {'variation_id': 1, 'variation_name': 'Color', 'value_id': 1, 'value_name': 'Red', 'value_color': '#FF0000'},
            {'variation_id': 2, 'variation_name': 'Size', 'value_id': 8, 'value_name': 'Large', 'value_color': 'L'},
          ],
        },
        {
          'id': 105,
          'sku': 'red-XLarge',
          'price': 14000.0,
          'stock_qty': 80,
          'combinations': [
            {'variation_id': 1, 'variation_name': 'Color', 'value_id': 1, 'value_name': 'Red', 'value_color': '#FF0000'},
            {'variation_id': 2, 'variation_name': 'Size', 'value_id': 9, 'value_name': 'Extra Large', 'value_color': 'XL'},
          ],
        },
        {
          'id': 106,
          'sku': 'green-Large',
          'price': 15000.0,
          'stock_qty': 61,
          'combinations': [
            {'variation_id': 1, 'variation_name': 'Color', 'value_id': 2, 'value_name': 'Green', 'value_color': '#00FF00'},
            {'variation_id': 2, 'variation_name': 'Size', 'value_id': 8, 'value_name': 'Large', 'value_color': 'L'},
          ],
        },
        {
          'id': 107,
          'sku': 'green-XLarge',
          'price': 16000.0,
          'stock_qty': 62,
          'combinations': [
            {'variation_id': 1, 'variation_name': 'Color', 'value_id': 2, 'value_name': 'Green', 'value_color': '#00FF00'},
            {'variation_id': 2, 'variation_name': 'Size', 'value_id': 9, 'value_name': 'Extra Large', 'value_color': 'XL'},
          ],
        },
      ],
    };

    final product = HomeProductItem.fromJson(json);

    var state = ProductDetailsState.initial().copyWith(
      product: () => product,
      selectedColorId: '1',
      selectedSize: 'Large',
      selectedAttributes: {'color': '1', 'size': 'Large'},
    );

    expect(state.selectedVariation?.sku, 'red-Large');
    expect(state.price, 15000.0);

    // Change size to Extra Large
    state = state.copyWith(
      selectedSize: 'Extra Large',
      selectedAttributes: {'color': '1', 'size': 'Extra Large'},
    );
    expect(state.selectedVariation?.sku, 'red-XLarge');
    expect(state.price, 14000.0);

    // Change color to Green (id: 2)
    state = state.copyWith(
      selectedColorId: '2',
      selectedAttributes: {'color': '2', 'size': 'Extra Large'},
    );
    expect(state.selectedVariation?.sku, 'green-XLarge');
    expect(state.price, 16000.0);
  });
}
