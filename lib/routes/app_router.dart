import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// Auth Views
import 'package:rwnaqk_frontend/modules/auth/views/banned_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/email_verification_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/forgot_password_method_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/login_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/network_error_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/otp_verify_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/register_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/reset_password_view.dart';
import 'package:rwnaqk_frontend/modules/auth/views/two_factor_challenge_view.dart';

// Cart & Checkout Views
import 'package:rwnaqk_frontend/modules/cart/views/cart_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_confirmation_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/order_success_view.dart';
import 'package:rwnaqk_frontend/modules/checkout/views/payment_view.dart';

// Catalog & Search Views
import 'package:rwnaqk_frontend/modules/catalog/views/flash_sale_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/product_details_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/products_listing_view.dart';
import 'package:rwnaqk_frontend/modules/catalog/views/reviews_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_results_view.dart';
import 'package:rwnaqk_frontend/modules/search/views/search_view.dart';

// Customer Views
import 'package:rwnaqk_frontend/modules/customer/views/addresses_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/edit_profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/password_and_security_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/profile_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/settings_view.dart';
import 'package:rwnaqk_frontend/modules/customer/views/two_factor_and_passkeys_view.dart';

// Home Views
import 'package:rwnaqk_frontend/modules/home/views/home_view.dart';
import 'package:rwnaqk_frontend/modules/home/views/main_view.dart';

// Onboarding Views
import 'package:rwnaqk_frontend/modules/onboarding/views/onboarding_view.dart';

// Orders Views
import 'package:rwnaqk_frontend/modules/orders/views/order_details_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/order_tracking_view.dart';
import 'package:rwnaqk_frontend/modules/orders/views/orders_view.dart';

// Support Views
import 'package:rwnaqk_frontend/modules/support/views/help_center_view.dart';
import 'package:rwnaqk_frontend/modules/support/views/support_chat_view.dart';

// Wishlist Views
import 'package:rwnaqk_frontend/modules/wishlist/views/wishlist_view.dart';

/// Centralized native router replacing GetPage route table.
abstract final class AppRouter {
  const AppRouter._();

