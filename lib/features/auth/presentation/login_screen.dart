import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/dialog_utils.dart';
import '../data/auth_mock_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMockService _service = AuthMockService();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObsecure = true;
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Vui lòng nhập email' : null;
      _passError = _passController.text.isEmpty ? 'Vui lòng nhập mật khẩu' : null;
    });

    if (_emailError != null || _passError != null) return;

    setState(() => _isLoading = true);
    bool success = await _service.login(_emailController.text, _passController.text);
    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog('Đăng nhập thành công!', 'Chào mừng bạn quay lại White Hotel.');
    } else {
      setState(() {
        _emailError = ' '; // Báo đỏ ô nhập
        _passError = 'Tài khoản hoặc mật khẩu không chính xác';
      });
    }
  }

  void _showSuccessDialog(String title, String desc) {
    DialogUtils.showSuccessDialog(
      context: context, 
      title: title, 
      desc: desc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              children: [
                Image.asset('Assets/images/logo.png', height: 90),
                const SizedBox(height: 20),
                Text(
                  'White Hotel', 
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.brownAccent),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Email', 
                  controller: _emailController, 
                  icon: Icons.email_outlined, 
                  errorText: _emailError,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Mật khẩu', 
                  controller: _passController, 
                  icon: Icons.lock_outline, 
                  isPassword: true, 
                  obsecure: _isObsecure, 
                  errorText: _passError, 
                  onToggle: () => setState(() => _isObsecure = !_isObsecure),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen())),
                    child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.brownAccent)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                  child: const Text('Tạo tài khoản', style: TextStyle(color: AppColors.greenPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}