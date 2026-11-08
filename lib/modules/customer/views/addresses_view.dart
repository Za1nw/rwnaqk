import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/shipping_address_sheet.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_empty_state.dart';

/// شاشة إدارة عناوين الشحن والتوصيل الفاخرة للعميل (Addresses Screen)
class AddressesScreen extends GetView<AddressesController> {
  const AddressesScreen({super.key});

  void _openAdd(BuildContext context) {
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
    final item = controller.addresses.firstWhereOrNull((e) => e.id == id);
    if (item == null) return;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            // ترويسة الصفحة مع زر الرجوع وزر إضافة عنوان جديد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _TopCircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'الرجوع',
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.addressesShippingAddress.tr, // 'عناوين التوصيل'
                          style: AppTextTheme.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'إدارة مواقع استلام طلباتك وشحناتك',
                          style: AppTextTheme.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TopCircleButton(
                    icon: Icons.add_location_alt_rounded,
                    tooltip: 'إضافة عنوان',
                    onTap: () => _openAdd(context),
                  ),
                ],
              ),
            ),

            // قائمة العناوين أو الحالة الفارغة
            Expanded(
              child: Obx(() {
                if (controller.addresses.isEmpty) {
                  return AddressEmptyState(onAdd: () => _openAdd(context));
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 100),
                  itemCount: controller.addresses.length,
                  itemBuilder: (context, index) {
                    final item = controller.addresses[index];
                    return AddressCard(
                      address: item,
                      onSetDefault: () => controller.setDefault(item.id),
                      onEdit: () => _openEdit(context, item.id),
                      onDelete: () => controller.confirmDeleteAddress(item.id),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.25)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
        ),
      ),
    );
  }
}
