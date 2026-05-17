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
    on<LoadMoreHotelsEvent>(_onLoadMoreHotels);
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
        pageIndex: 1,
        province: null,
        accessToken: session?.accessToken,
      );

      emit(HomeLoaded(
        provinces: provinces,
        hotels: hotels,
        selectedProvince: null,
        fullName: session?.fullName ?? 'Bạn',
        pageIndex: 1,
        hasReachedMax: hotels.length < 12,
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
      emit(currentState.copyWith(
        isRefreshing: true,
        selectedProvince: event.province, // Update immediately for UI responsiveness
      ));

      try {
        final session = await _authStorage.getSession();
        final hotels = await getRecommendations.execute(
          topK: 12,
          pageIndex: 1,
          province: event.province?.name,
          accessToken: session?.accessToken,
        );

        emit(currentState.copyWith(
          hotels: hotels,
          selectedProvince: event.province,
          isRefreshing: false,
          pageIndex: 1,
          hasReachedMax: hotels.length < 12,
        ));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMoreHotels(
    LoadMoreHotelsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded && !currentState.hasReachedMax && !currentState.isFetchingMore) {
      emit(currentState.copyWith(isFetchingMore: true));
      try {
        final session = await _authStorage.getSession();
        final nextPage = currentState.pageIndex + 1;
        final newHotels = await getRecommendations.execute(
          topK: 12,
          pageIndex: nextPage,
          province: currentState.selectedProvince?.name,
          accessToken: session?.accessToken,
        );

        if (newHotels.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isFetchingMore: false));
        } else {
          emit(currentState.copyWith(
            hotels: List.of(currentState.hotels)..addAll(newHotels),
            pageIndex: nextPage,
            hasReachedMax: newHotels.length < 12,
            isFetchingMore: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(isFetchingMore: false));
      }
    }
  }
}
