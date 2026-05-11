part of 'hotel_bloc.dart';

abstract class HotelEvent {}

class LoadHotelDetailEvent extends HotelEvent {
  final int hotelId;

  LoadHotelDetailEvent(this.hotelId);
}

class ToggleHotelFavoriteEvent extends HotelEvent {
  final int hotelId;

  ToggleHotelFavoriteEvent(this.hotelId);
}
