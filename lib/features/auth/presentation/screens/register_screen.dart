import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../injection.dart' as di;
import '../bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/validators.dart'; 

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: const _RegisterScreenContent(),
    );
  }
}

class _RegisterScreenContent extends StatefulWidget {
  const _RegisterScreenContent();

  @override
  State<_RegisterScreenContent> createState() => _RegisterScreenContentState();
}

class _RegisterScreenContentState extends State<_RegisterScreenContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obsecurePass = true;
  bool _obsecureConfirmPass = true;
  bool _agree = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passError;
  String? _confirmPassError;
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Vui lòng nhập họ tên' : null;
      _emailError = Validators.validateEmail(_emailController.text);
      _phoneError = _phoneController.text.isEmpty ? 'Vui lòng nhập số điện thoại' : null;
      _passError = Validators.validatePassword(_passController.text);
      _confirmPassError = (_confirmPassController.text != _passController.text) 
          ? 'Mật khẩu xác nhận không khớp' : null;
      _formError = null;
    });

    if (_nameError != null || _emailError != null || _phoneError != null || _passError != null || _confirmPassError != null) return;

    if (!_agree) {
      setState(() => _formError = 'Vui lòng đồng ý với Điều khoản dịch vụ');
      return;
    }

    final nameParts = _splitName(_nameController.text);

    context.read<AuthBloc>().add(RegisterEvent(
      firstName: nameParts.firstName,
      lastName: nameParts.lastName,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passController.text,
    ));
  }

  ({String firstName, String lastName}) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      final fallback = parts.isEmpty ? 'User' : parts.first;
      return (firstName: fallback, lastName: fallback);
    }
    return (firstName: parts.sublist(1).join(' '), lastName: parts.first);
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            DialogUtils.showSuccessDialog(
              context: context,
              title: 'Đăng ký thành công!',
              desc: 'Tài khoản của bạn đã được tạo. Hãy đăng nhập để bắt đầu.',
              buttonText: 'Quay lại đăng nhập',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
          } else if (state is AuthError) {
            setState(() {
              _formError = state.message;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return SingleChildScrollView(
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
                    Image.asset('Assets/images/logo.png', height: 95, fit: BoxFit.contain),
                    const SizedBox(height: 25),
                    Text('White Hotel', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brownAccent)),
                    const SizedBox(height: 40),

                    CustomTextField(label: 'Họ và tên', controller: _nameController, icon: Icons.person_outline, errorText: _nameError, textInputAction: TextInputAction.next),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Địa chỉ Email', controller: _emailController, icon: Icons.email_outlined, errorText: _emailError, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Số điện thoại', controller: _phoneController, icon: Icons.phone_outlined, errorText: _phoneError, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Mật khẩu', controller: _passController, icon: Icons.lock_outline, isPassword: true, obsecure: _obsecurePass, errorText: _passError, onToggle: () => setState(() => _obsecurePass = !_obsecurePass), textInputAction: TextInputAction.next),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Xác nhận mật khẩu', controller: _confirmPassController, icon: Icons.vpn_key_outlined, isPassword: true, obsecure: _obsecureConfirmPass, errorText: _confirmPassError, onToggle: () => setState(() => _obsecureConfirmPass = !_obsecureConfirmPass), textInputAction: TextInputAction.done),
                    
                    const SizedBox(height: 25),
                    if (_formError != null) ...[
                      Text(_formError!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(value: _agree, activeColor: AppColors.greenPrimary, onChanged: (v) => setState(() => _agree = v ?? false)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]))),
                      ],
                    ),
                    
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng ký ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}