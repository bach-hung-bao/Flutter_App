import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_my_bookings_usecase.dart';
import '../../domain/usecases/get_rooms_usecase.dart';
import '../../domain/usecases/get_time_slots_usecase.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/time_slot_entity.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetMyBookingsUseCase getMyBookings;
  final CancelBookingUseCase cancelBooking;
  final CreateBookingUseCase createBooking;
  final GetRoomsByHotelIdUseCase getRoomsByHotel;
  final GetTimeSlotsByRoomIdUseCase getTimeSlotsByRoom;

  BookingBloc({
    required this.getMyBookings,
    required this.cancelBooking,
    required this.createBooking,
    required this.getRoomsByHotel,
    required this.getTimeSlotsByRoom,
  }) : super(BookingInitial()) {
    on<LoadMyBookingsEvent>(_onLoadMyBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadRoomsForHotelEvent>(_onLoadRoomsForHotel);
    on<LoadTimeSlotsForRoomEvent>(_onLoadTimeSlotsForRoom);
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final (bookings, count) = await getMyBookings.execute(
        pageIndex: 1,
        pageSize: 50,
      );
      emit(
        MyBookingsLoaded(
          bookings: bookings,
          totalCount: count,
          statusFilter: event.status,
        ),
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    if (currentState is MyBookingsLoaded) {
      emit(currentState.copyWith(isCancelling: true));
      try {
        final result = await cancelBooking.execute(
          event.bookingId,
          event.reason,
        );
        if (result != null) {
          // Reload the list
          final (bookings, count) = await getMyBookings.execute(
            pageIndex: 1,
            pageSize: 50,
          );
          emit(
            MyBookingsLoaded(
              bookings: bookings,
              totalCount: count,
              statusFilter: event.currentStatusFilter,
              isCancelling: false,
            ),
          );
        } else {
          emit(BookingError("Không thể hủy đặt phòng. Vui lòng thử lại."));
          emit(currentState.copyWith(isCancelling: false));
        }
      } catch (e) {
        emit(BookingError(e.toString()));
        emit(currentState.copyWith(isCancelling: false));
      }
    }
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingActionLoading());
    try {
      await createBooking.execute(
        roomId: event.roomId,
        checkInDate: event.checkInDate,
        checkOutDate: event.checkOutDate,
        guestCount: event.guestCount,
        paidAmount: event.paidAmount,
        paymentMethod: event.paymentMethod,
        transactionCode: event.transactionCode,
        paymentNote: event.paymentNote,
        note: event.note,
      );
      emit(BookingCreatedSuccess());
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadRoomsForHotel(
    LoadRoomsForHotelEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final rooms = await getRoomsByHotel.execute(event.hotelId);
      emit(RoomsLoaded(rooms));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadTimeSlotsForRoom(
    LoadTimeSlotsForRoomEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final timeSlots = await getTimeSlotsByRoom.execute(event.roomId);
      emit(TimeSlotsLoaded(timeSlots));
    } catch (e) {
      emit(TimeSlotsLoaded(const []));
    }
  }
}
