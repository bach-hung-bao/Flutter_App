import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection.dart' as di;
import '../../../shell/presentation/screens/main_nav_screen.dart';
import '../bloc/booking_bloc.dart';

// 1. CLASS CHA: Khởi tạo và cung cấp BookingBloc
class PaymentScreen extends StatelessWidget {
  final int roomId;
  final String hotelName;
  final String roomNumber;
  final String roomType;
  final int price;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const PaymentScreen({
    super.key,
    required this.roomId,
    required this.hotelName,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>(),
      child: _PaymentScreenView(
        roomId: roomId,
        hotelName: hotelName,
        roomNumber: roomNumber,
        roomType: roomType,
        price: price,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      ),
    );
  }
}

// 2. CLASS CON: Chứa giao diện
class _PaymentScreenView extends StatelessWidget {
  final int roomId;
  final String hotelName;
  final String roomNumber;
  final String roomType;
  final int price;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const _PaymentScreenView({
    required this.roomId,
    required this.hotelName,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = checkOutDate.difference(checkInDate).inDays;
    final total = price * (days == 0 ? 1 : days);

    // BlocListener lắng nghe trạng thái để bật/tắt Popup Loading và Thành công
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionLoading) {
          // Bật vòng tròn xoay chờ API
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary)),
          );
        } else if (state is BookingCreatedSuccess) {
          // Tắt vòng tròn xoay
          Navigator.of(context, rootNavigator: true).pop();
          // Hiện thông báo thành công
          _showSuccessDialog(context);
        } else if (state is BookingError) {
          // Tắt vòng tròn xoay
          Navigator.of(context, rootNavigator: true).pop();
          // Hiện lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text('Thanh toán', style: GoogleFonts.dmSans(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildInfoCard(days, total),
              const SizedBox(height: 24),
              _buildQRSection(total),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // CHỈ CẦN GỬI EVENT (BlocListener ở trên sẽ tự động bắt và hiện popup)
                    context.read<BookingBloc>().add(CreateBookingEvent(
                          roomId: roomId,
                          checkInDate: checkInDate,
                          checkOutDate: checkOutDate,
                          guestCount: 1,
                          paidAmount: total.toDouble(),
                          paymentMethod: 'BankTransfer',
                          note: 'Thanh toán chuyển khoản qua QR',
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Xác nhận đã chuyển khoản', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRSection(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
      child: Column(
        children: [
          Text('Quét mã để thanh toán', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Vui lòng chuyển đúng số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total)}', textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.grey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.greenPrimary.withOpacity(0.2)), borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'Assets/images/QR.png',
                width: 200, height: 200, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2_rounded, size: 200, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Nội dung: Đặt phòng $roomId', style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.greenPrimary)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(int days, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.greenPrimary, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(children: [const Icon(Icons.hotel, color: Colors.white), const SizedBox(width: 12), Text(hotelName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
          const Divider(color: Colors.white24, height: 32),
          _rowInfo('Loại phòng', roomType),
          _rowInfo('Số đêm', '$days đêm'),
          _rowInfo('Tổng thanh toán', NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total), isPrice: true),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String val, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(val, style: TextStyle(color: Colors.white, fontWeight: isPrice ? FontWeight.bold : FontWeight.normal, fontSize: isPrice ? 18 : 14)),
      ]),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 20),
            Text('Đã gửi yêu cầu thành công!', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1E293B)), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Yêu cầu đặt phòng của bạn đã được ghi nhận. Khách sạn đang kiểm tra giao dịch và sẽ duyệt đơn.', textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Chuyển về màn hình MainNavScreen và load thẳng vào Tab Đặt phòng (initialIndex: 1)
                  // Thao tác này xóa lịch sử màn hình, bắt buộc app phải load lại API mới nhất
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavScreen(
                        initialIndex: 1,
                        initialBookingTab: 1, // Tab Chờ duyệt
                      ),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Đồng ý', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}