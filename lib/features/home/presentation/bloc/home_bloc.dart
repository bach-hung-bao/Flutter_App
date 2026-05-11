import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/hotel_recommendation_entity.dart';
import '../../domain/entities/province_entity.dart';
import '../../domain/usecases/get_home_recommendations_usecase.dart';
import '../../domain/usecases/get_provinces_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeRecommendationsUseCase getRecommendations;
  final GetProvincesUseCase getProvinces;
  final AuthStorage _authStorage = AuthStorage();

  HomeBloc({
    required this.getRecommendations,
    required this.getProvinces,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHotelsEvent>(_onRefreshHotels);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final session = await _authStorage.getSession();
      final provinces = await getProvinces.execute(pageSize: 8);

      final hotels = await getRecommendations.execute(
        topK: 12,
        province: null,
        accessToken: session?.accessToken,
      );

      emit(HomeLoaded(
        provinces: provinces,
        hotels: hotels,
        selectedProvince: null,
        fullName: session?.fullName ?? 'Bạn',
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHotels(
    RefreshHotelsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(HomeLoaded(
        provinces: currentState.provinces,
        hotels: currentState.hotels,
        fullName: currentState.fullName,
        isRefreshing: true,
        selectedProvince: event.province, // Update immediately for UI responsiveness
      ));

      try {
        final session = await _authStorage.getSession();
        final hotels = await getRecommendations.execute(
          topK: 12,
          province: event.province?.name,
          accessToken: session?.accessToken,
        );

        emit(HomeLoaded(
          provinces: currentState.provinces,
          hotels: hotels,
          selectedProvince: event.province,
          fullName: currentState.fullName,
          isRefreshing: false,
        ));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }
}
