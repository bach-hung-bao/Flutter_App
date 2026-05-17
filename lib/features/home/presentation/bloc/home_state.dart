part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProvinceEntity> provinces;
  final List<HotelRecommendationEntity> hotels;
  final ProvinceEntity? selectedProvince;
  final String fullName;
  final bool isRefreshing;
  final int pageIndex;
  final bool hasReachedMax;
  final bool isFetchingMore;

  HomeLoaded({
    required this.provinces,
    required this.hotels,
    this.selectedProvince,
    required this.fullName,
    this.isRefreshing = false,
    this.pageIndex = 1,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  HomeLoaded copyWith({
    List<ProvinceEntity>? provinces,
    List<HotelRecommendationEntity>? hotels,
    ProvinceEntity? selectedProvince,
    String? fullName,
    bool? isRefreshing,
    int? pageIndex,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return HomeLoaded(
      provinces: provinces ?? this.provinces,
      hotels: hotels ?? this.hotels,
      selectedProvince: selectedProvince, 
      fullName: fullName ?? this.fullName,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      pageIndex: pageIndex ?? this.pageIndex,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
