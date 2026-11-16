/// نقاط نهاية المصادقة وحساب العميل والأمان [AuthEndpoints]
class AuthEndpoints {
  AuthEndpoints._();

  /// تسجيل حساب عميل جديد
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/register`
  /// - جسم الطلب (Body):
  ///   - `name`: اسم العميل
  ///   - `phone`: رقم الهاتف (بالصيغة اليمنية المعتمدة)
  ///   - `email`: البريد الإلكتروني (اختياري أو إلزامي حسب الإعدادات)
  ///   - `password`: كلمة المرور
  ///   - `password_confirmation`: تأكيد كلمة المرور
  static const String register = '/api/v1/customer/auth/register';

  /// تسجيل الدخول للعميل
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/login`
  /// - جسم الطلب (Body):
  ///   - `login`: البريد الإلكتروني أو رقم الهاتف
  ///   - `password`: كلمة المرور
  ///   - `device_name`: اسم الجهاز/المنصة لحفظ جلسة التوكن
  static const String login = '/api/v1/customer/auth/login';

  /// جلب بيانات حساب العميل المسجل حالياً (الملف الشخصي والجلسة الفعالة)
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/customer/auth/me`
  /// - الترويسة: تتطلب `Authorization: Bearer {token}`
  static const String me = '/api/v1/customer/auth/me';

  /// تسجيل الخروج وإلغاء توكن الجلسة الحالية
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/logout`
  static const String logout = '/api/v1/customer/auth/logout';

  /// إرسال طلب استعادة كلمة المرور عبر البريد أو الهاتف
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/forgot-password`
  /// - جسم الطلب: `email` أو `phone`
  static const String forgotPassword = '/api/v1/customer/auth/forgot-password';

  /// التحقق من رمز التحقق الخاص باستعادة كلمة المرور
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/verify-reset-code`
  /// - جسم الطلب: `login` (بريد أو هاتف)، `code` (رمز OTP المكون من 6 أرقام)
  static const String verifyPasswordResetCode =
      '/api/v1/customer/auth/verify-reset-code';

  /// تعيين كلمة مرور جديدة بعد التحقق من الرمز
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/reset-password`
  /// - جسم الطلب: `login`, `code`, `password`, `password_confirmation`
  static const String resetPassword = '/api/v1/customer/auth/reset-password';

  /// طلب إرسال رمز تأكيد وتفعيل البريد الإلكتروني
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/email/verification-code`
  static const String sendVerificationCode =
      '/api/v1/customer/auth/email/verification-code';

  /// التحقق من كود تفعيل البريد الإلكتروني
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/email/verify-code`
  /// - جسم الطلب: `code` (رمز OTP)
  static const String verifyEmailCode =
      '/api/v1/customer/auth/email/verify-code';

  /// تحديث بيانات الملف الشخصي الأساسية للعميل
  /// 
  /// - الطريقة: **PUT** / **POST**
  /// - المسار: `/api/v1/customer/auth/profile`
  /// - جسم الطلب: `name`, `phone`, `email`, `gender`, `avatar`
  static const String updateProfile = '/api/v1/customer/auth/profile';

  /// تغيير كلمة المرور للعميل المسجل الدخول
  /// 
  /// - الطريقة: **PUT** / **POST**
  /// - المسار: `/api/v1/customer/auth/password`
  /// - جسم الطلب: `current_password`, `password`, `password_confirmation`
  static const String changePassword = '/api/v1/customer/auth/password';

  /// قائمة جلسات تسجيل الدخول النشطة للعميل عبر الأجهزة
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/customer/auth/sessions`
  static const String sessions = '/api/v1/customer/auth/sessions';

  /// إنهاء وإلغاء جلسة تسجيل دخول محددة برقم المعرف
  /// 
  /// - الطريقة: **DELETE**
  /// - المسار: `/api/v1/customer/auth/sessions/{id}`
  static String revokeSession(int id) => '/api/v1/customer/auth/sessions/$id';

  /// إنهاء وإلغاء كافة الجلسات الأخرى على الأجهزة المختلفة والإبقاء على الجهاز الحالي
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/sessions/revoke-others`
  static const String revokeOtherSessions =
      '/api/v1/customer/auth/sessions/revoke-others';

  /// قائمة مفاتيح المرور الحيوية (Passkeys) المسجلة
  /// 
  /// - الطريقة: **GET** (جلب المفاتيح) | **POST** (تسجيل مفتاح جديد)
  /// - المسار: `/api/v1/customer/auth/passkeys`
  static const String passkeys = '/api/v1/customer/auth/passkeys';

  /// تسجيل الدخول السريع باستخدام مفتاح المرور الحيوي (Passkey)
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/auth/passkeys/login`
  static const String passkeyLogin = '/api/v1/customer/auth/passkeys/login';

  /// حذف مفتاح مرور محدد
  /// 
  /// - الطريقة: **DELETE**
  /// - المسار: `/api/v1/customer/auth/passkeys/{id}`
  static String deletePasskey(int id) => '/api/v1/customer/auth/passkeys/$id';
}
