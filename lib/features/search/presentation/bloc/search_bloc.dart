import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/search_usecases.dart';
import '../../../hotel/domain/entities/hotel_entity.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetFeaturedHotelsUseCase getFeaturedHotels;
  final SearchHotelsByNameUseCase searchHotelsByName;
  final SearchHotelsByProvinceUseCase searchHotelsByProvince;

  SearchBloc({
    required this.getFeaturedHotels,
    required this.searchHotelsByName,
    required this.searchHotelsByProvince,
  }) : super(const SearchState()) {
    on<LoadFeaturedHotelsEvent>(_onLoadFeatured);
    on<SearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onLoadFeatured(
      LoadFeaturedHotelsEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(isFeaturedLoading: true, featuredError: ''));
    try {
      final items = await getFeaturedHotels.execute(pageSize: event.pageSize);
      emit(state.copyWith(
        featured: items,
        isFeaturedLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isFeaturedLoading: false,
        featuredError: e.toString(),
      ));
    }
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChangedEvent event, Emitter<SearchState> emit) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(state.copyWith(
        currentQuery: '',
        searchResults: [],
        searchError: '',
        isSearchLoading: false,
        searchMode: event.searchMode,
      ));
      return;
    }

    emit(state.copyWith(
      currentQuery: query,
      isSearchLoading: true,
      searchError: '',
      searchMode: event.searchMode,
      // Hiển thị kết quả filter tạm thời từ danh sách featured
      searchResults: _filterFeatured(query),
    ));

    try {
      final List<HotelEntity> items;
      if (event.searchMode == 0) {
        items = await searchHotelsByName.execute(query);
      } else {
        items = await searchHotelsByProvince.execute(query);
      }

      final merged = items.isNotEmpty ? items : _filterFeatured(query);
      emit(state.copyWith(
        isSearchLoading: false,
        searchResults: merged,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearchLoading: false,
        searchError: e.toString().contains('404')
            ? 'Không tìm thấy kết quả.'
            : 'Có lỗi xảy ra: $e',
      ));
    }
  }

  List<HotelEntity> _filterFeatured(String query) {
    final normalized = query.toLowerCase();
    if (normalized.isEmpty) return [];
    return state.featured.where((h) {
      final name = h.name.toLowerCase();
      return name.startsWith(normalized) || name.contains(normalized);
    }).toList();
  }
}
