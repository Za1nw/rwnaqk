import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/two_factor_settings_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class ProfileTwoFactorSection extends GetView<TwoFactorSettingsController> {
  const ProfileTwoFactorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = controller.isEnabled.value;
      final busy = controller.isLoading.value || controller.isSubmitting.value;
      final canShowSetup = controller.hasSetupData.value && !enabled;
      final setupKey = controller.manualSetupKey.value;
      final recoveryCodes = controller.recoveryCodes;

      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border.withOpacity(.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.primary.withOpacity(.18)),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Tk.profileTwoFactorTitle.tr,
                        style: TextStyle(
                          color: context.foreground,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Tk.profileTwoFactorSubtitle.tr,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: enabled
                        ? context.success.withOpacity(.12)
                        : context.destructive.withOpacity(.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    enabled
                        ? Tk.profileTwoFactorEnabled.tr
                        : Tk.profileTwoFactorDisabled.tr,
                    style: TextStyle(
                      color: enabled ? context.success : context.destructive,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (canShowSetup) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: context.input,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border.withOpacity(.45)),
                ),
                child: Text(
                  Tk.profileTwoFactorSetupPending.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (setupKey.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Tk.profileTwoFactorManualKey.tr,
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            setupKey,
                            style: TextStyle(
                              color: context.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: busy ? null : controller.copyManualSetupKey,
                      icon: Icon(Icons.copy_rounded, color: context.primary),
                      tooltip: Tk.commonCopy.tr,
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              TextField(
                enabled: !busy,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: controller.onCodeChanged,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: Tk.profileTwoFactorCodeLabel.tr,
                  hintText: Tk.profileTwoFactorCodeHint.tr,
                  filled: true,
                  fillColor: context.input,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy || !controller.canConfirmCode
                      ? null
                      : controller.confirmSetup,
                  child: Text(Tk.profileTwoFactorConfirm.tr),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : enabled
                        ? controller.disable
                        : controller.enable,
                    icon: Icon(
                      enabled ? Icons.shield_outlined : Icons.shield_rounded,
                      size: 18,
                    ),
                    label: Text(
                      enabled
                          ? Tk.profileTwoFactorDisable.tr
                          : (canShowSetup
                                ? Tk.profileTwoFactorContinueSetup.tr
                                : Tk.profileTwoFactorEnable.tr),
                    ),
                  ),
                ),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Tk.profileTwoFactorRecoveryCodes.tr,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: busy ? null : controller.refreshRecoveryCodes,
                    tooltip: Tk.profileTwoFactorRefreshCodes.tr,
                    icon: Icon(Icons.refresh_rounded, color: context.primary),
                  ),
                  IconButton(
                    onPressed: busy ? null : controller.regenerateRecoveryCodes,
                    tooltip: Tk.profileTwoFactorRegenerateCodes.tr,
                    icon: Icon(
                      Icons.restart_alt_rounded,
                      color: context.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: busy ? null : controller.copyAllRecoveryCodes,
                    tooltip: Tk.commonCopy.tr,
                    icon: Icon(Icons.copy_all_rounded, color: context.primary),
                  ),
                ],
              ),
              if (recoveryCodes.isEmpty)
                Text(
                  Tk.profileTwoFactorNoRecoveryCodes.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recoveryCodes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, index) {
                    final code = recoveryCodes[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.input,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.border.withOpacity(.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              code,
                              maxLines: 1,
                              style: TextStyle(
                                color: context.foreground,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: busy
                                ? null
                                : () => controller.copyRecoveryCode(code),
                            tooltip: Tk.commonCopy.tr,
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: context.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      );
    });
  }
}
