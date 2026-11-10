import 'package:flutter/material.dart';

/// Global navigation and overlay keys for native Flutter routing
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Unified application navigator replacing GetX navigation.
abstract final class AppNav {
  const AppNav._();

  static GlobalKey<NavigatorState> get navigatorKey => appNavigatorKey;
  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      appScaffoldMessengerKey;

  static BuildContext? get currentContext => appNavigatorKey.currentContext;
  static BuildContext? get context => currentContext;

  static String? currentRoute;

  static OverlayState? get overlay => appNavigatorKey.currentState?.overlay;

  /// Navigate to named route.
  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return appNavigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with named route.
  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return appNavigatorKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Push named route and remove routes until predicate returns true.
  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
    Object? arguments,
  }) async {
    return appNavigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route.
  static void back<T extends Object?>([T? result]) {
    if (appNavigatorKey.currentState?.canPop() ?? false) {
      appNavigatorKey.currentState?.pop<T>(result);
    }
  }

  /// Check whether navigator can pop.
  static bool canPop() => appNavigatorKey.currentState?.canPop() ?? false;

  /// Display a modal bottom sheet using root navigator.
  static Future<T?> bottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.transparent,
    ShapeBorder? shape,
    bool enableDrag = true,
    bool isDismissible = true,
  }) {
    final context = currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: shape,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      builder: (_) => child,
    );
  }

  /// Display an alert dialog using root navigator.
  static Future<T?> dialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final context = currentContext;
    if (context == null) return Future.value(null);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }
}
