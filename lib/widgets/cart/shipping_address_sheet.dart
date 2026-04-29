import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/app_select_field.dart';

enum EditSection { shipping, contact }

class ShippingAddressSheet extends StatefulWidget {
  final EditSection section;

  /// -----------------------
  /// Shipping controllers
  final TextEditingController? governorateController;
  final TextEditingController? districtController;
  final TextEditingController? streetController;
  final TextEditingController? addressDetailsController;
  final List<String>? governorates;
  final List<String> Function(String? governorate)? districtsForGovernorate;

  /// -----------------------
  /// Contact controllers
  final TextEditingController? phoneController;
  final TextEditingController? emailController;

  /// -----------------------
  final VoidCallback onSave;

  const ShippingAddressSheet({
    super.key,
    required this.section,
    this.governorateController,
    this.districtController,
    this.streetController,
    this.addressDetailsController,
    this.governorates,
    this.districtsForGovernorate,
    this.phoneController,
    this.emailController,
    required this.onSave,
  })  : assert(
          section == EditSection.shipping
              ? (governorateController != null &&
                  districtController != null &&
                  streetController != null &&
                  addressDetailsController != null &&
                  governorates != null &&
                  districtsForGovernorate != null)
              : true,
          'Shipping mode requires governorate/district/street/addressDetails/governorates/districtsForGovernorate',
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
    required TextEditingController governorateController,
    required TextEditingController districtController,
    required TextEditingController streetController,
    required TextEditingController addressDetailsController,
    required List<String> governorates,
    required List<String> Function(String? governorate) districtsForGovernorate,
    required VoidCallback onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShippingAddressSheet(
        section: EditSection.shipping,
        governorateController: governorateController,
        districtController: districtController,
        streetController: streetController,
        addressDetailsController: addressDetailsController,
        governorates: governorates,
        districtsForGovernorate: districtsForGovernorate,
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
    final selectedGovernorate = _normalizedValue(
      widget.governorateController?.text,
      widget.governorates ?? const [],
    );
    final districtItems =
        widget.districtsForGovernorate?.call(selectedGovernorate) ?? const [];
    final selectedDistrict = _normalizedValue(
      widget.districtController?.text,
      districtItems,
    );

    final title = isShipping
        ? Tk.addressesShippingAddress.tr
        : Tk.addressesContactInformation.tr;
    final saveText = Tk.addressesSaveChanges.tr;

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
                    label: Tk.addressesGovernorate.tr,
                    hint: Tk.addressesGovernorate.tr,
                    items: widget.governorates!,
                    value: selectedGovernorate,
                    itemLabel: (item) => item,
                    prefixIcon: Icons.map_outlined,
                    onChanged: (value) {
                      final nextValue = (value ?? '').trim();
                      final currentValue =
                          widget.governorateController!.text.trim();

                      widget.governorateController!.text = nextValue;
                      if (nextValue != currentValue) {
                        widget.districtController!.clear();
                      }

                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  AppSelectField<String>(
                    label: Tk.addressesDistrict.tr,
                    hint: Tk.addressesDistrict.tr,
                    items: districtItems,
                    value: selectedDistrict,
                    itemLabel: (item) => item,
                    prefixIcon: Icons.location_city_outlined,
                    enabled:
                        selectedGovernorate != null && districtItems.isNotEmpty,
                    onChanged: (value) {
                      widget.districtController!.text = (value ?? '').trim();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  AppInputField(
                    controller: widget.streetController!,
                    label: Tk.addressesStreet.tr,
                    hint: Tk.addressesStreet.tr,
                    prefixIcon: Icons.route_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppInputField(
                    controller: widget.addressDetailsController!,
                    label: Tk.addressesAddressDetails.tr,
                    hint: Tk.addressesAddressDetailsHint.tr,
                    prefixIcon: Icons.apartment_outlined,
                    maxLines: 2,
                  ),
                ],

                // =========================
                // CONTACT UI
                // =========================
                if (!isShipping) ...[
                  AppInputField(
                    controller: widget.phoneController!,
                    label: Tk.addressesPhone.tr,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AppInputField(
                    controller: widget.emailController!,
                    label: Tk.addressesEmail.tr,
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

  String? _normalizedValue(String? raw, List<String> items) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    return items.contains(value) ? value : null;
  }
}
