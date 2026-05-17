import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../injection.dart' as di;
import '../bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/auth_session_model.dart';
import '../../../shell/presentation/screens/main_nav_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final AuthStorage _authStorage = AuthStorage();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isObsecure = true;
  String? _emailError;
  String? _passError;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _emailError = _emailController.text.isEmpty
          ? 'Vui lòng nhập email'
          : null;
      _passError = _passController.text.isEmpty
          ? 'Vui lòng nhập mật khẩu'
          : null;
      _formError = null;
    });

    if (_emailError != null || _passError != null) return;

    context.read<AuthBloc>().add(
      LoginEvent(email: _emailController.text, password: _passController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            await _authStorage.saveSession(
              state.authEntity as AuthSessionModel,
            );
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            setState(() {
              _emailError = ' ';
              _passError = ' ';
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
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset('Assets/images/logo.png', height: 90),
                    const SizedBox(height: 20),
                    Text(
                      'White Hotel',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      errorText: _emailError,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Mật khẩu',
                      controller: _passController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obsecure: _isObsecure,
                      errorText: _passError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      onToggle: () =>
                          setState(() => _isObsecure = !_isObsecure),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _formError!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text(
                        'Tạo tài khoản',
                        style: TextStyle(
                          color: AppColors.greenPrimary,
                          fontWeight: FontWeight.bold,
                        ),
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
