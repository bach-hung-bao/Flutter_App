import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../booking/domain/usecases/create_booking_usecase.dart';

// ─── Palette (đồng bộ home) ────────────────────────────────────────────────
const _kGreen = Color(0xFF1A8F5C);
const _kGreenDark = Color(0xFF0F5C3A);
const _kGreenAccent = Color(0xFF00D68F);
const _kSurface = Color(0xFFF5F7F6);
const _kCard = Colors.white;
const _kTextPrimary = Color(0xFF1A2B24);
const _kTextSec = Color(0xFF6B8070);
const _kDivider = Color(0xFFEAEEEC);

class BookingScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;
  final CreateBookingUseCase createBookingUseCase;
  final int? roomId;

  const BookingScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.createBookingUseCase,
    this.roomId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guestCount = 1;
  String _paymentMethod = 'Cash';
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  late AnimationController _fadeCtrl;

  final _paymentMethods = ['Cash', 'BankTransfer', 'Online'];

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    if (_checkOut!.isBefore(_checkIn!)) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? now
          : (_checkIn ?? now).add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kGreen,
            onPrimary: Colors.white,
            surface: _kCard,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _kGreen),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_checkIn == null || _checkOut == null) {
      _snack('Vui lòng chọn ngày check-in và check-out', Colors.orange);
      return;
    }
    if (_nights < 1) {
      _snack('Check-out phải sau check-in ít nhất 1 ngày', Colors.orange);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    try {
      await widget.createBookingUseCase.execute(
        roomId: widget.roomId ?? 1,
        checkInDate: _checkIn!,
        checkOutDate: _checkOut!,
        guestCount: _guestCount,
        paidAmount: 0,
        paymentMethod: _paymentMethod,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      if (mounted) {
        _snack('Đặt phòng thành công! Chờ xác nhận.', _kGreen);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _snack('Lỗi: $e', Colors.red);
      }
    }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeCtrl,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHotelBanner(),
                      const SizedBox(height: 28),
                      _buildSectionLabel(
                        'Chọn ngày lưu trú',
                        Icons.date_range_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildDateRow(),
                      if (_nights > 0) ...[
                        const SizedBox(height: 12),
                        _buildNightsBadge(),
                      ],
                      const SizedBox(height: 28),
                      _buildSectionLabel(
                        'Số lượng khách',
                        Icons.people_alt_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildGuestCounter(),
                      const SizedBox(height: 28),
                      _buildSectionLabel(
                        'Phương thức thanh toán',
                        Icons.payment_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildPaymentMethods(),
                      const SizedBox(height: 28),
                      _buildSectionLabel(
                        'Ghi chú (tuỳ chọn)',
                        Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildNoteField(),
                      const SizedBox(height: 36),
                      _buildSubmitButton(),
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

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
                  'Đặt phòng',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
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

  // ── Hotel Banner ────────────────────────────────────────────────────────
  Widget _buildHotelBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kGreen.withValues(alpha: 0.08),
            _kGreenAccent.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, Color(0xFF23B97A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn đang đặt tại',
                  style: GoogleFonts.dmSans(fontSize: 12, color: _kTextSec),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.hotelName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
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
        Icon(icon, size: 18, color: _kGreen),
        const SizedBox(width: 8),
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

  // ── Date Row ─────────────────────────────────────────────────────────────
  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: _DateCard(
            label: 'Check-in',
            date: _checkIn,
            icon: Icons.flight_land_rounded,
            onTap: () => _pickDate(true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Icon(Icons.arrow_forward_rounded, color: _kGreen, size: 18),
            ],
          ),
        ),
        Expanded(
          child: _DateCard(
            label: 'Check-out',
            date: _checkOut,
            icon: Icons.flight_takeoff_rounded,
            onTap: () => _pickDate(false),
          ),
        ),
      ],
    );
  }

  Widget _buildNightsBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kGreen, Color(0xFF23B97A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: _kGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.nights_stay_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '$_nights đêm lưu trú',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Guest Counter ─────────────────────────────────────────────────────────
  Widget _buildGuestCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: _kGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số người',
                  style: GoogleFonts.dmSans(fontSize: 12, color: _kTextSec),
                ),
                Text(
                  '$_guestCount khách',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          _GuestStepper(
            value: _guestCount,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _guestCount = v);
            },
          ),
        ],
      ),
    );
  }

  // ── Payment Methods ────────────────────────────────────────────────────────
  Widget _buildPaymentMethods() {
    final labels = {
      'Cash': 'Tiền mặt',
      'BankTransfer': 'Chuyển khoản',
      'Online': 'Online',
    };
    final icons = {
      'Cash': Icons.payments_rounded,
      'BankTransfer': Icons.account_balance_rounded,
      'Online': Icons.language_rounded,
    };
    return Row(
      children: _paymentMethods.map((m) {
        final selected = _paymentMethod == m;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: m != _paymentMethods.last ? 10 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _paymentMethod = m);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [_kGreen, Color(0xFF23B97A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : _kCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? Colors.transparent : _kDivider,
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _kGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Icon(
                      icons[m]!,
                      color: selected ? Colors.white : _kGreen,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[m]!,
                      style: GoogleFonts.dmSans(
                        color: selected ? Colors.white : _kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Note Field ────────────────────────────────────────────────────────────
  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _noteCtrl,
        maxLines: 3,
        style: GoogleFonts.dmSans(fontSize: 14, color: _kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Yêu cầu đặc biệt, giờ nhận phòng, sở thích...',
          hintStyle: GoogleFonts.dmSans(color: _kTextSec, fontSize: 13),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _kDivider, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _kDivider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _kGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.all(18),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8, top: 14),
            child: Icon(Icons.edit_rounded, color: _kGreen, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: _isSubmitting
            ? null
            : const LinearGradient(
                colors: [_kGreenDark, _kGreen, Color(0xFF23B97A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: _isSubmitting ? _kDivider : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isSubmitting
            ? []
            : [
                BoxShadow(
                  color: _kGreen.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _kGreen,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Xác nhận đặt phòng',
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

// ════════════════════════════════════════════════════════════════════════════
// DATE CARD
// ════════════════════════════════════════════════════════════════════════════
class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;
  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasDate ? _kGreen : _kDivider,
            width: hasDate ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasDate
                  ? _kGreen.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasDate ? _kGreen : _kTextSec,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, size: 16, color: _kGreen),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    hasDate
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'Chọn ngày',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: hasDate ? FontWeight.w700 : FontWeight.w400,
                      color: hasDate ? _kTextPrimary : _kTextSec,
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
}

// ════════════════════════════════════════════════════════════════════════════
// GUEST STEPPER
// ════════════════════════════════════════════════════════════════════════════
class _GuestStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _GuestStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove_rounded,
          enabled: value > 1,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add_rounded,
          enabled: value < 10,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [_kGreen, Color(0xFF23B97A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : _kDivider,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
