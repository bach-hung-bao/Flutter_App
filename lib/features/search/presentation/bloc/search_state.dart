import '../../../hotel/domain/entities/hotel_entity.dart';

class SearchState {
  final bool isFeaturedLoading;
  final String featuredError;
  final List<HotelEntity> featured;

  final bool isSearchLoading;
  final String searchError;
  final List<HotelEntity> searchResults;

  final String currentQuery;
  final int searchMode; // 0: name, 1: province

  const SearchState({
    this.isFeaturedLoading = true,
    this.featuredError = '',
    this.featured = const [],
    this.isSearchLoading = false,
    this.searchError = '',
    this.searchResults = const [],
    this.currentQuery = '',
    this.searchMode = 0,
  });

  SearchState copyWith({
    bool? isFeaturedLoading,
    String? featuredError,
    List<HotelEntity>? featured,
    bool? isSearchLoading,
    String? searchError,
    List<HotelEntity>? searchResults,
    String? currentQuery,
    int? searchMode,
  }) {
    return SearchState(
      isFeaturedLoading: isFeaturedLoading ?? this.isFeaturedLoading,
      featuredError: featuredError ?? this.featuredError,
      featured: featured ?? this.featured,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      searchError: searchError ?? this.searchError,
      searchResults: searchResults ?? this.searchResults,
      currentQuery: currentQuery ?? this.currentQuery,
      searchMode: searchMode ?? this.searchMode,
    );
  }
}
