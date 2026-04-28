import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../booking/data/booking_api_service.dart';
import '../../booking/domain/entities/booking_entity.dart';
import '../../booking/domain/usecases/get_my_bookings_usecase.dart';
import '../../booking/domain/usecases/cancel_booking_usecase.dart';
import 'booking_detail_screen.dart';
import '../../shell/presentation/main_nav_screen.dart';
import '../../../core/constants/app_colors.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kGreen = AppColors.greenPrimary;
const _kGreenDark = AppColors.greenPrimary;
const _kGold = Colors.amber;
const _kSurface = AppColors.scaffoldBg;
const _kCard = AppColors.cardBg;
const _kTextPrimary = AppColors.textPrimary;
const _kTextSec = AppColors.textSecondary;
const _kDivider = AppColors.divider;

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

  final _tabs = const [
    'Tất cả',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Hoàn thành',
    'Đã hủy',
  ];

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final (items, _) = await _getMyBookings.execute(pageSize: 50);
      if (mounted) {
        setState(() {
          _all = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<BookingEntity> _filtered(int tab) {
    switch (tab) {
      case 1:
        return _all.where((b) => b.isPending).toList();
      case 2:
        return _all.where((b) => b.isConfirmed).toList();
      case 3:
        return _all.where((b) => b.isCompleted).toList();
      case 4:
        return _all.where((b) => b.isCancelled).toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                  ? _buildError()
                  : TabBarView(
                      controller: _tabController,
                      children: List.generate(
                        _tabs.length,
                        (i) => _buildList(_filtered(i), context),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.greenPrimary, AppColors.greenMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đặt phòng của tôi',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_all.length} đặt phòng',
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _loadBookings();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
              indicatorColor: _kGold,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(color: _kGreen, strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text(
          'Đang tải đặt phòng...',
          style: GoogleFonts.dmSans(color: _kTextSec, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không tải được dữ liệu',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kiểm tra kết nối mạng và thử lại.',
            style: GoogleFonts.dmSans(fontSize: 13.5, color: _kTextSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadBookings,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGreenDark, _kGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Thử lại',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Khối Icon bo tròn mềm mại
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greenMedium.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenMedium.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded, // Đổi icon sang dạng hóa đơn/booking
                  size: 56,
                  color: AppColors.greenMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Chưa có đặt phòng nào',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172B24),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Bạn chưa có giao dịch đặt phòng nào ở mục này. Hãy lên kế hoạch cho kỳ nghỉ tuyệt vời của mình ngay nhé!',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF6B7B75),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Nút Call to Action
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenMedium,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Bo góc mượt
                ),
              ),
              onPressed: () {
                // Quay lại trang chủ để tìm phòng
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Đặt phòng ngay',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60), // Đẩy nhẹ lên giữa màn hình
        ],
      ),
    ),
  );

  Widget _buildList(List<BookingEntity> items, BuildContext context) {
    if (items.isEmpty) {
      return _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: _kGreen,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(), // Để vuốt refresh hoạt động khi list rỗng
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: items.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: items[i],
          index: i,
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a, _) => BookingDetailScreen(
                booking: items[i],
                cancelUseCase: _cancelBooking,
                onCancelled: _loadBookings,
              ),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position:
                      Tween(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BOOKING CARD
// ════════════════════════════════════════════════════════════════════════════
class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;
  final int index;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.index,
  });

  Color get _statusColor {
    if (booking.isPending) return const Color(0xFFF59E0B);
    if (booking.isConfirmed) return _kGreen;
    if (booking.isCancelled) return const Color(0xFFEF4444);
    return const Color(0xFF6366F1); // completed → indigo
  }

  IconData get _statusIcon {
    if (booking.isPending) return Icons.hourglass_top_rounded;
    if (booking.isConfirmed) return Icons.check_circle_rounded;
    if (booking.isCancelled) return Icons.cancel_rounded;
    return Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Colored top strip ──────────────────────────────────────
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Status chip + Room ──────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _statusColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon, size: 12, color: _statusColor),
                              const SizedBox(width: 5),
                              Text(
                                booking.statusLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kDivider),
                          ),
                          child: Text(
                            'Phòng #${booking.roomId}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(height: 1, color: _kDivider),
                    const SizedBox(height: 14),

                    // ── Row 2: Dates ───────────────────────────────────
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.flight_land_rounded,
                          label: 'Check-in',
                          value: _fmt(booking.checkInDate),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: _kTextSec,
                          ),
                        ),
                        _InfoChip(
                          icon: Icons.flight_takeoff_rounded,
                          label: 'Check-out',
                          value: _fmt(booking.checkOutDate),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Row 3: Nights · Guests · Price ────────────────
                    Row(
                      children: [
                        _DotTag(
                          icon: Icons.nights_stay_rounded,
                          text: '${booking.nightCount} đêm',
                        ),
                        _buildDot(),
                        _DotTag(
                          icon: Icons.people_rounded,
                          text: '${booking.guestCount} khách',
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_money(booking.totalAmount)}đ',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _kGreen,
                              ),
                            ),
                            Text(
                              'tổng tiền',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _kTextSec,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: _kTextSec.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    ),
  );

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _money(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: _kTextSec)),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(icon, size: 13, color: _kGreen),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DotTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _kGreen),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _kTextSec,
          ),
        ),
      ],
    );
  }
}