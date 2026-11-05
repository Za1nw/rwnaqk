import 'package:flutter/material.dart';

class ShippingOptionModel {
  final String id;
  final String priceText;
  final IconData? icon;

  const ShippingOptionModel({
    required this.id,
    required this.priceText,
    this.icon,
  });
}
