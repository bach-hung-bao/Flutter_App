import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/dialog_utils.dart';
import '../data/auth_mock_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthMockService _service = AuthMockService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool _obsecurePass = true;
  bool _obsecureConfirmPass = true;
  bool _agree = false;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmPassError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Vui lòng nhập họ tên' : null;
      _emailError = _emailController.text.isEmpty ? 'Vui lòng nhập email' : null;
      _passError = _passController.text.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null;
      if (_confirmPassController.text.isEmpty) {
        _confirmPassError = 'Vui lòng xác nhận mật khẩu';
      } else if (_confirmPassController.text != _passController.text) {
        _confirmPassError = 'Mật khẩu xác nhận không khớp';
      } else {
        _confirmPassError = null;
      }
    });

    if (_nameError != null || _emailError != null || _passError != null || _confirmPassError != null) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với Điều khoản dịch vụ!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _service.register(_emailController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      DialogUtils.showSuccessDialog(
        context: context,
        title: 'Đăng ký thành công!',
        desc: 'Tài khoản của bạn đã được tạo thành công. Tuyệt vời!',
        buttonText: 'Quay lại đăng nhập',
        onPressed: () {
          // Xóa dialog
          Navigator.pop(context);
          // Quay về trang login
          Navigator.pop(context);
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
                Text(
                  'White Hotel',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo tài khoản mới',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Họ và tên',
                  hint: 'Nguyễn Văn A',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  errorText: _nameError,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Địa chỉ Email',
                  hint: 'example@email.com',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Mật khẩu',
                  hint: '••••••••',
                  controller: _passController,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obsecure: _obsecurePass,
                  errorText: _passError,
                  onToggle: () => setState(() => _obsecurePass = !_obsecurePass),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Xác nhận mật khẩu',
                  hint: '••••••••',
                  controller: _confirmPassController,
                  icon: Icons.vpn_key_outlined,
                  isPassword: true,
                  obsecure: _obsecureConfirmPass,
                  errorText: _confirmPassError,
                  onToggle: () => setState(() => _obsecureConfirmPass = !_obsecureConfirmPass),
                ),
                const SizedBox(height: 25),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agree,
                        activeColor: AppColors.greenPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _agree = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                          children: const [
                            TextSpan(text: 'Tôi đồng ý với '),
                            TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: AppColors.greenPrimary, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' và '),
                            TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: AppColors.greenPrimary, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' của White Hotel.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Đăng ký ngay',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản? ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Đăng nhập tại đây', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.greenPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}