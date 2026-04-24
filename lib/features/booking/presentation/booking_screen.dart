import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../booking/domain/usecases/create_booking_usecase.dart';

class BookingScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;
  final CreateBookingUseCase createBookingUseCase;
  // roomId would be selected; for now default to 1 or can be passed
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

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guestCount = 1;
  String _paymentMethod = 'Cash';
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  final _paymentMethods = ['Cash', 'BankTransfer', 'Online'];

  int get _nights {
    // 1. Nếu chưa chọn 1 trong 2 ngày thì trả về 0 luôn
    if (_checkIn == null || _checkOut == null) return 0;
    
    // 2. Nếu ngày Check-out trước ngày Check-in (lỗi logic người dùng) thì trả về 0
    if (_checkOut!.isBefore(_checkIn!)) return 0;
    
    // 3. Tính số đêm hợp lệ
    return _checkOut!.difference(_checkIn!).inDays;
  }
  
  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? now : (_checkIn ?? now).add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.greenPrimary),
        ),
        child: child!,
      ),
    );
    
    if (picked == null) return;
    
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
      _snack('Vui lòng chọn ngày check-in và check-out', AppColors.warning);
      return;
    }
    if (_nights < 1) {
      _snack('Check-out phải sau check-in ít nhất 1 ngày', AppColors.warning);
      return;
    }

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
        _snack('Đặt phòng thành công! Chờ xác nhận.', AppColors.greenPrimary);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.poppins()), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        title: Text('Đặt phòng',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hotel name banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.hotel, color: AppColors.greenPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.hotelName,
                    style: AppTextStyles.labelLarge, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Dates
          Text('Chọn ngày', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DatePicker(
              label: 'Check-in',
              date: _checkIn,
              icon: Icons.login_outlined,
              onTap: () => _pickDate(true),
            )),
            const SizedBox(width: 12),
            Expanded(child: _DatePicker(
              label: 'Check-out',
              date: _checkOut,
              icon: Icons.logout_outlined,
              onTap: () => _pickDate(false),
            )),
          ]),
          if (_nights > 0) ...[
            const SizedBox(height: 8),
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$_nights đêm',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.greenPrimary)),
            )),
          ],
          const SizedBox(height: 24),

          // Guest count
          Text('Số khách', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(children: [
              const Icon(Icons.people_outline, color: AppColors.brownAccent),
              const SizedBox(width: 12),
              Text('Số người', style: AppTextStyles.bodyMedium),
              const Spacer(),
              _Stepper(
                value: _guestCount,
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => _guestCount = v),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Payment method
          Text('Thanh toán', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _paymentMethods.map((m) => ChoiceChip(
              label: Text(_payLabel(m), style: GoogleFonts.poppins(fontSize: 13)),
              selected: _paymentMethod == m,
              onSelected: (_) => setState(() => _paymentMethod = m),
              selectedColor: AppColors.greenPrimary,
              backgroundColor: AppColors.cardBg,
              labelStyle: GoogleFonts.poppins(
                color: _paymentMethod == m ? Colors.white : AppColors.textPrimary),
            )).toList(),
          ),
          const SizedBox(height: 24),

          // Note
          Text('Ghi chú (tuỳ chọn)', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Yêu cầu đặc biệt, giờ nhận phòng...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 36),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Xác nhận đặt phòng', style: AppTextStyles.button),
            ),
          ),
        ]),
      ),
    );
  }

  String _payLabel(String m) {
    switch (m) {
      case 'Cash': return 'Tiền mặt';
      case 'BankTransfer': return 'Chuyển khoản';
      case 'Online': return 'Online';
      default: return m;
    }
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;
  const _DatePicker({required this.label, required this.date, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: date != null ? AppColors.greenPrimary : AppColors.divider, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, size: 18, color: AppColors.greenPrimary),
            const SizedBox(width: 6),
            Text(
              date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Chọn',
              style: AppTextStyles.bodyMedium.copyWith(
                color: date != null ? AppColors.textPrimary : AppColors.textHint),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _Btn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('$value', style: AppTextStyles.h3),
      ),
      _Btn(Icons.add, value < max ? () => onChanged(value + 1) : null),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _Btn(this.icon, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onPressed != null ? AppColors.greenPrimary : AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}