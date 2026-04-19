import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_mock_service.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthMockService _service = AuthMockService();
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  
  bool _isLoading = false;
  String? _otpError;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleVerify() async {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _otpError = 'Vui lòng nhập đủ 6 chữ số');
      return;
    }
    
    setState(() {
      _otpError = null;
      _isLoading = true;
    });
    
    bool success = await _service.verifyOtp(code);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    } else {
      setState(() => _otpError = 'Mã xác thực không đúng. Hãy thử 112233');
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_outlined,
                    color: AppColors.greenPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Nhập mã xác thực',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã xác thực đã được gửi đến email của bạn\nuser@whitehotel.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOtpBox(context, index)),
                ),
                
                if (_otpError != null) ...[
                  const SizedBox(height: 15),
                  Text(_otpError!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 13)),
                ],

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Xác thực',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                    children: const [
                      TextSpan(text: 'Gửi lại mã '),
                      TextSpan(text: '(sau 60s)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user, color: AppColors.greenPrimary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'KẾT NỐI BẢO MẬT BỞI WHITE HOTEL',
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      height: 55,
      width: 45, 
      child: TextField(
        controller: _controllers[index],
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1), 
          FilteringTextInputFormatter.digitsOnly, 
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _otpError != null ? Colors.red : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _otpError != null ? Colors.red : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.greenPrimary, width: 2), 
          ),
        ),
      ),
    );
  }
}