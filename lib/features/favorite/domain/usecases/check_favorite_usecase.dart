// File: lib/features/favorite/domain/usecases/check_favorite_usecase.dart

import '../repositories/favorite_repository.dart';

class CheckFavoriteUseCase {
  final FavoriteRepository _repository;
  const CheckFavoriteUseCase(this._repository);

  Future<bool> execute(int hotelId) => _repository.isFavorite(hotelId);
}