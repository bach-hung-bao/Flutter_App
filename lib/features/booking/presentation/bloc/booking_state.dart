part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class MyBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;
  final int totalCount;
  final String? statusFilter;
  final bool isCancelling;

  MyBookingsLoaded({
    required this.bookings,
    required this.totalCount,
    this.statusFilter,
    this.isCancelling = false,
  });

  MyBookingsLoaded copyWith({
    List<BookingEntity>? bookings,
    int? totalCount,
    String? statusFilter,
    bool? isCancelling,
  }) {
    return MyBookingsLoaded(
      bookings: bookings ?? this.bookings,
      totalCount: totalCount ?? this.totalCount,
      statusFilter: statusFilter ?? this.statusFilter, // Keep old filter if null is passed here, but usually it's fine.
      isCancelling: isCancelling ?? this.isCancelling,
    );
  }
}

class BookingActionLoading extends BookingState {}

class BookingCreatedSuccess extends BookingState {}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}

class RoomsLoaded extends BookingState {
  final List<RoomEntity> rooms;
  RoomsLoaded(this.rooms);
}

class TimeSlotsLoaded extends BookingState {
  final List<TimeSlotEntity> timeSlots;
  TimeSlotsLoaded(this.timeSlots);
}
