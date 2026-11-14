import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/utils/app_validators.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_input_field.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/edit_profile/editable_avatar_badge.dart';

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

  String? _selectedGender;
  String _avatarPath = '';
  String _avatarUrl = '';
  bool _isUploadingAvatar = false;
  bool _isSaving = false;
  bool _isSuccess = false;

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
    _avatarUrl = customer?.avatarUrl ?? '';
    _selectedGender = customer?.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  bool get _isBusy => _isUploadingAvatar || _isSaving || _isSuccess;

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

    final phoneError = AppValidators.phone(mobile);
    if (phoneError != null) {
      AppToast.warning(phoneError, title: Tk.commonError.tr);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final session = ref.read(authSessionProvider);
      final isRealAuth =
          session.isAuthenticated && (session.token?.isNotEmpty == true);

      if (isRealAuth) {
        final parts = name.split(' ');
        final firstName = parts.first;
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        final authRepo = ref.read(authRepositoryProvider);
        final updatedCustomer = await authRepo.updateProfile(
          firstName: firstName,
          lastName: lastName,
          name: name,
          email: email,
          mobile: mobile,
          gender: _selectedGender,
          avatarFilePath: _avatarPath.isNotEmpty ? _avatarPath : null,
        );

        ref.read(authSessionProvider.notifier).setCustomer(updatedCustomer);
      } else {
        ref.read(authSessionProvider.notifier).updateCustomer((current) {
          if (current == null) {
            return CustomerModel(
              id: 1,
              firstName: name,
              fullName: name,
              email: email,
              mobile: mobile,
              gender: _selectedGender,
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
            gender: _selectedGender ?? current.gender,
          );
        });
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSaving = false;
          _isSuccess = true;
        });
      }

      await Future<void>.delayed(const Duration(milliseconds: 950));
      if (mounted) {
        AppNav.back();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSuccess = false;
        });
        AppNotifier.errorFrom(e);
      }
    }
  }

  Widget _buildGenderSelector(BuildContext context, bool isDark) {
    final selected = _selectedGender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.wc_rounded,
              size: 16,
              color: context.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              'الجنس',
              style: AppTextTheme.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // ذكر
            Expanded(
              child: _buildGenderOptionTile(
                context,
                label: 'ذكر',
                subtitle: 'Male',
                icon: Icons.male_rounded,
                isSelected: selected == 'male' || selected == 'ذكر',
                isDark: isDark,
                onTap: () {
                  setState(() => _selectedGender = 'male');
                },
              ),
            ),
            const SizedBox(width: 10),
            // أنثى
            Expanded(
              child: _buildGenderOptionTile(
                context,
                label: 'أنثى',
                subtitle: 'Female',
                icon: Icons.female_rounded,
                isSelected: selected == 'female' || selected == 'أنثى',
                isDark: isDark,
                onTap: () {
                  setState(() => _selectedGender = 'female');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOptionTile(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeColor = context.primary;
    final borderColor = isSelected
        ? activeColor
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final bgColor = isSelected
        ? activeColor.withValues(alpha: isDark ? 0.22 : 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.03)
            : context.muted.withValues(alpha: 0.25));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: isDark ? 0.3 : 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.4)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 0.8,
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color: isSelected ? activeColor : context.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextTheme.cairo(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? activeColor : context.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextTheme.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.8)
                          : context.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: context.primaryForeground,
                ),
              ),
          ],
        ),
      ),
    );
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(anim),
                child: child,
              ),
            ),
            child: _isSuccess
                ? Container(
                    key: const ValueKey('save_success_btn'),
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.successDark : AppColors.success,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.successDark
                                  : AppColors.success)
                              .withValues(alpha: isDark ? 0.45 : 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) => Transform.scale(
                            scale: val,
                            child: child,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تم الحفظ بنجاح',
                          style: AppTextTheme.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : AppButton(
                    key: const ValueKey('save_action_btn'),
                    text: _isSaving
                        ? 'جاري الحفظ...'
                        : Tk.profileEditSaveChanges.tr,
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _isSaving,
                    height: 50,
                    borderRadius: 15,
                    onPressed: _isBusy ? null : _save,
                  ),
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
                        const SizedBox(height: 14),
                        _buildGenderSelector(context, isDark),
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
