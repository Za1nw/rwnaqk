import 'package:rwnaqk/models/shipping_address.dart';

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة العناوين.
///
/// نستخدمه لفصل:
/// - الدول المتاحة
/// - البيانات التجريبية
/// - منطق تعيين الافتراضي
///
/// لاحقًا عند ربط API الحقيقي، سيكون هذا الملف هو المكان المناسب
/// لجلب العناوين وحفظها وحذفها من السيرفر.
class AddressesService {
  /// الدول المتاحة داخل نموذج العنوان.
  List<String> get countries => const [
        'Yemen',
        'Saudi Arabia',
        'UAE',
        'Egypt',
      ];

  /// هذه الدالة تعيد عناوين تجريبية جاهزة.
  List<ShippingAddress> seedMockAddresses() {
    return const [
      ShippingAddress(
        id: '1',
        country: 'Yemen',
        address: 'Street 10, near the mall',
        city: 'Taiz',
        postcode: '12345',
        isDefault: true,
      ),
      ShippingAddress(
        id: '2',
        country: 'Saudi Arabia',
        address: 'King Road 22',
        city: 'Riyadh',
        postcode: '65432',
      ),
    ];
  }

  /// هذه الدالة تعيد قائمة جديدة مع جعل عنوان واحد فقط هو الافتراضي.
  List<ShippingAddress> markDefault({
    required List<ShippingAddress> addresses,
    required String id,
  }) {
    final list = addresses.toList();

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(isDefault: list[i].id == id);
    }

    return list;
  }

  /// هذه الدالة تضمن بقاء عنوان افتراضي بعد الحذف.
  ///
  /// إذا لم يعد هناك عنوان افتراضي بعد الحذف وكان هناك عناصر متبقية،
  /// يتم جعل أول عنوان هو الافتراضي.
  List<ShippingAddress> buildDefaultAfterDelete(List<ShippingAddress> addresses) {
    if (addresses.isEmpty) return addresses;

    final hasDefault = addresses.any((e) => e.isDefault);
    if (hasDefault) return addresses;

    final list = addresses.toList();
    list[0] = list[0].copyWith(isDefault: true);
    return list;
  }
}