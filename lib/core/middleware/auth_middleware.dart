import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';

/// Route guard middleware ensuring user authentication.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.priorityValue = 0});

  final int priorityValue;

  @override
  int? get priority => priorityValue;

  @override
  RouteSettings? redirect(String? route) {
    if (!_hasAuthenticatedSession()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  GuestMiddleware({this.priorityValue = 0});

  final int priorityValue;

  @override
  int? get priority => priorityValue;

  @override
  RouteSettings? redirect(String? route) {
    if (_hasAuthenticatedSession()) {
      return const RouteSettings(name: AppRoutes.main);
    }

    return null;
  }
}

bool _hasAuthenticatedSession() {
  if (!Get.isRegistered<AuthSessionService>()) {
    return false;
  }

  return Get.find<AuthSessionService>().isAuthenticated;
}
