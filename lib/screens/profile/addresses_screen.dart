import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../controllers/addresses/addresses_controller.dart';
import '../../widgets/cart/address_section.dart';
import '../../widgets/cart/shipping_address_sheet.dart';

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
                  borderColor: context.border.withValues(alpha: .35),
                  size: 40,
                  radius: 14,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    Tk.addressesShippingAddress.tr,
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
              Tk.addressesChooseShipping.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.muted,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.addresses.isEmpty) {
                return AddressSection(
                  title: Tk.addressesShippingAddress.tr,
                  address: null,
                  lines: const [],
                  allowAddWhenEmpty: true,
                  emptyHint: Tk.addressesEmptyHint.tr,
                  onEdit: () => _openAdd(context),
                );
              }

              return Column(
                children: controller.addresses.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AddressCard(
                      title: a.isDefault
                          ? Tk.addressesDefaultAddress.tr
                          : Tk.addressesShippingAddress.tr,
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
    controller.openAddSheet(context);

    ShippingAddressSheet.showShipping(
      context,
      governorateController: controller.governorateCtrl,
      districtController: controller.districtCtrl,
      streetController: controller.streetCtrl,
      addressDetailsController: controller.addressDetailsCtrl,
      governorates: controller.governorates,
      districtsForGovernorate: controller.districtsForGovernorate,
      onSave: controller.saveFromSheet,
    );
  }

  void _openEdit(BuildContext context, String id) {
    final item = controller.addresses.firstWhere((e) => e.id == id);
    controller.openEditSheet(item);

    ShippingAddressSheet.showShipping(
      context,
      governorateController: controller.governorateCtrl,
      districtController: controller.districtCtrl,
      streetController: controller.streetCtrl,
      addressDetailsController: controller.addressDetailsCtrl,
      governorates: controller.governorates,
      districtsForGovernorate: controller.districtsForGovernorate,
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
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.border.withValues(alpha: .35)),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: context.primary.withValues(alpha: .25),
                      ),
                    ),
                    child: Text(
                      Tk.addressesDefault.tr,
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
                Expanded(
                  child: InkWell(
                    onTap: onSetDefault,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isDefault
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isDefault ? context.primary : context.muted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Tk.addressesSetDefault.tr,
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
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, color: context.foreground),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: context.destructive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
