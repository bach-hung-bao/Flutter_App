import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/welcome/presentation/welcome_screen.dart'; 

void main() {
  runApp(const WhiteHotelApp());
}

class WhiteHotelApp extends StatelessWidget {
  const WhiteHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt cái chữ DEBUG màu đỏ góc phải
      title: 'White Hotel',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Dùng font Poppins cho toàn bộ app
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // ĐÂY LÀ ĐIỂM MẤU CHỐT: Gọi Màn hình Chào mừng lên đầu tiên!
      home: const WelcomeScreen(), 
    );
  }
}