import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection.dart' as di;
import '../bloc/booking_bloc.dart';
import '../../domain/usecases/get_my_bookings_usecase.dart';
import 'payment_screen.dart';

const _kGreen = AppColors.greenPrimary;
const _kSurface = Color(0xFFF8FAFC);
const _kTextPrimary = Color(0xFF1E293B);
const _kRed = Color(0xFFEF4444);

// =========================================================================
// MÀN HÌNH 1: CHỌN NGÀY LƯU TRÚ
// =========================================================================
class RoomSelectionScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const RoomSelectionScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final GetMyBookingsUseCase _getMyBookings = di.sl<GetMyBookingsUseCase>();
  List<DateTime> _bookedDates = [];

  bool _isBooked(DateTime day) {
    return _bookedDates.any((d) => isSameDay(d, day));
  }

  @override
  void initState() {
    super.initState();
    _fetchBookedDates();
  }

  Future<void> _fetchBookedDates() async {
    // Gọi UseCase lấy danh sách booking của khách sạn này để bôi đỏ
    try {
      final (bookings, _) = await _getMyBookings.execute(
        pageIndex: 1,
        pageSize: 200,
      ); // Đồng bộ với API MyBookings
      if (!mounted) return;
      setState(() {
        _bookedDates = bookings
            .where((b) => b.status == 0 || b.status == 1) // Chờ duyệt hoặc Đã xác nhận
            .expand((b) => _getDaysInBetween(b.checkInDate, b.checkOutDate))
            .toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bookedDates = [];
      });
    }
  }

  List<DateTime> _getDaysInBetween(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  void _showTimeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimeSelectionSheet(
        onTimeSelected: (time) {
          Navigator.pop(context); // Đóng bảng chọn giờ
          // CHUYỂN SANG MÀN HÌNH 2: CHỌN PHÒNG
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AvailableRoomsScreen(
                hotelId: widget.hotelId,
                hotelName: widget.hotelName,
                checkIn: _rangeStart!,
                checkOut: _rangeEnd!,
                checkInTime: time,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _rangeStart != null && _rangeEnd != null;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _kTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chọn ngày lưu trú',
          style: GoogleFonts.dmSans(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _rangeStart ?? DateTime.now(),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  onRangeSelected: (start, end, focused) {
                    if (start != null && _isBooked(start)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phòng đã được đặt', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    if (end != null && _isBooked(end)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phòng đã được đặt', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    if (start != null && end != null) {
                      final days = _getDaysInBetween(start, end);
                      if (days.any(_isBooked)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phòng đã được đặt trong khoảng thời gian này', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        return;
                      }
                    }
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (_isBooked(day)) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: _kRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  calendarStyle: const CalendarStyle(
                    rangeHighlightColor: Color(0xFFE8F5EE),
                    rangeStartDecoration: BoxDecoration(
                      color: _kGreen,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: _kGreen,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
            ),
          ),
          // NÚT TIẾP TỤC DƯỚI CÙNG
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canContinue ? _showTimeSelectionSheet : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tiếp tục',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canContinue ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// MÀN HÌNH NHỎ (BOTTOM SHEET): CHỌN GIỜ CHECK-IN
// =========================================================================
class _TimeSelectionSheet extends StatefulWidget {
  final Function(String) onTimeSelected;
  const _TimeSelectionSheet({required this.onTimeSelected});

  @override
  State<_TimeSelectionSheet> createState() => _TimeSelectionSheetState();
}

class _TimeSelectionSheetState extends State<_TimeSelectionSheet> {
  final List<String> _times = [
    "08:00",
    "10:00",
    "12:00",
    "14:00",
    "16:00",
    "18:00",
    "20:00",
  ];
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chọn giờ nhận phòng',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _kGreen : Colors.white,
                      border: Border.all(
                        color: isSelected ? _kGreen : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.dmSans(
                        color: isSelected ? Colors.white : _kTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedTime != null
                    ? () => widget.onTimeSelected(_selectedTime!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedTime != null
                        ? Colors.white
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// MÀN HÌNH 2: CHỌN PHÒNG VIP / STD
// =========================================================================
class AvailableRoomsScreen extends StatelessWidget {
  final int hotelId;
  final String hotelName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String checkInTime;

  const AvailableRoomsScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
  });

  @override
  Widget build(BuildContext context) {
    // Cung cấp Bloc mới cho màn hình này để gọi API lấy danh sách phòng
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>()..add(LoadRoomsForHotelEvent(hotelId)),
      child: _AvailableRoomsView(
        hotelName: hotelName,
        checkIn: checkIn,
        checkOut: checkOut,
        checkInTime: checkInTime,
      ),
    );
  }
}

class _AvailableRoomsView extends StatefulWidget {
  final String hotelName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String checkInTime;

  const _AvailableRoomsView({
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
  });

  @override
  State<_AvailableRoomsView> createState() => _AvailableRoomsViewState();
}

class _AvailableRoomsViewState extends State<_AvailableRoomsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _roomTypeKey(dynamic room) {
    final raw = room.roomTypeName?.toString() ?? '';
    return raw.trim().toUpperCase();
  }

  bool _isVipRoom(dynamic room) {
    final key = _roomTypeKey(room);
    return key.contains('VIP') || key.contains('DELUXE');
  }

  bool _isStdRoom(dynamic room) {
    final key = _roomTypeKey(room);
    return key.contains('STD') || key.contains('STANDARD');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 2 Tabs: VIP và STD
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM');

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _kTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Chọn hạng phòng',
              style: GoogleFonts.dmSans(
                color: _kTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${dateFmt.format(widget.checkIn)} - ${dateFmt.format(widget.checkOut)} • Nhận phòng: ${widget.checkInTime}',
              style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _kGreen,
          indicatorWeight: 3,
          labelColor: _kGreen,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: "Phòng VIP"),
            Tab(text: "Phòng STD"),
          ],
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _kGreen),
            );
          }
          if (state is RoomsLoaded) {
            // LỌC DỮ LIỆU TỪ DATABASE THEO TỪ KHOÁ "VIP" VÀ "STD"
            final vipRooms = state.rooms.where(_isVipRoom).toList();
            final stdRooms = state.rooms.where(_isStdRoom).toList();

            return TabBarView(
              controller: _tabController,
              children: [_buildRoomList(vipRooms), _buildRoomList(stdRooms)],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRoomList(List<dynamic> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Không có phòng hạng này",
              style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isVip = _isVipRoom(room);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isVip
                  ? Colors.amber.shade300
                  : Colors.grey.withOpacity(0.1),
              width: isVip ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isVip
                      ? Colors.amber.shade50
                      : _kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.king_bed_rounded,
                  color: isVip ? Colors.amber.shade700 : _kGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Phòng ${room.roomNumber}',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isVip) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(room.price)}/đêm',
                      style: GoogleFonts.dmSans(
                        color: _kGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        roomId: room.id,
                        hotelName: widget.hotelName,
                        roomNumber: room.roomNumber!,
                        roomType: room.roomTypeName ?? (isVip ? 'VIP' : 'STD'),
                        price: room.price.toInt(),
                        checkInDate: widget.checkIn,
                        checkOutDate: widget.checkOut,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Chọn',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
