import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/app_select_field.dart';

enum EditSection { shipping, contact }

class ShippingAddressSheet extends StatefulWidget {
  final EditSection section;

  /// -----------------------
  /// Shipping controllers
  final TextEditingController? addressController;
  final TextEditingController? cityController;
  final TextEditingController? postcodeController;

  final String? country;
  final List<String>? countries;
  final ValueChanged<String?>? onCountryChanged;

  /// -----------------------
  /// Contact controllers
  final TextEditingController? phoneController;
  final TextEditingController? emailController;

  /// -----------------------
  final VoidCallback onSave;

  const ShippingAddressSheet({
    super.key,
    required this.section,
    this.addressController,
    this.cityController,
    this.postcodeController,
    this.country,
    this.countries,
    this.onCountryChanged,
    this.phoneController,
    this.emailController,
    required this.onSave,
  }) : assert(
          section == EditSection.shipping
              ? (addressController != null &&
                  cityController != null &&
                  postcodeController != null &&
                  countries != null &&
                  onCountryChanged != null)
              : true,
          'Shipping mode requires address/city/postcode/countries/onCountryChanged',
        ),
        assert(
          section == EditSection.contact
              ? (phoneController != null && emailController != null)
              : true,
          'Contact mode requires phoneController & emailController',
        );

  // =========================
  // Show helpers (أفضل لك بالاستدعاء)
  // =========================

  static Future<void> showShipping(
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
        section: EditSection.shipping,
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

  static Future<void> showContact(
    BuildContext context, {
    required TextEditingController phoneController,
    required TextEditingController emailController,
    required VoidCallback onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShippingAddressSheet(
        section: EditSection.contact,
        phoneController: phoneController,
        emailController: emailController,
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

    final isShipping = widget.section == EditSection.shipping;

    final title = isShipping ? "Shipping Address" : "Contact Information";
    final saveText = "Save Changes";

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.foreground,
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // SHIPPING UI
                // =========================
                if (isShipping) ...[
                  AppSelectField<String>(
                    label: "Country",
                    hint: "Select country",
                    value: widget.country,
                    items: widget.countries!,
                    prefixIcon: Icons.public,
                    itemLabel: (e) => e,
                    onChanged: widget.onCountryChanged!,
                  ),
                  const SizedBox(height: 12),

                  AppInputField(
                    controller: widget.addressController!,
                    label: "Address",
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  AppInputField(
                    controller: widget.cityController!,
                    label: "Town / City",
                    prefixIcon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 12),

                  AppInputField(
                    controller: widget.postcodeController!,
                    label: "Postcode",
                    prefixIcon: Icons.local_post_office_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],

                // =========================
                // CONTACT UI
                // =========================
                if (!isShipping) ...[
                  AppInputField(
                    controller: widget.phoneController!,
                    label: "Phone",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  AppInputField(
                    controller: widget.emailController!,
                    label: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],

                const SizedBox(height: 18),

                AppButton(
                  text: saveText,
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