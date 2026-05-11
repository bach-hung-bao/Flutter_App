part of 'hotel_bloc.dart';

abstract class HotelState {}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final HotelEntity hotel;
  final bool isFav;

  HotelLoaded({required this.hotel, required this.isFav});

  HotelLoaded copyWith({HotelEntity? hotel, bool? isFav}) {
    return HotelLoaded(hotel: hotel ?? this.hotel, isFav: isFav ?? this.isFav);
  }
}

class HotelError extends HotelState {
  final String message;

  HotelError(this.message);
}

class HotelToggleError extends HotelState {
  final HotelEntity hotel;
  final bool isFav;
  final String message;

  HotelToggleError({
    required this.hotel,
    required this.isFav,
    required this.message,
  });
}
