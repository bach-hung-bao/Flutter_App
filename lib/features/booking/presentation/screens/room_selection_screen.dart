import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection.dart' as di;
import '../bloc/booking_bloc.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import 'payment_screen.dart';
import 'package:intl/intl.dart';

class RoomSelectionScreen extends StatelessWidget {
  final int hotelId;
  final String hotelName;

  const RoomSelectionScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>()..add(LoadRoomsForHotelEvent(hotelId)),
      child: _RoomSelectionScreenContent(
        hotelId: hotelId,
        hotelName: hotelName,
      ),
    );
  }
}

class _RoomSelectionScreenContent extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const _RoomSelectionScreenContent({
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<_RoomSelectionScreenContent> createState() =>
      _RoomSelectionScreenContentState();
}

class _RoomSelectionScreenContentState
    extends State<_RoomSelectionScreenContent> {
  int _selectedCategory = 0; // 0: Tat ca, 1: VIP, 2: Thuong

  bool _isVipRoom(RoomEntity room) {
    final typeName = (room.roomTypeName ?? '').toLowerCase();
    final roomNo = (room.roomNumber ?? '').toLowerCase();
    final isDlx = typeName.contains('dlx') || typeName.contains('deluxe');
    final isStd = typeName.contains('std') || typeName.contains('standard');
    if (roomNo.contains('dlx')) return true;
    if (roomNo.contains('std')) return false;
    if (isDlx) return true;
    if (isStd) return false;
    return false;
  }

  void _showCalendar(RoomEntity room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider(
          create: (_) =>
              di.sl<BookingBloc>()..add(LoadTimeSlotsForRoomEvent(room.id)),
          child: _CalendarBottomSheet(room: room, hotelName: widget.hotelName),
        );
      },
    );
  }

  Widget _buildRoomItem(RoomEntity room) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenPrimary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phòng ${room.roomNumber ?? 'N/A'}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2B24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.roomTypeName ?? 'Loại: ${room.roomTypeId}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.greenPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: Color(0xFF6B8070),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sức chứa: ${room.capacity} người',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF6B8070),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Color(0xFFEAEEEC), height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá chỉ từ',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B8070),
                      ),
                    ),
                    Text(
                      formatCurrency.format(room.price),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        color: AppColors.greenPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showCalendar(room),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Chọn lịch',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text(
          'Chọn phòng',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.greenPrimary),
            );
          } else if (state is BookingError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.dmSans(color: Colors.red),
              ),
            );
          } else if (state is RoomsLoaded) {
            final rooms = state.rooms;
            if (rooms.isEmpty) {
              return Center(
                child: Text(
                  'Khách sạn hiện chưa có phòng trống.',
                  style: GoogleFonts.dmSans(color: Colors.grey),
                ),
              );
            }
            final vipRooms = rooms.where(_isVipRoom).toList();
            final regularRooms = rooms.where((r) => !_isVipRoom(r)).toList();
            final filtered = switch (_selectedCategory) {
              1 => vipRooms,
              2 => regularRooms,
              _ => rooms,
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'Tất cả (${rooms.length})',
                        isSelected: _selectedCategory == 0,
                        onTap: () => setState(() => _selectedCategory = 0),
                      ),
                      const SizedBox(width: 10),
                      _CategoryChip(
                        label: 'VIP (${vipRooms.length})',
                        isSelected: _selectedCategory == 1,
                        onTap: () => setState(() => _selectedCategory = 1),
                      ),
                      const SizedBox(width: 10),
                      _CategoryChip(
                        label: 'Thường (${regularRooms.length})',
                        isSelected: _selectedCategory == 2,
                        onTap: () => setState(() => _selectedCategory = 2),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildRoomItem(filtered[index]),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenPrimary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.greenPrimary : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.greenPrimary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: isSelected ? Colors.white : const Color(0xFF1A2B24),
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Sheet với Date Picker ────────────────────────────────────────────
class _CalendarBottomSheet extends StatefulWidget {
  final RoomEntity room;
  final String hotelName;

  const _CalendarBottomSheet({required this.room, required this.hotelName});

  @override
  State<_CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<_CalendarBottomSheet> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  TimeSlotEntity? _matchedSlot;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isInSelectedRange(DateTime day) {
    if (_checkIn == null || _checkOut == null) return false;
    final normalized = _stripTime(day);
    final start = _stripTime(_checkIn!);
    final end = _stripTime(_checkOut!);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }

  // Sau khi chọn ngày, lọc time slot phù hợp từ danh sách đã load
  void _findMatchingSlot(List<TimeSlotEntity> slots) {
    if (_checkIn == null || _checkOut == null) return;
    setState(() {
      _matchedSlot = slots.where((s) {
        return s.isActive &&
            !s.startDate.isAfter(_checkIn!) &&
            !s.endDate.isBefore(_checkOut!);
      }).firstOrNull;
    });
  }

  Future<void> _pickCheckIn(
    BuildContext context,
    List<TimeSlotEntity> slots,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Chọn ngày nhận phòng',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.greenPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(_checkIn!)) {
          _checkOut = null;
          _matchedSlot = null;
        }
      });
      if (_checkOut != null) _findMatchingSlot(slots);
    }
  }

  Future<void> _pickCheckOut(
    BuildContext context,
    List<TimeSlotEntity> slots,
  ) async {
    if (_checkIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chọn ngày nhận phòng trước',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut ?? _checkIn!.add(const Duration(days: 1)),
      firstDate: _checkIn!.add(const Duration(days: 1)),
      lastDate: _checkIn!.add(const Duration(days: 30)),
      helpText: 'Chọn ngày trả phòng',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.greenPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _checkOut = picked);
      _findMatchingSlot(slots);
    }
  }

  void _navigateToPayment(BuildContext context, double unitPrice) {
    Navigator.pop(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final dateStr = '${fmt.format(_checkIn!)} - ${fmt.format(_checkOut!)}';
    final nightCount = _checkOut!.difference(_checkIn!).inDays;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          roomId: widget.room.id,
          hotelName: widget.hotelName,
          roomNumber: widget.room.roomNumber ?? 'Đang cập nhật',
          roomType: widget.room.roomTypeName ?? 'Đang cập nhật',
          price: (unitPrice * nightCount).toInt(),
          date: dateStr,
          checkInDate: _checkIn!,
          checkOutDate: _checkOut!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final slots = state is TimeSlotsLoaded
              ? state.timeSlots
              : <TimeSlotEntity>[];
          final isLoading = state is BookingLoading;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Text(
                  'Chọn lịch cho phòng ${widget.room.roomNumber ?? ''}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Date pickers ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerCard(
                        label: 'Nhận phòng',
                        icon: Icons.login_rounded,
                        value: _checkIn != null ? fmt.format(_checkIn!) : null,
                        onTap: () => _pickCheckIn(context, slots),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerCard(
                        label: 'Trả phòng',
                        icon: Icons.logout_rounded,
                        value: _checkOut != null
                            ? fmt.format(_checkOut!)
                            : null,
                        onTap: () => _pickCheckOut(context, slots),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLegend(),
                const SizedBox(height: 12),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.twoWeeks,
                  availableCalendarFormats: const {
                    CalendarFormat.twoWeeks: '2 weeks',
                  },
                  rowHeight: 44,
                  daysOfWeekHeight: 24,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _rangeStart = selectedDay;
                      _rangeEnd = null;
                      _checkIn = selectedDay;
                      _checkOut = null;
                      _matchedSlot = null;
                    });
                  },
                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _rangeStart = start;
                      _rangeEnd = end;
                      _checkIn = start;
                      _checkOut = end;
                      _matchedSlot = null;
                    });
                    if (start != null && end != null) {
                      _findMatchingSlot(slots);
                    }
                  },
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    isTodayHighlighted: true,
                    rangeHighlightColor: Color(0x332E8B3C),
                    rangeStartDecoration: BoxDecoration(
                      color: AppColors.greenPrimary,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: AppColors.greenPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, isToday: true);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Kết quả sau khi chọn ngày ────────────────────────────────
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  )
                else if (_checkIn == null || _checkOut == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 60,
                            color: Color(0xFFCCDDD5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chọn ngày nhận và trả phòng\nđể xem lịch trống',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: const Color(0xFF6B8070),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is BookingError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.dmSans(color: Colors.red),
                      ),
                    ),
                  )
                else ...[
                  // Hiển thị kết quả
                  _buildAvailableResult(
                    _matchedSlot?.price ?? widget.room.price,
                    formatCurrency,
                    context,
                    isAvailable: true,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _LegendChip(color: AppColors.greenPrimary, label: 'Có thể chọn'),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false}) {
    final isSelected = _isInSelectedRange(day);
    const baseColor = AppColors.greenPrimary;
    final bgColor = isSelected
        ? baseColor
        : isToday
        ? baseColor.withValues(alpha: 0.12)
        : Colors.transparent;
    final textColor = isSelected ? Colors.white : const Color(0xFF1A2B24);

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: baseColor, width: 1.4) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.dmSans(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAvailableResult(
    double unitPrice,
    NumberFormat fmt,
    BuildContext context, {
    required bool isAvailable,
  }) {
    final nightCount = _checkOut!.difference(_checkIn!).inDays;
    final totalPrice = unitPrice * nightCount;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.greenPrimary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.greenPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAvailable
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isAvailable
                        ? AppColors.greenPrimary
                        : Colors.redAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAvailable ? 'Có thể đặt phòng' : 'Đã được đặt',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isAvailable
                          ? AppColors.greenPrimary
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ResultRow(
                label: 'Nhận phòng',
                value: DateFormat('dd/MM/yyyy').format(_checkIn!),
              ),
              const SizedBox(height: 8),
              _ResultRow(
                label: 'Trả phòng',
                value: DateFormat('dd/MM/yyyy').format(_checkOut!),
              ),
              const SizedBox(height: 8),
              _ResultRow(label: 'Số đêm', value: '$nightCount đêm'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền:',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: const Color(0xFF6B8070),
                    ),
                  ),
                  Text(
                    fmt.format(totalPrice),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable
                  ? AppColors.greenPrimary
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isAvailable
                ? () => _navigateToPayment(context, unitPrice)
                : null,
            child: Text(
              isAvailable ? 'Tiếp tục đặt phòng' : 'Không còn phòng',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF6B8070),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Widget phụ ──────────────────────────────────────────────────────────────
class _DatePickerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.greenPrimary.withValues(alpha: 0.07)
              : const Color(0xFFF5F7F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? AppColors.greenPrimary : Colors.grey[300]!,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: hasValue
                      ? AppColors.greenPrimary
                      : const Color(0xFF6B8070),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF6B8070),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value ?? 'Chọn ngày',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasValue ? const Color(0xFF1A2B24) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF6B8070),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2B24),
          ),
        ),
      ],
    );
  }
}
