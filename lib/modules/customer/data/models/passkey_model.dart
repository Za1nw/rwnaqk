/// نموذج مفتاح المرور Passkey المسجل عبر البصمة أو قفل الهاتف
class PasskeyModel {
  final int id;
  final String name;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  const PasskeyModel({
    required this.id,
    required this.name,
    this.lastUsedAt,
    this.createdAt,
  });

  factory PasskeyModel.fromJson(Map<String, dynamic> json) {
    return PasskeyModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'مفتاح مرور',
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
      'name': name,
      'last_used_at': lastUsedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

