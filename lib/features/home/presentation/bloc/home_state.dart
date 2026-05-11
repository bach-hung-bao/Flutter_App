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

  HomeLoaded({
    required this.provinces,
    required this.hotels,
    this.selectedProvince,
    required this.fullName,
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    List<ProvinceEntity>? provinces,
    List<HotelRecommendationEntity>? hotels,
    ProvinceEntity? selectedProvince,
    String? fullName,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      provinces: provinces ?? this.provinces,
      hotels: hotels ?? this.hotels,
      selectedProvince: selectedProvince, // Need to handle null explicitly if needed, but for our case it's fine.
      fullName: fullName ?? this.fullName,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
