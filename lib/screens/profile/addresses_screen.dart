import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../controllers/addresses/addresses_controller.dart';
import '../../widgets/cart/address_section.dart';        // بطاقة العرض اللي أعطيتني
import '../../widgets/cart/shipping_address_sheet.dart'; // الشيت اللي عندك

class AddressesScreen extends GetView<AddressesController> {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            Row(
              children: [
                AppActionIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: Get.back,
                  backgroundColor: context.card,
                  iconColor: context.foreground,
                  borderColor: context.border.withOpacity(.35),
                  size: 40,
                  radius: 14,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Shipping Address'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.foreground,
                    ),
                  ),
                ),
                AppActionIconButton(
                  icon: Icons.add_rounded,
                  onTap: () => _openAdd(context),
                  backgroundColor: context.primary,
                  iconColor: Colors.white,
                  size: 40,
                  radius: 14,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'Choose your country'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.muted,
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {
              if (controller.addresses.isEmpty) {
                // لو مافي عناوين: اعرض AddInfoCard عن طريق AddressSection
                return AddressSection(
                  title: 'Shipping Address'.tr,
                  address: null, // لازم واحد فقط: address أو lines
                  // لتجاوز assert، مرر address كـ '' أو مرر lines بدلاً
                  // الأفضل: lines: const []
                  lines: const [],
                  allowAddWhenEmpty: true,
                  emptyHint: 'اضف عنوان الشحن',
                  onEdit: () => _openAdd(context),
                );
              }

              return Column(
                children: controller.addresses.map((a) {
                  // ✅ نعرض كل عنوان بكرت + default + edit
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AddressCard(
                      title: a.isDefault ? 'Default Address'.tr : 'Address'.tr,
                      addressText: a.fullText,
                      isDefault: a.isDefault,
                      onSetDefault: () => controller.setDefault(a.id),
                      onEdit: () => _openEdit(context, a.id),
                      onDelete: () => controller.deleteAddress(a.id),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    // جهز القيم
    controller.openAddSheet(context);

    ShippingAddressSheet.showShipping(
      context,
      addressController: controller.addressCtrl,
      cityController: controller.cityCtrl,
      postcodeController: controller.postcodeCtrl,
      country: controller.country.value,
      countries: controller.countries,
      onCountryChanged: controller.setCountry,
      onSave: controller.saveFromSheet,
    );
  }

  void _openEdit(BuildContext context, String id) {
    final item = controller.addresses.firstWhere((e) => e.id == id);
    controller.openEditSheet(item);

    ShippingAddressSheet.showShipping(
      context,
      addressController: controller.addressCtrl,
      cityController: controller.cityCtrl,
      postcodeController: controller.postcodeCtrl,
      country: controller.country.value,
      countries: controller.countries,
      onCountryChanged: controller.setCountry,
      onSave: controller.saveFromSheet,
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final String addressText;
  final bool isDefault;

  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.title,
    required this.addressText,
    required this.isDefault,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ استخدم نفس EditableInfoCard عندك إذا تبغى
    // هنا سويت كرت بسيط يدعم default + actions
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: context.foreground,
                    ),
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.primary.withOpacity(.25)),
                    ),
                    child: Text(
                      'Default'.tr,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              addressText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.muted,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // ✅ اختيار الافتراضي
                Expanded(
                  child: InkWell(
                    onTap: onSetDefault,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isDefault ? context.primary : context.muted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Set as default'.tr,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Edit
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, color: context.foreground),
                ),
                // Delete
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: context.destructive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}