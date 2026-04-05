import 'package:rwnaqk/controllers/profile/profile_store_service.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة تعديل الملف الشخصي.
///
/// نستخدمه لفصل:
/// - القيم الابتدائية
/// - تجهيز بيانات الحفظ
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لجلب بيانات المستخدم وتحديثها ورفع الصورة.
class EditProfileService {
  EditProfileService(this._store);

  final ProfileStoreService _store;

  /// هذه الدالة تعيد الاسم الابتدائي الحالي.
  String initialName() => _store.name.value;

  /// هذه الدالة تعيد البريد الإلكتروني الابتدائي الحالي.
  String initialEmail() => _store.email.value;

  /// هذه الدالة تعيد نص معاينة كلمة المرور الحالي.
  String passwordPreview() => _store.passwordPreview.value;

  /// هذه الدالة تتحقق من صحة بيانات الحفظ بشكل مبدئي.
  ///
  /// حاليًا نتحقق فقط من:
  /// - عدم فراغ الاسم
  /// - عدم فراغ البريد
  /// ويمكن توسيعها لاحقًا بسهولة.
  bool canSave({
    required String name,
    required String email,
  }) {
    if (name.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    return true;
  }

  void saveProfile({
    required String name,
    required String email,
  }) {
    _store.updateProfile(
      nextName: name.trim(),
      nextEmail: email.trim(),
    );
  }
}
