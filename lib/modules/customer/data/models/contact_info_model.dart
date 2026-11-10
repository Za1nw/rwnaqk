class ContactInfoModel {
  final String? name;
  final String phone;
  final String email;

  const ContactInfoModel({this.name, required this.phone, required this.email});

  bool get isEmpty => phone.trim().isEmpty && email.trim().isEmpty;

  List<String> get lines => [
    if (name != null && name!.trim().isNotEmpty) name!.trim(),
    if (phone.trim().isNotEmpty) phone.trim(),
    if (email.trim().isNotEmpty) email.trim(),
  ];

  ContactInfoModel copyWith({String? name, String? phone, String? email}) {
    return ContactInfoModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  factory ContactInfoModel.empty() {
    return const ContactInfoModel(name: '', phone: '', email: '');
  }
}