  /// مسارات تدفق المصادقة (متاحة للضيوف وغير المسجلين فقط؛ يتم تحويل المستخدم المسجل منها إلى الرئيسية)
  static const Set<String> _authFlowRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgot,
    AppRoutes.otp,
    AppRoutes.reset,
    AppRoutes.twoFactorChallenge,
  };

  /// مسارات عامة بالكامل (متاحة للزوار، الضيوف، وغير المسجلين)
  @visibleForTesting
  static const Set<String> publicRoutes = {
    AppRoutes.onboarding,
    AppRoutes.main,
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.searchResults,
    AppRoutes.flashSale,
    AppRoutes.product,
    AppRoutes.reviews,
    AppRoutes.listing,
    AppRoutes.helpCenter,
    AppRoutes.supportChat,
    AppRoutes.wishlist,
    AppRoutes.settings,
    AppRoutes.cart,
    AppRoutes.orders,
  };

  /// مسارات محمية حصراً (تتطلب مستخدماً موثقاً isAuthenticated == true؛ يُمنع الزائر والضيف تماماً)
  static const Set<String> _protectedRoutes = {
    AppRoutes.payment,
    AppRoutes.orderConfirmation,
    AppRoutes.orderSuccess,
    AppRoutes.orderDetails,
    AppRoutes.orderTracking,
    AppRoutes.addresses,
    AppRoutes.profile,
    AppRoutes.editProfile,
    AppRoutes.passwordAndSecurity,
    AppRoutes.twoFactorAndPasskeys,
  };

  /// Route generator with security guards and seamless transitions.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.onboarding;
    AppNav.currentRoute = routeName;
    AppNav.currentArguments = settings.arguments;

    // Evaluate route guard redirects
    final redirectedRoute = _checkRouteGuards(routeName);
    if (redirectedRoute != null && redirectedRoute != routeName) {
      AppNav.currentRoute = redirectedRoute;

      // إذا تم التحويل إلى شاشة الدخول بسبب مسار محمي، نرفق مسار العودة
      var redirectedArgs = settings.arguments;
      if (redirectedRoute == AppRoutes.login && _protectedRoutes.contains(routeName)) {
        final existingMap = (settings.arguments is Map<String, dynamic>)
            ? (settings.arguments as Map<String, dynamic>)
            : <String, dynamic>{};
        redirectedArgs = <String, dynamic>{
          ...existingMap,
          AppRouteArgs.returnRoute: routeName,
          if (settings.arguments != null) AppRouteArgs.returnArgs: settings.arguments,
        };
      }

      return onGenerateRoute(
        RouteSettings(name: redirectedRoute, arguments: redirectedArgs),
      );
    }

    final builder = _resolveWidgetBuilder(routeName);
    if (builder == null) {
      // Fallback 404 route: go to main or onboarding
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => const MainScreen(),
      );
    }

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: builder,
    );
  }

  static String? _checkRouteGuards(String route) {
    try {
      final session = globalProviderContainer.read(authSessionProvider);
      final isBanned = session.isBanned;
      final isAuth = session.isAuthenticated;
      final isGuest = session.isGuest;
      final requiresVerification = session.requiresEmailVerification;

      // الحظر الإلزامي: يُقفل التطبيق تماماً للمستخدم المحظور ويُوجّه حصراً لشاشة الحظر
      if (isBanned) {
        if (route == AppRoutes.banned) {
          return null;
        }
        return AppRoutes.banned;
      }

      // منع الدخول المباشر لشاشة الحظر للمستخدمين غير المحظورين
      if (route == AppRoutes.banned) {
        return isAuth ? AppRoutes.main : AppRoutes.login;
      }

      // خطأ الاتصال بالخادم: إذا كان المستخدم مسجلاً وفشل الاتصال، يُقفل التصفح ويُوجّه لشاشة الخطأ
      final hasServerError = session.hasServerError;
      if (hasServerError) {
        if (route == AppRoutes.networkError) {
          return null;
        }
        return AppRoutes.networkError;
      }

      // منع الدخول المباشر لشاشة خطأ الاتصال عند عدم وجود خطأ
      if (route == AppRoutes.networkError) {
        return isAuth ? AppRoutes.main : AppRoutes.login;
      }

      // الحماية الإلزامية: لا يمكن للعميل غير المؤكد استخدام التطبيق أو تصفحه إطلاقاً
      // يُقفل الوصول إلى جميع مسارات المتجر ويُحوّل مباشرة إلى شاشة تأكيد البريد الإلكتروني
      if (requiresVerification) {
        if (route == AppRoutes.emailVerify || route == AppRoutes.login) {
          return null;
        }
        return AppRoutes.emailVerify;
      }

      if (_authFlowRoutes.contains(route)) {
        // إذا كان المستخدم موثقاً وفعالاً (وليس زائراً)، يُحوّل للرئيسية (أو تأكيد البريد إذا لم يؤكد)
        if (isAuth && !isGuest) {
          return requiresVerification ? AppRoutes.emailVerify : AppRoutes.main;
        }
      }

      if (_protectedRoutes.contains(route)) {
        // المسارات المحمية تتطلب مستخدماً موثقاً حصراً (يُمنع الزائر وغير المسجل)
        if (!isAuth || isGuest) {
          return AppRoutes.login;
        }
      }
    } catch (e, st) {
      debugPrint('[AppRouter] Route guard check failed for route $route: $e\n$st');
      // Fail-Safe (SEC-05): في حال حدوث أي خطأ في قراءة الجلسة، تُقفل المسارات المحمية فوراً
      // وتُوجّه إلى شاشة تسجيل الدخول حمايةً لبيانات المستخدم
      if (_protectedRoutes.contains(route)) {
        return AppRoutes.login;
      }
    }

    return null;
  }

  /// فحص الحراس البرمجيين للمسار (متاح للاختبارات الآلية)
  @visibleForTesting
  static String? checkRouteGuards(String route) => _checkRouteGuards(route);

  static WidgetBuilder? _resolveWidgetBuilder(String route) {
    switch (route) {
      case AppRoutes.onboarding:
        return (_) => const OnboardingScreen();
      case AppRoutes.login:
        return (_) => const LoginScreen();
      case AppRoutes.register:
        return (_) => const RegisterScreen();
      case AppRoutes.emailVerify:
        return (_) => const EmailVerificationScreen();
      case AppRoutes.twoFactorChallenge:
        return (_) => const TwoFactorChallengeScreen();
      case AppRoutes.forgot:
        return (_) => const ForgotPasswordMethodScreen();
      case AppRoutes.otp:
        return (_) => const OtpVerifyScreen();
      case AppRoutes.reset:
        return (_) => const ResetPasswordScreen();
      case AppRoutes.banned:
        return (_) => const BannedScreen();
      case AppRoutes.networkError:
        return (_) => const NetworkErrorScreen();
      case AppRoutes.home:
        return (_) => const HomeScreen();
      case AppRoutes.search:
        return (_) => const SearchScreen();
      case AppRoutes.searchResults:
        return (_) => const SearchResultsScreen();
      case AppRoutes.flashSale:
        return (_) => const FlashSaleScreen();
      case AppRoutes.product:
        return (_) => const ProductDetailsScreen();
      case AppRoutes.reviews:
        return (_) => const ReviewsScreen();
      case AppRoutes.wishlist:
        return (_) => const WishlistScreen();
      case AppRoutes.main:
        return (_) => const MainScreen();
      case AppRoutes.cart:
        return (_) => const CartScreen();
      case AppRoutes.payment:
        return (_) => const PaymentScreen();
      case AppRoutes.orderConfirmation:
        return (_) => const OrderConfirmationScreen();
      case AppRoutes.orderSuccess:
        return (_) => const OrderSuccessScreen();
      case AppRoutes.settings:
        return (_) => const SettingsScreen();
      case AppRoutes.profile:
        return (_) => const ProfileScreen();
      case AppRoutes.passwordAndSecurity:
        return (_) => const PasswordAndSecurityScreen();
      case AppRoutes.twoFactorAndPasskeys:
        return (_) => const TwoFactorAndPasskeysScreen();
      case AppRoutes.helpCenter:
        return (_) => const HelpCenterScreen();
      case AppRoutes.supportChat:
        return (_) => const SupportChatScreen();
      case AppRoutes.editProfile:
        return (_) => const EditProfileScreen();
      case AppRoutes.addresses:
        return (_) => const AddressesScreen();
      case AppRoutes.orders:
        return (_) => const OrdersScreen();
      case AppRoutes.orderDetails:
        return (_) => const OrderDetailsScreen();
      case AppRoutes.orderTracking:
        return (_) => const OrderTrackingScreen();
      case AppRoutes.listing:
        return (_) => const ProductsListingScreen();
      default:
        return null;
    }
  }
}
