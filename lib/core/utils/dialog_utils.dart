import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class DialogUtils {
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String desc,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title, 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18), 
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              desc, 
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed ?? () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                buttonText, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
