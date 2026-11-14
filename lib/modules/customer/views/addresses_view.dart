import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/widgets/shipping_address_sheet.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/addresses_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_card.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/addresses/address_empty_state.dart';

/// شاشة إدارة عناوين الشحن والتوصيل الفاخرة للعميل (Addresses Screen) بتقنية Riverpod
class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _postcodeCtrl = TextEditingController();

  String _country = 'اليمن';
  String? _editingId;
  final List<String> _countries = const [
    'اليمن',
    'السعودية',
    'الإمارات',
    'عمان',
    'الكويت',
    'قطر',
    'البحرين',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressesProvider.notifier).loadAddresses();
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postcodeCtrl.dispose();
    super.dispose();
  }

  void _openAdd(BuildContext context) {
    _addressCtrl.clear();
    _cityCtrl.clear();
    _postcodeCtrl.clear();
    _country = 'اليمن';
    _editingId = null;

    ShippingAddressSheet.showShipping(
      context,
      addressController: _addressCtrl,
      cityController: _cityCtrl,
      postcodeController: _postcodeCtrl,
      country: _country,
      countries: _countries,
      onCountryChanged: (val) {
        if (val != null) setState(() => _country = val);
      },
      onSave: () => _saveFromSheet(context),
    );
  }

  void _openEdit(BuildContext context, ShippingAddress item) {
    _addressCtrl.text = item.address;
    _cityCtrl.text = item.city;
    _postcodeCtrl.text = item.postcode;
    _country = item.country.isNotEmpty ? item.country : 'اليمن';
    _editingId = item.id;

    ShippingAddressSheet.showShipping(
      context,
      addressController: _addressCtrl,
      cityController: _cityCtrl,
      postcodeController: _postcodeCtrl,
      country: _country,
      countries: _countries,
      onCountryChanged: (val) {
        if (val != null) setState(() => _country = val);
      },
      onSave: () => _saveFromSheet(context),
    );
  }

  Future<void> _saveFromSheet(BuildContext sheetContext) async {
    final a = _addressCtrl.text.trim();
    final c = _cityCtrl.text.trim();
    final p = _postcodeCtrl.text.trim();

    if (a.isEmpty || c.isEmpty || p.isEmpty || _country.trim().isEmpty) {
      AppToast.warning(Tk.profileEditFillAll.tr, title: Tk.commonError.tr);
      return;
    }

    final isNew = _editingId == null;
    final addresses = ref.read(addressesProvider).addresses;

    try {
      if (isNew) {
        final hasDefault = addresses.any((e) => e.isDefault);
        final newItem = ShippingAddress(
          id: '',
          country: _country,
          city: c,
          address: a,
          postcode: p,
          isDefault: !hasDefault,
        );
        await ref.read(addressesProvider.notifier).addAddress(newItem);
      } else {
        final existing = addresses.where((e) => e.id == _editingId).firstOrNull;
        final updated = ShippingAddress(
          id: _editingId!,
          country: _country,
          city: c,
          address: a,
          postcode: p,
          isDefault: existing?.isDefault ?? false,
        );
        await ref.read(addressesProvider.notifier).updateAddress(updated);
      }

      if (sheetContext.mounted) {
        Navigator.of(sheetContext).pop();
      }
      if (mounted) {
        AppToast.success(
          isNew ? 'تمت إضافة العنوان بنجاح' : 'تم تحديث بيانات العنوان بنجاح',
          title: 'عناوين التوصيل',
        );
      }
    } catch (_) {
      AppToast.error('فشل حفظ العنوان على الخادم', title: 'عناوين التوصيل');
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await ref.read(addressesProvider.notifier).setDefaultAddress(id);
      AppToast.success(
        'تم تعيين العنوان كافتراضي لتوصيل طلباتك',
        title: 'العنوان الافتراضي',
      );
    } catch (_) {
      AppToast.error('تعذر تعيين العنوان الافتراضي', title: 'العنوان الافتراضي');
    }
  }

  Future<void> _confirmDelete(ShippingAddress item) async {
    final confirmed = await AppConfirmDialog.show(
      title: 'حذف عنوان التوصيل',
      message:
          'هل أنت متأكد من رغبتك في حذف هذا العنوان نهائياً؟\n(${item.city} - ${item.address})',
      confirmLabel: 'نعم، حذف',
      cancelLabel: Tk.commonCancel.tr,
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await ref.read(addressesProvider.notifier).deleteAddress(item.id);
        AppToast.info('تم حذف العنوان بنجاح', title: 'عناوين التوصيل');
      } catch (_) {
        AppToast.error('تعذر حذف العنوان من الخادم', title: 'عناوين التوصيل');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addressesState = ref.watch(addressesProvider);
    final addresses = addressesState.addresses;

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
                    onTap: AppNav.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.addressesShippingAddress.tr,
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
              child: addressesState.isLoading && addresses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : addresses.isEmpty
                      ? AddressEmptyState(onAdd: () => _openAdd(context))
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 100),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final item = addresses[index];
                            return AddressCard(
                              address: item,
                              onSetDefault: () => _setDefault(item.id),
                              onEdit: () => _openEdit(context, item),
                              onDelete: () => _confirmDelete(item),
                            );
                          },
                        ),
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
