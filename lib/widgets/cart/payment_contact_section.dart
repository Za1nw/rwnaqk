import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/cart/address_section.dart';

class PaymentContactSection extends StatelessWidget {
  final List<String> lines;
  final VoidCallback onEdit;

  const PaymentContactSection({
    super.key,
    required this.lines,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AddressSection(
      title: Tk.cartContactInformation.tr,
      lines: lines,
      onEdit: onEdit,
      allowAddWhenEmpty: false,
      emptyHint: Tk.cartAddContactInformation.tr,
    );
  }
}
