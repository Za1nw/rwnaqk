import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة العناوين.
///
/// نستخدمه لإدارة:
/// - قائمة العناوين
/// - حفظ عنوان جديد أو تعديل عنوان موجود
/// - تعيين العنوان الافتراضي
/// - حذف عنوان
///
/// كما أنه يعمل كحلقة ربط بين:
/// - AddressesUiController الخاص بحالة الفورم
/// - AddressesService الخاص بالبيانات والتجهيزات
class AddressesController extends GetxController {
  AddressesController(this._service);

  final AddressesService _service;
  final _store = Get.find<ProfileStoreService>();
  AddressesUiController get ui => Get.find<AddressesUiController>();

  /// قائمة العناوين الحالية.
  RxList<ShippingAddress> get addresses => _store.addresses;

  // =========================
  // UI BRIDGES
  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  List<String> get countries => _service.countries;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  TextEditingController get addressCtrl => ui.addressCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  TextEditingController get cityCtrl => ui.cityCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  TextEditingController get postcodeCtrl => ui.postcodeCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxnString get country => ui.country;

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller وتحميل البيانات التجريبية.
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    if (addresses.isEmpty) {
      seedMockData();
    }
  }

  /// هذه الدالة تهيئ البيانات التجريبية الخاصة بالعناوين.
  void seedMockData() {
    _service.saveAddresses(_service.seedMockAddresses());
  }

  /// هذه الدالة تغيّر الدولة المختارة في النموذج.
  void setCountry(String? value) {
    ui.setCountry(value);
  }

  /// هذه الدالة تجهز النموذج لوضع إضافة عنوان جديد.
  ///
  /// أبقينا نفس التوقيع الحالي حتى لا تنكسر الشاشة.
  void openAddSheet(_) {
    ui.openAddSheet();
  }

  /// هذه الدالة تجهز النموذج لوضع تعديل عنوان موجود.
  void openEditSheet(ShippingAddress item) {
    ui.openEditSheet(item);
  }

  /// هذه الدالة تحفظ بيانات النموذج:
  /// - تضيف عنوانًا جديدًا إذا لم نكن في وضع التعديل
  /// - أو تعدّل العنوان الحالي إذا كان هناك editingId
  void saveFromSheet() {
    final c = (country.value ?? '').trim();
    final a = addressCtrl.text.trim();
    final city = cityCtrl.text.trim();
    final p = postcodeCtrl.text.trim();

    if (c.isEmpty || a.isEmpty || city.isEmpty || p.isEmpty) {
      AppToast.warning(Tk.profileEditFillAll.tr, title: Tk.commonError.tr);
      return;
    }

    if (ui.editingId == null) {
      final hasDefault = addresses.any((e) => e.isDefault);

      final newItem = ui.buildAddressFromForm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isDefault: !hasDefault,
      );

      addresses.add(newItem);
    } else {
      final idx = addresses.indexWhere((e) => e.id == ui.editingId);

      if (idx != -1) {
        final old = addresses[idx];
        final updated = ui.buildAddressFromForm(
          id: old.id,
          isDefault: old.isDefault,
        );

        addresses[idx] = updated;
      }
    }

    _service.saveAddresses(addresses.toList(growable: false));

    AppToast.success(
      ui.editingId == null
          ? 'تمت إضافة العنوان بنجاح'
          : 'تم تحديث بيانات العنوان بنجاح',
      title: 'عناوين التوصيل',
    );

    Get.back();
  }

  /// هذه الدالة تجعل عنوانًا واحدًا فقط هو الافتراضي.
  void setDefault(String id) {
    _service.saveAddresses(
      _service.markDefault(
        addresses: addresses.toList(growable: false),
        id: id,
      ),
    );
    AppToast.success(
      'تم تعيين العنوان كافتراضي لتوصيل طلباتك',
      title: 'العنوان الافتراضي',
    );
  }

  /// طلب تأكيد قبل الحذف لمنع الحذف العرضي
  Future<void> confirmDeleteAddress(String id) async {
    final item = addresses.firstWhereOrNull((e) => e.id == id);
    if (item == null) return;

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
      deleteAddress(id);
      AppToast.info('تم حذف العنوان بنجاح', title: 'عناوين التوصيل');
    }
  }

  /// هذه الدالة تحذف عنوانًا من القائمة.
  ///
  /// وإذا تم حذف العنوان الافتراضي، نضمن أن يبقى هناك عنوان افتراضي
  /// إذا كانت القائمة لا تزال تحتوي على عناصر.
  void deleteAddress(String id) {
    final next = addresses.where((e) => e.id != id).toList();

    _service.saveAddresses(_service.buildDefaultAfterDelete(next));
  }
}
