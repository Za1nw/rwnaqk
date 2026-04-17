import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/two_factor_settings_service.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

class TwoFactorSettingsController extends GetxController {
  TwoFactorSettingsController(this._service);

  final TwoFactorSettingsService _service;

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final isEnabled = false.obs;
  final requiresConfirmation = false.obs;
  final hasSetupData = false.obs;

  final manualSetupKey = ''.obs;
  final setupCode = ''.obs;
  final recoveryCodes = <String>[].obs;

  String get qrCodeSvg => '';

  bool get canConfirmCode => setupCode.value.trim().length == 6;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  Future<void> loadStatus() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      final state = await _service.fetchStatus();
      _applyState(state);

      if (state.enabled) {
        recoveryCodes.assignAll(await _service.fetchRecoveryCodes());
      } else {
        recoveryCodes.clear();
      }
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enable() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;

    try {
      final state = await _service.enable();
      _applyState(state);
      setupCode.value = '';

      if (state.recoveryCodes.isNotEmpty) {
        recoveryCodes.assignAll(state.recoveryCodes);
      }

      if (state.requiresConfirmation) {
        AppNotifier.success(Tk.profileTwoFactorSetupPending);
      }
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> confirmSetup() async {
    if (isSubmitting.value || !canConfirmCode) {
      return;
    }

    isSubmitting.value = true;

    try {
      final message = await _service.confirm(code: setupCode.value);
      setupCode.value = '';
      AppNotifier.success(message, isKey: false);
      await loadStatus();
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> disable() async {
    if (isSubmitting.value) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(Tk.profileTwoFactorDisableConfirmTitle.tr),
        content: Text(Tk.profileTwoFactorDisableConfirmMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(Tk.commonCancel.tr),
          ),
          FilledButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text(Tk.commonYes.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) {
      return;
    }

    isSubmitting.value = true;

    try {
      final message = await _service.disable();
      AppNotifier.success(message, isKey: false);
      await loadStatus();
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> refreshRecoveryCodes() async {
    if (isSubmitting.value || !isEnabled.value) {
      return;
    }

    isSubmitting.value = true;

    try {
      recoveryCodes.assignAll(await _service.fetchRecoveryCodes());
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> regenerateRecoveryCodes() async {
    if (isSubmitting.value || !isEnabled.value) {
      return;
    }

    isSubmitting.value = true;

    try {
      recoveryCodes.assignAll(await _service.regenerateRecoveryCodes());
      AppNotifier.success(Tk.commonDone);
    } catch (error) {
      AppNotifier.errorFrom(error);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> copyAllRecoveryCodes() async {
    if (recoveryCodes.isEmpty) {
      return;
    }

    final content = recoveryCodes.join('\n');
    await Clipboard.setData(ClipboardData(text: content));
    AppNotifier.success(Tk.commonCopied);
  }

  Future<void> copyRecoveryCode(String code) async {
    final value = code.trim();
    if (value.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    AppNotifier.success(Tk.commonCopied);
  }

  void onCodeChanged(String value) {
    setupCode.value = value.replaceAll(RegExp('[^0-9]'), '').trim();
  }

  Future<void> copyManualSetupKey() async {
    final key = manualSetupKey.value.trim();
    if (key.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: key));
    AppNotifier.success(Tk.commonCopied);
  }

  void _applyState(TwoFactorSettingsState state) {
    isEnabled.value = state.enabled;
    requiresConfirmation.value = state.requiresConfirmation;
    hasSetupData.value = state.hasSetupData;
    manualSetupKey.value = state.manualSetupKey?.trim() ?? '';
  }
}
