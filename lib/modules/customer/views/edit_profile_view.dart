import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_saved_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/edit_profile/editable_avatar_badge.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة تعديل الملف الشخصي الفاخرة للعميل (Edit Profile Screen) بتقنية Riverpod
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;

  String _avatarPath = '';
  String _avatarUrl = '';
  bool _isUploadingAvatar = false;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final customer = ref.read(currentCustomerProvider);
    final initialName = (customer?.fullName?.isNotEmpty == true)
        ? customer!.fullName!
        : ((customer?.firstName?.isNotEmpty == true)
            ? customer!.firstName!
            : (customer?.displayName ?? ''));
    final initialEmail = customer?.email ?? '';
    final initialMobile = customer?.mobile ?? '';

    _nameCtrl = TextEditingController(text: initialName);
    _emailCtrl = TextEditingController(text: initialEmail);
    _mobileCtrl = TextEditingController(text: initialMobile);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  bool get _isBusy => _isUploadingAvatar || _isSaving;

  Future<void> _pickAvatar(ImageSource source) async {
    if (_isBusy) return;
    setState(() => _isUploadingAvatar = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        imageQuality: 88,
      );
      if (file == null) {
        setState(() => _isUploadingAvatar = false);
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final dotIndex = file.path.lastIndexOf('.');
      final ext = dotIndex != -1 ? file.path.substring(dotIndex).toLowerCase() : '.jpg';
      final targetPath =
          '${directory.path}${Platform.pathSeparator}profile_avatar$ext';
      final targetFile = File(targetPath);

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      final copied = await File(file.path).copy(targetPath);
      if (mounted) {
        setState(() {
          _avatarPath = copied.path;
          _avatarUrl = '';
          _isUploadingAvatar = false;
        });
        AppToast.success(Tk.profileEditPhotoUpdated.tr, title: Tk.commonDone.tr);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        AppToast.error(
          Tk.profileEditPhotoPickFailed.tr,
          title: Tk.commonError.tr,
        );
      }
    }
  }

  Future<void> _save() async {
    if (_isBusy) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty) {
      AppToast.warning(Tk.profileEditFillAll.tr, title: Tk.commonError.tr);
      return;
    }

    setState(() => _isSaving = true);
    try {
      ref.read(authSessionProvider.notifier).updateCustomer((current) {
        if (current == null) {
          return CustomerModel(
            id: 1,
            firstName: name,
            fullName: name,
            email: email,
            mobile: mobile,
          );
        }
        return current.copyWith(
          firstName: name.split(' ').first,
          lastName: name.split(' ').length > 1
              ? name.split(' ').sublist(1).join(' ')
              : current.lastName,
          fullName: name,
          email: email,
          mobile: mobile,
        );
      });

      await AppSavedDialog.show(messageKey: Tk.profileEditUpdated);
      if (mounted) {
        AppNav.back();
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(Tk.commonUnexpectedError.tr, title: Tk.commonError.tr);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _goToForgotPassword() {
    AppNav.toNamed(AppRoutes.forgot);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 14),
          child: AppButton(
            text: _isSaving
                ? 'جاري الحفظ...'
                : Tk.profileEditSaveChanges.tr,
            icon: Icons.check_circle_outline_rounded,
            isLoading: _isSaving,
            onPressed: _isBusy ? null : _save,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ترويسة الصفحة مع زر الرجوع
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _TopCircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'الرجوع',
                    onTap: AppNav.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tk.profileEditTitle.tr,
                          style: AppTextTheme.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          Tk.profileEditSubtitle.tr,
                          style: AppTextTheme.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // محتوى الحقول القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصورة الشخصية القابلة للتعديل
                    const SizedBox(height: 10),
                    EditableAvatarBadge(
                      name: _nameCtrl.text,
                      avatarPath: _avatarPath,
                      avatarUrl: _avatarUrl,
                      isUploading: _isUploadingAvatar,
                      onPickImage: _pickAvatar,
                    ),
                    const SizedBox(height: 24),

                    // بطاقة المعلومات الأساسية
                    _FormCard(
                      title: 'البيانات الشخصية',
                      icon: Icons.person_outline_rounded,
                      children: [
                        AppInputField(
                          controller: _nameCtrl,
                          label: Tk.profileEditName.tr,
                          hint: Tk.profileEditNameHint.tr,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: _emailCtrl,
                          label: Tk.profileEditEmail.tr,
                          hint: Tk.profileEditEmailHint.tr,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          controller: _mobileCtrl,
                          label: Tk.profileEditMobile.tr,
                          hint: Tk.registerPhoneHint.tr,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // بطاقة الأمان وكلمة المرور
                    _FormCard(
                      title: 'الأمان وكلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        Text(
                          'لحماية حسابك، نوصي باستخدام كلمة مرور قوية تحتوي على أرقام ورموز خاصة.',
                          style: AppTextTheme.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _goToForgotPassword,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? BrandColors.gold.withValues(alpha: 0.1)
                                    : BrandColors.burgundy.withValues(
                                        alpha: 0.05,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? BrandColors.gold.withValues(alpha: 0.25)
                                      : BrandColors.burgundy.withValues(
                                          alpha: 0.12,
                                        ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.key_rounded,
                                    size: 18,
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      Tk.profileEditChangePassword.tr,
                                      style: AppTextTheme.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : BrandColors.burgundy,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_left_rounded,
                                    size: 20,
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة احتواء وتجميع حقول الإدخال
class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.18)
              : BrandColors.burgundy.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextTheme.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.25)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
        ),
      ),
    );
  }
}
