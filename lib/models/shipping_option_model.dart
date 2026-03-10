import 'package:flutter/material.dart';

class ShippingOptionModel {
  final String id;
  final String title;
  final String eta;
  final String priceText;
  final String? note;
  final IconData? icon;

  const ShippingOptionModel({
    required this.id,
    required this.title,
    required this.eta,
    required this.priceText,
    this.note,
    this.icon,
  });
}