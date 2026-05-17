import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../injection.dart' as di;
import '../../../../../core/storage/auth_storage.dart';
import '../bloc/booking_bloc.dart';

import '../../domain/entities/booking_entity.dart';
import '../../../review/presentation/screens/write_review_screen.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF1A8F5C);
const _kGreenDark = Color(0xFF0F5C3A);
const _kGreenAccent = Color(0xFF00D68F);
const _kSurface = Color(0xFFF5F7F6);
const _kCard = Colors.white;
const _kTextPrimary = Color(0xFF1A2B24);
const _kTextSec = Color(0xFF6B8070);
const _kDivider = Color(0xFFEAEEEC);

class BookingDetailScreen extends StatelessWidget {
  final BookingEntity booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>(),
      child: _BookingDetailScreenView(booking: booking),
    );
  }
}

class _BookingDetailScreenView extends StatefulWidget {
  final BookingEntity booking;

  const _BookingDetailScreenView({required this.booking});

  @override
  State<_BookingDetailScreenView> createState() =>
      _BookingDetailScreenViewState();
}

class _BookingDetailScreenViewState extends State<_BookingDetailScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  int? _currentUserId;

  Color get _statusColor {
    final b = widget.booking;
    if (b.isPending) return const Color(0xFFF59E0B);
    if (b.isConfirmed) return _kGreen;
    if (b.isCancelled) return const Color(0xFFEF4444);
    return const Color(0xFF6366F1);
  }

  IconData get _statusIcon {
    final b = widget.booking;
    if (b.isPending) return Icons.hourglass_top_rounded;
    if (b.isConfirmed) return Icons.check_circle_rounded;
    if (b.isCancelled) return Icons.cancel_rounded;
    return Icons.star_rounded;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    // Load current userId asynchronously
    AuthStorage().getSession().then((session) {
      if (mounted) setState(() => _currentUserId = session?.userId);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy?'),
        content: const Text('Bạn sẽ mất toàn bộ số tiền đã thanh toán. Bạn có chắc chắn muốn hủy không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Quay lại')),
          TextButton(
            onPressed: () {
              context.read<BookingBloc>().add(CancelBookingEvent(widget.booking.id, reason: 'Hủy phòng'));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Tôi chấp nhận hủy', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is MyBookingsLoaded && !state.isCancelling) {
              _snack('Đã hủy đặt phòng thành công', const Color(0xFFEF4444));
              Navigator.pop(context); // Go back after success
            } else if (state is BookingError) {
              _snack(state.message, Colors.red);
            }
          },
          builder: (context, state) {
            bool isCancelling = false;
            if (state is MyBookingsLoaded) {
              isCancelling = state.isCancelling;
            }

            // currentUserId loaded from initState
            final currentUserId = _currentUserId;

            return Column(
              children: [
                _buildHeader(b),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeCtrl,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusBanner(b),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Thông tin lưu trú'),
                          const SizedBox(height: 12),
                          _buildInfoCard([
                            _DetailRow(
                              Icons.meeting_room_rounded,
                              'Phòng',
                              '#${b.roomId}',
                            ),
                            _DetailRow(
                              Icons.flight_land_rounded,
                              'Check-in',
                              _fmtDate(b.checkInDate),
                            ),
                            _DetailRow(
                              Icons.flight_takeoff_rounded,
                              'Check-out',
                              _fmtDate(b.checkOutDate),
                            ),
                            _DetailRow(
                              Icons.nights_stay_rounded,
                              'Số đêm',
                              '${b.nightCount} đêm',
                            ),
                            _DetailRow(
                              Icons.people_rounded,
                              'Số khách',
                              '${b.guestCount} người',
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Thanh toán'),
                          const SizedBox(height: 12),
                          _buildPaymentCard(b),

                          if (b.note != null) ...[
                            const SizedBox(height: 20),
                            _buildSectionLabel('Ghi chú'),
                            const SizedBox(height: 12),
                            _buildNoteCard(b.note!),
                          ],

                          if (b.isCancelled && b.cancelReason != null) ...[
                            const SizedBox(height: 20),
                            _buildCancelReasonCard(b.cancelReason!),
                          ],

                          const SizedBox(height: 32),
                          _buildActions(b, isCancelling, currentUserId),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BookingEntity b) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6B42), _kGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Chi tiết đặt phòng',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Banner ───────────────────────────────────────────────────────────
  Widget _buildStatusBanner(BookingEntity b) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor.withValues(alpha: 0.12),
            _statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.statusLabel,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Mã đặt phòng #${b.id}',
                  style: GoogleFonts.dmSans(fontSize: 12, color: _kTextSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGreen, _kGreenAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }

  // ── Info Card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: rows[i],
              ),
              if (i < rows.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(height: 1, color: _kDivider),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Payment Card ─────────────────────────────────────────────────────────────
  // (Giữ phần Palette và các imports ở đầu file của bạn)

  Widget _buildPaymentCard(BookingEntity b) {
    final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kDivider),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Đơn giá/đêm',
            currencyFmt.format(b.roomUnitPrice),
            isBold: false,
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Số lượng đêm', 'x${b.nightCount}', isBold: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildPriceRow(
            'Tổng cộng',
            currencyFmt.format(b.totalAmount),
            isBold: true,
            color: _kGreen,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Đã thanh toán',
            currencyFmt.format(b.totalAmount),
            isBold: false,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(color: _kTextSec, fontSize: 14)),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
            color: color ?? _kTextPrimary,
          ),
        ),
      ],
    );
  }

  // ── Note Card ────────────────────────────────────────────────────────────────
  Widget _buildNoteCard(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_rounded, color: _kGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _kTextSec,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancel Reason Card ────────────────────────────────────────────────────────
  Widget _buildCancelReasonCard(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lý do hủy',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _kTextSec,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Widget _buildActions(BookingEntity b, bool isCancelling, int? currentUserId) {
    if (b.status == 0) { // Chỉ hiện khi đang Chờ duyệt (Pending)
      final isCreator = currentUserId == b.customerId;

      if (!isCreator) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isCancelling ? null : () {
                      context.read<BookingBloc>().add(UpdateBookingStatusEvent(b.id, 3)); // 3 = Cancelled/Rejected
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Từ chối', style: GoogleFonts.dmSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isCancelling ? null : () {
                      context.read<BookingBloc>().add(UpdateBookingStatusEvent(b.id, 1)); // 1 = Confirmed
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Xác nhận', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '* Lưu ý: Hủy đặt phòng lúc này sẽ không được hoàn lại tiền.',
                style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Hủy đặt phòng', style: GoogleFonts.dmSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    }

    if (b.isCompleted) {
      return _GradientButton(
        label: 'Viết đánh giá',
        icon: Icons.star_rounded,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                WriteReviewScreen(bookingId: b.id, roomId: b.roomId),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _money(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _kGreen),
        ),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.dmSans(fontSize: 14, color: _kTextSec)),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDestructive
        ? [const Color(0xFFB91C1C), const Color(0xFFEF4444)]
        : [_kGreenDark, _kGreen, const Color(0xFF23B97A)];

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
