import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetFavoritesUseCase getFavorites;
  final ToggleFavoriteUseCase toggleFavorite;

  FavoriteBloc({
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(FavoriteInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteInListEvent>(_onToggleFavoriteInList);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      final favorites = await getFavorites.execute();
      emit(FavoriteLoaded(favorites));
    } catch (e) {
      final isAuthError =
          e is ApiException && (e.statusCode == 401 || e.statusCode == 403);
      emit(FavoriteError(e.toString(), isAuthError: isAuthError));
    }
  }

  Future<void> _onToggleFavoriteInList(
      ToggleFavoriteInListEvent event, Emitter<FavoriteState> emit) async {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      // 1. Optimistic update (Xoá tạm trên UI trước cho mượt)
      final previousFavorites = List.of(currentState.favorites);
      final updatedFavorites =
          previousFavorites.where((h) => h.id != event.hotelId).toList();
      emit(FavoriteLoaded(updatedFavorites));

      try {
        // 2. Gọi API thực tế
        await toggleFavorite.execute(event.hotelId);
      } catch (e) {
        // 3. Nếu API lỗi -> Phải emit Error TRƯỚC để kích hoạt Snackbar
        emit(FavoriteError('Không thể bỏ yêu thích, vui lòng kiểm tra kết nối!'));
        // 4. Bắt buộc emit Loaded SAU CÙNG để UI rollback hiển thị lại List, không bị trắng màn
        emit(FavoriteLoaded(previousFavorites));
      }
    }
  }
}