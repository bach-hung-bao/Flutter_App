import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/dialog_utils.dart';
import '../data/auth_mock_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthMockService _service = AuthMockService();
  
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _obsecureNewPass = true;
  bool _obsecureConfirmPass = true;
  
  String? _newPassError;
  String? _confirmPassError;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    setState(() {
      _newPassError = _newPassController.text.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null;
      if (_confirmPassController.text.isEmpty) {
        _confirmPassError = 'Vui lòng xác nhận mật khẩu';
      } else if (_confirmPassController.text != _newPassController.text) {
        _confirmPassError = 'Mật khẩu xác nhận không khớp';
      } else {
        _confirmPassError = null;
      }
    });

    if (_newPassError != null || _confirmPassError != null) return;

    setState(() => _isLoading = true);
    bool success = await _service.resetPassword(_newPassController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      DialogUtils.showSuccessDialog(
        context: context,
        title: 'Đổi mật khẩu thành công!',
        desc: 'Bạn có thể sử dụng mật khẩu mới để đăng nhập vào White Hotel ngay bây giờ.',
        buttonText: 'Quay lại Đăng nhập',
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
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
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              children: [
                Image.asset('Assets/images/logo.png', height: 90),
                const SizedBox(height: 20),
                
                Text('Đặt lại mật khẩu', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('Vui lòng nhập mật khẩu mới để bảo vệ tài\nkhoản của bạn.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Mật khẩu mới', 
                  controller: _newPassController, 
                  icon: Icons.lock_outline, 
                  isPassword: true, 
                  obsecure: _obsecureNewPass, 
                  errorText: _newPassError,
                  onToggle: () => setState(() => _obsecureNewPass = !_obsecureNewPass)
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Xác nhận mật khẩu mới', 
                  controller: _confirmPassController, 
                  icon: Icons.vpn_key_outlined, 
                  isPassword: true, 
                  obsecure: _obsecureConfirmPass, 
                  errorText: _confirmPassError,
                  onToggle: () => setState(() => _obsecureConfirmPass = !_obsecureConfirmPass)
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Cập nhật mật khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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