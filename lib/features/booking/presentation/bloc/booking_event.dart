part of 'booking_bloc.dart';

abstract class BookingEvent {}

class LoadMyBookingsEvent extends BookingEvent {
  final String? status;

  LoadMyBookingsEvent({this.status});
}

class CancelBookingEvent extends BookingEvent {
  final int bookingId;
  final String reason;
  final String? currentStatusFilter;

  CancelBookingEvent(
    this.bookingId, {
    required this.reason,
    this.currentStatusFilter,
  });
}

class CreateBookingEvent extends BookingEvent {
  final int roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final double paidAmount;
  final String paymentMethod;
  final String? transactionCode;
  final String? paymentNote;
  final String note;

  CreateBookingEvent({
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    this.guestCount = 1,
    this.paidAmount = 0,
    this.paymentMethod = 'Cash',
    this.transactionCode,
    this.paymentNote,
    this.note = '',
  });
}

class LoadRoomsForHotelEvent extends BookingEvent {
  final int hotelId;
  LoadRoomsForHotelEvent(this.hotelId);
}

class LoadTimeSlotsForRoomEvent extends BookingEvent {
  final int roomId;
  LoadTimeSlotsForRoomEvent(this.roomId);
}

class UpdateBookingStatusEvent extends BookingEvent {
  final int bookingId;
  final int newStatus;
  final String? currentStatusFilter;

  UpdateBookingStatusEvent(
    this.bookingId,
    this.newStatus, {
    this.currentStatusFilter,
  });
}

