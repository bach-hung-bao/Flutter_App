import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    setState(() {
      _emailError = _emailController.text.isEmpty
          ? 'Vui lòng nhập email'
          : null;
    });

    if (_emailError != null) return;

    // API chưa có – hiển thị thông báo bảo trì
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.brownAccent),
            const SizedBox(width: 8),
            Text('Thông báo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Tính năng khôi phục mật khẩu đang được bảo trì,\n'
          'vui lòng liên hệ hotline: 1800 1234',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Đã hiểu',
                style: GoogleFonts.poppins(
                    color: AppColors.greenPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.asset(
                  'Assets/images/logo.png',
                  height: 95,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    color: AppColors.greenPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Quên mật khẩu',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập email của bạn để nhận hướng\ndẫn khôi phục mật khẩu.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Địa chỉ Email',
                  hint: 'example@email.com',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Gửi yêu cầu',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 12,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Quay lại trang Đăng nhập',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
