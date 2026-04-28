import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../booking/domain/entities/booking_entity.dart';
import '../../booking/domain/usecases/cancel_booking_usecase.dart';
import '../../review/data/review_api_service.dart';
import '../../review/domain/usecases/create_review_usecase.dart';
import '../../review/presentation/write_review_screen.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF1A8F5C);
const _kGreenDark = Color(0xFF0F5C3A);
const _kGreenAccent = Color(0xFF00D68F);
const _kSurface = Color(0xFFF5F7F6);
const _kCard = Colors.white;
const _kTextPrimary = Color(0xFF1A2B24);
const _kTextSec = Color(0xFF6B8070);
const _kDivider = Color(0xFFEAEEEC);

class BookingDetailScreen extends StatefulWidget {
  final BookingEntity booking;
  final CancelBookingUseCase cancelUseCase;
  final VoidCallback? onCancelled;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    required this.cancelUseCase,
    this.onCancelled,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isCancelling = false;
  late AnimationController _fadeCtrl;

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
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    final reason = await _showCancelDialog();
    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      await widget.cancelUseCase.execute(widget.booking.id, reason);
      if (mounted) {
        _snack('Đã hủy đặt phòng thành công', const Color(0xFFEF4444));
        widget.onCancelled?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        _snack('Lỗi: $e', Colors.red);
      }
    }
  }

  Future<String?> _showCancelDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: _kCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hủy đặt phòng?',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vui lòng cho chúng tôi biết lý do',
                style: GoogleFonts.dmSans(fontSize: 13, color: _kTextSec),
              ),
            ],
          ),
          content: TextField(
            controller: ctrl,
            style: GoogleFonts.dmSans(fontSize: 14, color: _kTextPrimary),
            decoration: InputDecoration(
              hintText: 'Nhập lý do hủy...',
              hintStyle: GoogleFonts.dmSans(color: _kTextSec),
              filled: true,
              fillColor: _kSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            maxLines: 3,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kTextSec,
                      side: const BorderSide(color: _kDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Giữ lại',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, ctrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Xác nhận hủy',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        body: Column(
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
                      _buildActions(b),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
  Widget _buildPaymentCard(BookingEntity b) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kGreen.withValues(alpha: 0.06),
            _kGreenAccent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kGreen.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: _kGreen,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Đơn giá',
                  style: GoogleFonts.dmSans(fontSize: 14, color: _kTextSec),
                ),
                const Spacer(),
                Text(
                  '${_money(b.roomUnitPrice)} VNĐ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 1,
                color: _kGreen.withValues(alpha: 0.15),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.attach_money_rounded,
                  color: _kGreen,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tổng tiền',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_money(b.totalAmount)} VNĐ',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
  Widget _buildActions(BookingEntity b) {
    if (b.isPending || b.isConfirmed) {
      return _GradientButton(
        label: 'Hủy đặt phòng',
        icon: Icons.cancel_rounded,
        isLoading: _isCancelling,
        isDestructive: true,
        onPressed: _cancel,
      );
    }

    if (b.isCompleted) {
      return _GradientButton(
        label: 'Viết đánh giá',
        icon: Icons.star_rounded,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WriteReviewScreen(
              bookingId: b.id,
              roomId: b.roomId,
              createReviewUseCase: CreateReviewUseCase(ReviewApiService()),
            ),
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
