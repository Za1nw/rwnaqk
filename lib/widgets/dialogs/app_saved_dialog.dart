import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/dialogs/app_dialog_shell.dart';

class AppSavedDialog extends StatelessWidget {
  final String titleKey;
  final String messageKey;

  const AppSavedDialog({
    super.key,
    this.titleKey = Tk.commonSaved,
    required this.messageKey,
  });

  static Future<T?> show<T>({
    String titleKey = Tk.commonSaved,
    required String messageKey,
  }) {
    return Get.dialog<T>(
      AppSavedDialog(
        titleKey: titleKey,
        messageKey: messageKey,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: titleKey,
      subtitle: messageKey,
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary.withOpacity(.10),
              border: Border.all(
                color: context.primary.withOpacity(.18),
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              color: context.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: Tk.commonOk.tr,
            onPressed: () => Get.back<void>(),
          ),
        ],
      ),
    );
  }
}
