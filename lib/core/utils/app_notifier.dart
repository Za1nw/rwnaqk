import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/api_error_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';

export 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';

/// المنسق العام لإشعارات وتنبيهات التطبيق الموحدة
/// يوجه كافة التنبيهات إلى نظام الإشعارات الملكي الخاص بتطبيق "رَوْنَقُك"
class AppNotifier {
  const AppNotifier._();

  /// إشعار نجاح ملكي
  static void success(
    String messageKeyOrText, {
    bool isKey = true,
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    RawnaqkToast.success(
      isKey ? messageKeyOrText.tr : messageKeyOrText,
      title: title ?? Tk.commonSuccess.tr,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// إشعار خطأ / تنبيه حرج
  static void error(
    String messageKeyOrText, {
    bool isKey = true,
    String? title,
    Duration duration = const Duration(milliseconds: 3800),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    RawnaqkToast.error(
      isKey ? messageKeyOrText.tr : messageKeyOrText,
      title: title ?? Tk.commonError.tr,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// إشعار تحذير ذهبي
  static void warning(
    String messageKeyOrText, {
    bool isKey = true,
    String? title,
    Duration duration = const Duration(milliseconds: 3400),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    RawnaqkToast.warning(
      isKey ? messageKeyOrText.tr : messageKeyOrText,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// إشعار معلومة من رَوْنَقُك
  static void info(
    String messageKeyOrText, {
    bool isKey = true,
    String? title,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    RawnaqkToast.info(
      isKey ? messageKeyOrText.tr : messageKeyOrText,
      title: title,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// إشعار نسخ للحافظة
  static void copied({String? message, String? title}) {
    RawnaqkToast.copied(message: message, title: title);
  }

  /// معالجة استثناءات الـ API وتحويلها لتنبيه خطأ ملكي
  static void errorFrom(Object exception) {
    AppNotifier.error(ApiErrorUtils.toLocaleKey(exception));
  }
}
