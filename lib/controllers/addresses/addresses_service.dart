import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
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
  AddressesService(this._store);

  final ProfileStoreService _store;

  static const List<String> _governoratesAr = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'ذمار',
    'حضرموت',
    'مأرب',
    'شبوة',
    'لحج',
    'أبين',
    'الضالع',
    'البيضاء',
    'حجة',
    'المحويت',
    'عمران',
    'صعدة',
    'الجوف',
    'ريمة',
    'سقطرى',
    'المهرة',
  ];

  static const List<String> _governoratesEn = [
    'Sanaa',
    'Aden',
    'Taiz',
    'Al Hudaydah',
    'Ibb',
    'Dhamar',
    'Hadramout',
    'Marib',
    'Shabwah',
    'Lahij',
    'Abyan',
    'Al Dhale',
    'Al Bayda',
    'Hajjah',
    'Al Mahwit',
    'Amran',
    'Saada',
    'Al Jawf',
    'Raymah',
    'Socotra',
    'Al Mahrah',
  ];

  static const Map<String, List<String>> _districtsByGovernorateAr = {
    'صنعاء': ['معين', 'التحرير', 'الثورة', 'بني الحارث'],
    'عدن': ['المنصورة', 'خور مكسر', 'كريتر', 'الشيخ عثمان'],
    'تعز': ['القاهرة', 'المظفر', 'صالة', 'شرعب السلام'],
    'الحديدة': ['الحوك', 'الحالي', 'باجل', 'زبيد'],
    'إب': ['الظهار', 'المشنة', 'جبلة', 'السبرة'],
    'ذمار': ['مدينة ذمار', 'عنس', 'جهران', 'وصاب العالي'],
    'حضرموت': ['المكلا', 'سيئون', 'الشحر', 'تريم'],
    'مأرب': ['مدينة مأرب', 'الوادي', 'الجوبة', 'صرواح'],
    'شبوة': ['عتق', 'نصاب', 'بيحان', 'مرخة السفلى'],
    'لحج': ['الحوطة', 'تبن', 'ردفان', 'يافع'],
    'أبين': ['زنجبار', 'خنفر', 'لودر', 'مودية'],
    'الضالع': ['الضالع', 'قعطبة', 'الأزارق', 'الحصين'],
    'البيضاء': ['البيضاء', 'رداع', 'الزاهر', 'الصومعة'],
    'حجة': ['حجة', 'عبس', 'ميدي', 'كحلان عفار'],
    'المحويت': ['المحويت', 'شبام', 'الرجم', 'الطويلة'],
    'عمران': ['عمران', 'خمر', 'ريدة', 'حرف سفيان'],
    'صعدة': ['صعدة', 'سحار', 'رازح', 'باقم'],
    'الجوف': ['الحزم', 'برط العنان', 'الغيل', 'خب والشعف'],
    'ريمة': ['الجبين', 'بلاد الطعام', 'كسمة', 'مزهر'],
    'سقطرى': ['حديبو', 'قلنسية', 'ديكسام', 'موري'],
    'المهرة': ['الغيضة', 'سيحوت', 'قشن', 'حوف'],
  };

  static const Map<String, List<String>> _districtsByGovernorateEn = {
    'Sanaa': ['Maeen', 'Al Tahrir', 'Al Thawrah', 'Bani Al Harith'],
    'Aden': ['Al Mansoura', 'Khor Maksar', 'Crater', 'Al Sheikh Othman'],
    'Taiz': ['Al Qahirah', 'Al Mudhaffar', 'Salah', 'Sharab Al Salam'],
    'Al Hudaydah': ['Al Hawak', 'Al Hali', 'Bajil', 'Zabid'],
    'Ibb': ['Al Dhihar', 'Al Mashannah', 'Jiblah', 'Al Sabrah'],
    'Dhamar': ['Dhamar City', 'Anss', 'Jahran', 'Wusab Al Ali'],
    'Hadramout': ['Mukalla', 'Seiyun', 'Al Shihr', 'Tarim'],
    'Marib': ['Marib City', 'Al Wadi', 'Al Jubah', 'Sirwah'],
    'Shabwah': ['Ataq', 'Nisab', 'Bayhan', 'Markhah Al Sufla'],
    'Lahij': ['Al Hawtah', 'Tuban', 'Radfan', 'Yafea'],
    'Abyan': ['Zinjibar', 'Khanfar', 'Lawdar', 'Mudia'],
    'Al Dhale': ['Al Dhale', 'Qaatabah', 'Al Azariq', 'Al Husha'],
    'Al Bayda': ['Al Bayda', 'Radaa', 'Al Zahir', 'Al Sawmaah'],
    'Hajjah': ['Hajjah', 'Abs', 'Midi', 'Kuhlan Affar'],
    'Al Mahwit': ['Al Mahwit', 'Shibam', 'Al Rajm', 'Al Tawilah'],
    'Amran': ['Amran', 'Khamir', 'Raydah', 'Harf Sufyan'],
    'Saada': ['Saada', 'Sahar', 'Razih', 'Baqim'],
    'Al Jawf': ['Al Hazm', 'Bart Al Anan', 'Al Ghayl', 'Khab wa Ash Shaaf'],
    'Raymah': ['Al Jabin', 'Bilad Al Taam', 'Kusmah', 'Mazhar'],
    'Socotra': ['Hadibu', 'Qalansiyah', 'Diksam', 'Mori'],
    'Al Mahrah': ['Al Ghaydah', 'Sayhut', 'Qishn', 'Hawf'],
  };

  List<String> get governorates =>
      List<String>.unmodifiable(localizedGovernorateOptions());

  List<String> districtsForGovernorate(String? governorate) {
    return districtsForGovernorateValue(governorate: governorate);
  }

  static List<String> localizedGovernorateOptions() {
    return _isArabicLocale ? _governoratesAr : _governoratesEn;
  }

  static List<String> districtsForGovernorateValue({
    required String? governorate,
  }) {
    final key = (governorate ?? '').trim();
    if (key.isEmpty) return const [];

    final primaryMap =
        _isArabicLocale ? _districtsByGovernorateAr : _districtsByGovernorateEn;
    final fallbackMap =
        _isArabicLocale ? _districtsByGovernorateEn : _districtsByGovernorateAr;

    return List<String>.unmodifiable(
      primaryMap[key] ?? fallbackMap[key] ?? const [],
    );
  }

  /// هذه الدالة تعيد عناوين تجريبية جاهزة.
  List<ShippingAddress> seedMockAddresses() {
    _store.seedAddressesIfNeeded();
    return _store.addresses.toList(growable: false);
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
  List<ShippingAddress> buildDefaultAfterDelete(
      List<ShippingAddress> addresses) {
    if (addresses.isEmpty) return addresses;

    final hasDefault = addresses.any((e) => e.isDefault);
    if (hasDefault) return addresses;

    final list = addresses.toList();
    list[0] = list[0].copyWith(isDefault: true);
    return list;
  }

  void saveAddresses(List<ShippingAddress> items) {
    _store.addresses.assignAll(items);
  }

  static bool get _isArabicLocale => Get.locale?.languageCode == 'ar';
}
