import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../booking/domain/entities/booking_entity.dart';
import '../../booking/domain/usecases/cancel_booking_usecase.dart';
import '../../review/data/review_api_service.dart';
import '../../review/domain/usecases/create_review_usecase.dart';
import '../../review/presentation/write_review_screen.dart';

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

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isCancelling = false;

  Future<void> _cancel() async {
    final reason = await _showCancelDialog();
    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      await widget.cancelUseCase.execute(widget.booking.id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đặt phòng', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.statusCancelled,
          ),
        );
        widget.onCancelled?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _showCancelDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Lý do hủy', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Nhập lý do...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Thoát', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCancelled),
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text('Xác nhận hủy',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        title: Text('Chi tiết đặt phòng',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status banner
          _StatusBanner(booking: b),
          const SizedBox(height: 20),

          // Info card
          _InfoCard(children: [
            _Row(Icons.meeting_room_outlined, 'Phòng', '#${b.roomId}'),
            _Row(Icons.login_outlined, 'Check-in', _fmtDate(b.checkInDate)),
            _Row(Icons.logout_outlined, 'Check-out', _fmtDate(b.checkOutDate)),
            _Row(Icons.nights_stay_outlined, 'Số đêm', '${b.nightCount} đêm'),
            _Row(Icons.people_outline, 'Số khách', '${b.guestCount} người'),
          ]),
          const SizedBox(height: 16),

          // Payment card
          _InfoCard(children: [
            _Row(Icons.attach_money, 'Đơn giá', '${_money(b.roomUnitPrice)} VNĐ'),
            _Row(Icons.receipt_outlined, 'Tổng tiền', '${_money(b.totalAmount)} VNĐ',
                valueStyle: AppTextStyles.price),
          ]),

          if (b.note != null) ...[
            const SizedBox(height: 16),
            _InfoCard(children: [
              _Row(Icons.notes_outlined, 'Ghi chú', b.note!),
            ]),
          ],

          if (b.isCancelled && b.cancelReason != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.statusCancelled.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _Row(Icons.cancel_outlined, 'Lý do hủy', b.cancelReason!),
            ),
          ],

          const SizedBox(height: 32),
          // Actions
          if (b.isPending || b.isConfirmed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isCancelling ? null : _cancel,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined),
                label: Text('Hủy đặt phòng',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCancelled,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (b.isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.star_outline),
                label: Text('Viết đánh giá',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _money(double v) => v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _StatusBanner extends StatelessWidget {
  final BookingEntity booking;
  const _StatusBanner({required this.booking});

  Color get _color {
    if (booking.isPending)   return AppColors.statusPending;
    if (booking.isConfirmed) return AppColors.statusConfirmed;
    if (booking.isCancelled) return AppColors.statusCancelled;
    return AppColors.statusCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, color: _color),
        const SizedBox(width: 10),
        Text(
          booking.statusLabel,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _color),
        ),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(color: AppColors.divider, height: 16)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _Row(this.icon, this.label, this.value, {this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.brownAccent),
      const SizedBox(width: 10),
      Text(label, style: AppTextStyles.bodySmall),
      const Spacer(),
      Text(value, style: valueStyle ?? AppTextStyles.labelLarge),
    ]);
  }
}
