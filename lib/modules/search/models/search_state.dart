import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// الحالة غير القابلة للتعديل لمنظومة البحث [SearchState]
@immutable
class SearchState {
  const SearchState({
    this.history = const [],
    this.recommendations = const [],
    this.discover = const [],
    this.results = const [],
    this.query = '',
    this.isLoading = false,
    this.searchSequence = 0,
    this.activeFilters = 0,
    this.errorMessage,
    this.hasSearched = false,
  });

  final List<String> history;
  final List<String> recommendations;
  final List<HomeProductItem> discover;
  final List<HomeProductItem> results;
  final String query;
  final bool isLoading;
  final int searchSequence;
  final int activeFilters;
  final String? errorMessage;
  final bool hasSearched;

  factory SearchState.initial() {
    return const SearchState(
      history: [],
      recommendations: [],
      discover: [],
      results: [],
      query: '',
      isLoading: false,
      searchSequence: 0,
      activeFilters: 0,
      errorMessage: null,
      hasSearched: false,
    );
  }

  SearchState copyWith({
    List<String>? history,
    List<String>? recommendations,
    List<HomeProductItem>? discover,
    List<HomeProductItem>? results,
    String? query,
    bool? isLoading,
    int? searchSequence,
    int? activeFilters,
    String? Function()? errorMessage,
    bool? hasSearched,
  }) {
    return SearchState(
      history: history ?? this.history,
      recommendations: recommendations ?? this.recommendations,
      discover: discover ?? this.discover,
      results: results ?? this.results,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      searchSequence: searchSequence ?? this.searchSequence,
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchState &&
        listEquals(other.history, history) &&
        listEquals(other.recommendations, recommendations) &&
        listEquals(other.discover, discover) &&
        listEquals(other.results, results) &&
        other.query == query &&
        other.isLoading == isLoading &&
        other.searchSequence == searchSequence &&
        other.activeFilters == activeFilters &&
        other.errorMessage == errorMessage &&
        other.hasSearched == hasSearched;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(history),
        Object.hashAll(recommendations),
        Object.hashAll(discover),
        Object.hashAll(results),
        query,
        isLoading,
        searchSequence,
        activeFilters,
        errorMessage,
        hasSearched,
      );
}

