import 'package:rwnaqk_frontend/modules/support/controllers/help_center_service.dart';

/// نموذج الحالة غير القابل للتعديل لشاشة مركز المساعدة [HelpCenterScreen].
class HelpCenterState {
  final String searchQuery;
  final String selectedCategory;
  final List<HelpCenterEntry> supportEntries;
  final List<HelpCenterContactEntry> contactEntries;
  final List<String> faqQuestions;

  const HelpCenterState({
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.supportEntries = const [],
    this.contactEntries = const [],
    this.faqQuestions = const [],
  });

  /// تصفية الأسئلة الشائعة بناءً على كلمة البحث الحالية.
  List<String> get filteredFaqQuestions {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return faqQuestions;
    }
    return faqQuestions.where((question) => question.toLowerCase().contains(query)).toList();
  }

  /// هل نتيجة البحث فارغة؟
  bool get isSearchEmpty => searchQuery.trim().isNotEmpty && filteredFaqQuestions.isEmpty;

  HelpCenterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    List<HelpCenterEntry>? supportEntries,
    List<HelpCenterContactEntry>? contactEntries,
    List<String>? faqQuestions,
  }) {
    return HelpCenterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      supportEntries: supportEntries ?? this.supportEntries,
      contactEntries: contactEntries ?? this.contactEntries,
      faqQuestions: faqQuestions ?? this.faqQuestions,
    );
  }
}

