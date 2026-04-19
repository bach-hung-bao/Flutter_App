import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/auth_mock_service.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthMockService _service = AuthMockService();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Vui lòng nhập email' : null;
    });

    if (_emailError != null) return;

    setState(() => _isLoading = true);
    bool success = await _service.sendOtp(_emailController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtpScreen()),
      );
    }
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
                  color: Colors.black.withOpacity(0.06),
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
                    color: AppColors.greenPrimary.withOpacity(0.1),
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
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Gửi yêu cầu',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Quay lại trang Đăng nhập',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
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