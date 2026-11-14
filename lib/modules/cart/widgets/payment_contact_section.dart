import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/address_section.dart';

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
