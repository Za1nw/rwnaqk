/// نموذج جلسة المستخدم النشطة المسجلة عبر الأجهزة
class UserSessionModel {
  final int id;
  final String deviceName;
  final bool isCurrent;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  const UserSessionModel({
    required this.id,
    required this.deviceName,
    required this.isCurrent,
    this.lastUsedAt,
    this.createdAt,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      deviceName: json['device_name'] as String? ?? 'جهاز غير معروف',
      isCurrent: json['is_current'] as bool? ?? false,
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.tryParse(json['last_used_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'is_current': isCurrent,
      'last_used_at': lastUsedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

