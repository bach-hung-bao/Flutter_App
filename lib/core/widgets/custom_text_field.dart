import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData icon;
  final bool isPassword;
  final bool obsecure;
  final String? errorText;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  
  // CÁC THAM SỐ MỚI ĐÃ ĐƯỢC THÊM VÀO ĐÂY:
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    required this.icon,
    this.isPassword = false,
    this.obsecure = false,
    this.errorText,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    // THÊM VÀO CONSTRUCTOR:
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obsecure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          // GẮN CÁC THAM SỐ MỚI VÀO ĐÂY:
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: AppColors.brownAccent),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obsecure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[500],
                    ),
                    onPressed: onToggle,
                  )
                : null,
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.greenPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}