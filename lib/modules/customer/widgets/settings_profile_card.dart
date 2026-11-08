import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';

export 'package:rwnaqk_frontend/modules/customer/widgets/settings/settings_user_header.dart';

/// بطاقة الترويسة الفاخرة للعميل (اسم بديل للتوافق)
class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarPath;
  final String? avatarUrl;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.phone,
    this.avatarPath,
    this.avatarUrl,
    required this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsUserHeader(
      name: name,
      phone: phone,
      avatarPath: avatarPath,
      avatarUrl: avatarUrl,
      onEdit: onEdit,
      onTap: onTap,
    );
  }
}
