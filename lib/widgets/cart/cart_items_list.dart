import 'package:flutter/material.dart';
import '../../models/home_product_item.dart';
import 'cart_item_tile.dart';

final cartItems = [
  HomeProductItem(
    id: "1",
    title: "Modern Light Clothes",
    price: 212,
    imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab",
  ),
  HomeProductItem(
    id: "2",
    title: "Nike Air Max Shoes",
    price: 340,
    imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
  ),
];

class CartItemsList extends StatelessWidget {
  final List<HomeProductItem> items;
  final Function(String id) onRemove;

  const CartItemsList({super.key, required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CartItemTile(
                      item: HomeProductItem(
                        id: "p1",
                        title: "Apple AirPods Pro (2nd Gen)",
                        imageUrl: "https://picsum.photos/200",
                        price: 49.99,
                      ),
                      quantity: 2,
                      variantText: "Black • Size M",
                      onIncrement: () {},
                      onDecrement: () {},
                      onRemove: () {},
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}
