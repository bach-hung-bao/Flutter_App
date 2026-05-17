import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../injection.dart' as di;
import '../../../shell/presentation/screens/main_nav_screen.dart';
import '../bloc/booking_bloc.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';

class MyBookingsScreen extends StatelessWidget {
  final int initialTabIndex;

  const MyBookingsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>()..add(LoadMyBookingsEvent()),
      child: _MyBookingsScreenView(initialTabIndex: initialTabIndex),
    );
  }
}

class _MyBookingsScreenView extends StatefulWidget {
  final int initialTabIndex;

  const _MyBookingsScreenView({required this.initialTabIndex});

  @override
  State<_MyBookingsScreenView> createState() => _MyBookingsScreenViewState();
}

class _MyBookingsScreenViewState extends State<_MyBookingsScreenView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _tabs = const [
    'Tất cả',
    'Chờ duyệt',
    'Đã xác nhận',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<BookingBloc>().add(LoadMyBookingsEvent());
      }
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingEntity> _filter(int tab, List<BookingEntity> all) {
    switch (tab) {
      case 1:
        return all.where((b) => b.status == 0).toList();
      case 2:
        return all.where((b) => b.status == 1).toList();
      case 3:
        return all.where((b) => b.status == 3).toList();
      case 4:
        return all.where((b) => b.status == 2).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.greenPrimary, AppColors.greenMedium],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Chuyến đi của tôi',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                context.read<BookingBloc>().add(LoadMyBookingsEvent()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.greenPrimary),
            );
          }
          if (state is BookingError)
            return _buildErrorState(context, state.message);

          if (state is MyBookingsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                final filteredList = _filter(i, state.bookings);
                if (filteredList.isEmpty) return _buildEmptyState(context);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) =>
                      _BookingItemCard(booking: filteredList[index]),
                );
              }),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.greenPrimary.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hiện tại bạn chưa có phòng nào',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quay lại trang chủ để đặt phòng nhé',
            style: GoogleFonts.dmSans(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Quay lại trang chủ', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 80,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Kết nối thất bại',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  context.read<BookingBloc>().add(LoadMyBookingsEvent()),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingItemCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingItemCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFmt = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.greenSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      color: AppColors.greenPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mã #${booking.id}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                booking.statusLabel,
                                style: GoogleFonts.dmSans(
                                  color: _statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phòng ${booking.roomId}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFmt.format(booking.checkInDate)} - ${dateFmt.format(booking.checkOutDate)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.nightCount} đêm • ${booking.guestCount} khách',
                    style: GoogleFonts.dmSans(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    currencyFmt.format(booking.totalAmount),
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.greenPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
