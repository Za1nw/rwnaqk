import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/app_select_field.dart';

class ShippingAddressSheet extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postcodeController;

  final String? country;
  final List<String> countries;

  final ValueChanged<String?> onCountryChanged;
  final VoidCallback onSave;

  const ShippingAddressSheet({
    super.key,
    required this.addressController,
    required this.cityController,
    required this.postcodeController,
    required this.country,
    required this.countries,
    required this.onCountryChanged,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required TextEditingController addressController,
    required TextEditingController cityController,
    required TextEditingController postcodeController,
    required String? country,
    required List<String> countries,
    required ValueChanged<String?> onCountryChanged,
    required VoidCallback onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShippingAddressSheet(
        addressController: addressController,
        cityController: cityController,
        postcodeController: postcodeController,
        country: country,
        countries: countries,
        onCountryChanged: onCountryChanged,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ShippingAddressSheet> createState() => _ShippingAddressSheetState();
}

class _ShippingAddressSheetState extends State<ShippingAddressSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// drag
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                Text(
                  "Shipping Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.foreground,
                  ),
                ),

                const SizedBox(height: 16),

                /// COUNTRY SELECT
                AppSelectField<String>(
                  label: "Country",
                  hint: "Select country",
                  value: widget.country,
                  items: widget.countries,
                  prefixIcon: Icons.public,
                  itemLabel: (e) => e,
                  onChanged: widget.onCountryChanged,
                ),

                const SizedBox(height: 12),

                /// ADDRESS
                AppInputField(
                  controller: widget.addressController,
                  label: "Address",
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                const SizedBox(height: 12),

                /// CITY
                AppInputField(
                  controller: widget.cityController,
                  label: "Town / City",
                  prefixIcon: Icons.location_city_outlined,
                ),

                const SizedBox(height: 12),

                /// POSTCODE
                AppInputField(
                  controller: widget.postcodeController,
                  label: "Postcode",
                  prefixIcon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),

                /// SAVE
                AppButton(
                  text: "Save Changes",
                  icon: Icons.check,
                  onPressed: widget.onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}