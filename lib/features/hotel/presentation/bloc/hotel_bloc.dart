import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/hotel_entity.dart';
import '../../domain/usecases/get_hotel_by_id_usecase.dart';
import '../../../favorite/domain/usecases/check_favorite_usecase.dart';
import '../../../favorite/domain/usecases/toggle_favorite_usecase.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final GetHotelByIdUseCase getHotel;
  final CheckFavoriteUseCase checkFav;
  final ToggleFavoriteUseCase toggleFav;

  HotelBloc({
    required this.getHotel,
    required this.checkFav,
    required this.toggleFav,
  }) : super(HotelInitial()) {
    on<LoadHotelDetailEvent>(_onLoadHotelDetail);
    on<ToggleHotelFavoriteEvent>(_onToggleHotelFavorite);
  }

  Future<void> _onLoadHotelDetail(
    LoadHotelDetailEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final hotelTask = getHotel.execute(event.hotelId);

      bool favStatus = false;
      try {
        favStatus = await checkFav.execute(event.hotelId);
      } catch (_) {}

      final hotelData = await hotelTask;
      if (hotelData == null) {
        emit(HotelError("Không tìm thấy thông tin khách sạn."));
        return;
      }

      emit(HotelLoaded(hotel: hotelData, isFav: favStatus));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<void> _onToggleHotelFavorite(
    ToggleHotelFavoriteEvent event,
    Emitter<HotelState> emit,
  ) async {
    final currentState = state;
    final loadedState = switch (currentState) {
      HotelLoaded() => currentState,
      HotelToggleError() => HotelLoaded(
        hotel: currentState.hotel,
        isFav: currentState.isFav,
      ),
      _ => null,
    };

    if (loadedState == null) return;

    try {
      final result = await toggleFav.execute(event.hotelId);
      emit(loadedState.copyWith(isFav: result));
    } catch (e) {
      emit(
        HotelToggleError(
          hotel: loadedState.hotel,
          isFav: loadedState.isFav,
          message: e is ApiException ? e.message : e.toString(),
        ),
      );
    }
  }
}
