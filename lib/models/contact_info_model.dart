class ContactInfoModel {
  final String phone;
  final String email;

  const ContactInfoModel({
    required this.phone,
    required this.email,
  });

  bool get isEmpty => phone.trim().isEmpty && email.trim().isEmpty;

  List<String> get lines => [
        if (phone.trim().isNotEmpty) phone.trim(),
        if (email.trim().isNotEmpty) email.trim(),
      ];

  ContactInfoModel copyWith({
    String? phone,
    String? email,
  }) {
    return ContactInfoModel(
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  factory ContactInfoModel.empty() {
    return const ContactInfoModel(phone: '', email: '');
  }
}