import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection.dart' as di;
import '../bloc/booking_bloc.dart';

class PaymentScreen extends StatefulWidget {
  final int roomId;
  final String hotelName;
  final String roomNumber;
  final String roomType;
  final int price;
  final String date;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;

  const PaymentScreen({
    super.key,
    required this.roomId,
    required this.hotelName,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    required this.date,
    required this.checkInDate,
    required this.checkOutDate,
    this.guestCount = 1,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _paymentMethods = ['Cash', 'BankTransfer', 'MoMo'];
  late String _paymentMethod;
  late TextEditingController _paidAmountCtrl;
  final TextEditingController _transactionCodeCtrl = TextEditingController();
  final TextEditingController _paymentNoteCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentMethod = _paymentMethods.first;
    _paidAmountCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _paidAmountCtrl.dispose();
    _transactionCodeCtrl.dispose();
    _paymentNoteCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _money(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  bool get _requiresTransaction => _paymentMethod != 'Cash';

  void _setPaymentMethod(String method) {
    setState(() {
      _paymentMethod = method;
      if (_paymentMethod == 'Cash') {
        _paidAmountCtrl.text = '0';
        _transactionCodeCtrl.clear();
        _paymentNoteCtrl.clear();
      } else {
        _paidAmountCtrl.text = widget.price.toString();
      }
    });
  }

  double _parsePaidAmount() {
    final raw = _paidAmountCtrl.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(raw) ?? 0;
  }

  String _buildQrPayload() {
    final amount = _parsePaidAmount().toStringAsFixed(0);
    return 'BANK:DEMO|ACC:123456789|NAME:HOTEL_OWNER|AMOUNT:$amount|ROOM:${widget.roomNumber}|NOTE:BOOKING';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>(),
      child: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreatedSuccess) {
            if (_requiresTransaction) {
              _showQrDialog(context);
            } else {
              _showPendingApprovalDialog(context);
            }
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.dmSans()),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BookingActionLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7F6),
            appBar: AppBar(
              title: Text(
                'Thanh toán & Xác nhận',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.greenPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greenPrimary.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.hotel_rounded,
                                    color: AppColors.greenPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.hotelName,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A2B24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  color: Color(0xFFEAEEEC),
                                  thickness: 1.5,
                                ),
                              ),
                              _InfoRow(
                                icon: Icons.meeting_room_rounded,
                                label: 'Phòng',
                                value:
                                    '${widget.roomNumber} (${widget.roomType})',
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.calendar_month_rounded,
                                label: 'Thời gian',
                                value: widget.date,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.greenPrimary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.greenPrimary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tổng tiền:',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B8070),
                                      ),
                                    ),
                                    Text(
                                      '${_money(widget.price)} VNĐ',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greenPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                'Phương thức thanh toán',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B8070),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: _paymentMethods.map((method) {
                                  final isSelected = _paymentMethod == method;
                                  return ChoiceChip(
                                    label: Text(
                                      method,
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.greenPrimary,
                                    backgroundColor: const Color(0xFFF0F4F2),
                                    labelStyle: GoogleFonts.dmSans(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1A2B24),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (_) =>
                                        _setPaymentMethod(method),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Số tiền thanh toán',
                                controller: _paidAmountCtrl,
                                hint: _paymentMethod == 'Cash'
                                    ? '0'
                                    : widget.price.toString(),
                                enabled: _paymentMethod != 'Cash',
                                keyboardType: TextInputType.number,
                              ),
                              if (_requiresTransaction) ...[
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: 'Mã giao dịch',
                                  controller: _transactionCodeCtrl,
                                  hint: 'VD: BANK-2025-001',
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: 'Ghi chú thanh toán',
                                  controller: _paymentNoteCtrl,
                                  hint: 'Nội dung chuyển khoản',
                                ),
                              ],
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Ghi chú đặt phòng',
                                controller: _noteCtrl,
                                hint: 'Thêm yêu cầu cho khách sạn',
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.greenPrimary, Color(0xFF23B97A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greenPrimary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_requiresTransaction &&
                                  _transactionCodeCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Vui lòng nhập mã giao dịch',
                                      style: GoogleFonts.dmSans(),
                                    ),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final paidAmount = _parsePaidAmount();
                              context.read<BookingBloc>().add(
                                CreateBookingEvent(
                                  roomId: widget.roomId,
                                  checkInDate: widget.checkInDate,
                                  checkOutDate: widget.checkOutDate,
                                  guestCount: widget.guestCount,
                                  paidAmount: paidAmount,
                                  paymentMethod: _paymentMethod,
                                  transactionCode: _requiresTransaction
                                      ? _transactionCodeCtrl.text.trim()
                                      : null,
                                  paymentNote: _requiresTransaction
                                      ? _paymentNoteCtrl.text.trim()
                                      : null,
                                  note: _noteCtrl.text.trim(),
                                ),
                              );
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Xác nhận Đặt Phòng',
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPendingApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Chờ phê duyệt',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Đơn đặt phòng của bạn đã được gửi thành công.\n\nVui lòng chờ khách sạn duyệt. Trạng thái hiện tại: Đang chờ duyệt.',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: const Color(0xFF6B8070),
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Về trang chủ',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quet ma QR de thanh toan',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: _buildQrPayload(),
              size: 180,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'So tien: ${_money(widget.price)} VND',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Noi dung: BOOKING ${widget.roomNumber}',
              style: GoogleFonts.dmSans(color: const Color(0xFF6B8070)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Huy',
              style: GoogleFonts.dmSans(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _showPendingApprovalDialog(context);
            },
            child: Text(
              'Da chuyen khoan',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B8070),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF0F4F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B8070)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF6B8070),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2B24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
