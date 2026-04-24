import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../booking/data/booking_api_service.dart';
import '../../booking/domain/entities/booking_entity.dart';
import '../../booking/domain/usecases/get_my_bookings_usecase.dart';
import '../../booking/domain/usecases/cancel_booking_usecase.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final GetMyBookingsUseCase _getMyBookings;
  late final CancelBookingUseCase _cancelBooking;
  late final TabController _tabController;

  bool _isLoading = true;
  String? _error;
  List<BookingEntity> _all = [];

  final _tabs = const ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Hoàn thành', 'Đã hủy'];

  @override
  void initState() {
    super.initState();
    final repo = BookingApiService();
    _getMyBookings = GetMyBookingsUseCase(repo);
    _cancelBooking = CancelBookingUseCase(repo);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final (items, _) = await _getMyBookings.execute(pageSize: 50);
      if (mounted) setState(() { _all = items; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  List<BookingEntity> _filtered(int tab) {
    switch (tab) {
      case 1: return _all.where((b) => b.isPending).toList();
      case 2: return _all.where((b) => b.isConfirmed).toList();
      case 3: return _all.where((b) => b.isCompleted).toList();
      case 4: return _all.where((b) => b.isCancelled).toList();
      default: return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.greenPrimary,
        elevation: 0,
        title: Text('Đặt phòng của tôi',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    _tabs.length,
                    (i) => _buildList(_filtered(i)),
                  ),
                ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 52, color: AppColors.error),
      const SizedBox(height: 12),
      Text('Không tải được dữ liệu', style: AppTextStyles.bodyMedium),
      TextButton(onPressed: _loadBookings, child: const Text('Thử lại')),
    ]),
  );

  Widget _buildList(List<BookingEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.hotel_outlined, size: 72, color: AppColors.greenLight),
          const SizedBox(height: 16),
          Text('Chưa có đặt phòng nào', style: AppTextStyles.bodyMedium),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _BookingCard(
          booking: items[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(
                booking: items[i],
                cancelUseCase: _cancelBooking,
                onCancelled: _loadBookings,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;
  const _BookingCard({required this.booking, required this.onTap});

  Color get _chipColor {
    if (booking.isPending)   return AppColors.statusPending;
    if (booking.isConfirmed) return AppColors.statusConfirmed;
    if (booking.isCancelled) return AppColors.statusCancelled;
    return AppColors.statusCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  booking.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _chipColor),
                ),
              ),
              const Spacer(),
              Text('Phòng #${booking.roomId}',
                  style: AppTextStyles.labelMedium),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.brownAccent),
              const SizedBox(width: 6),
              Text(
                '${_fmt(booking.checkInDate)} → ${_fmt(booking.checkOutDate)}',
                style: AppTextStyles.bodySmall,
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.nights_stay_outlined, size: 16, color: AppColors.brownAccent),
              const SizedBox(width: 6),
              Text('${booking.nightCount} đêm · ${booking.guestCount} khách',
                  style: AppTextStyles.bodySmall),
              const Spacer(),
              Text(
                '${_money(booking.totalAmount)} VNĐ',
                style: AppTextStyles.price.copyWith(fontSize: 15),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _money(double v) => v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
