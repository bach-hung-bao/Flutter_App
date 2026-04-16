import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // BẮT BUỘC THÊM DÒNG NÀY: Để lấy cấu hình cho phép dùng chuột kéo trên Web
import '../../auth/presentation/login_screen.dart'; 
import '../data/welcome_data.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; 

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FIX LỖI VUỐT: Bọc PageView trong ScrollConfiguration để cho phép kéo bằng chuột
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch, // Cho phép vuốt trên điện thoại
                PointerDeviceKind.mouse, // ĐÂY RỒI: Cho phép dùng chuột kéo trên Web
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: welcomeItems.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  welcomeItems[index].backgroundImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          ),

          // LỚP GIỮA: Phủ một lớp đen mờ
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black12,
                    Colors.black54,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // LỚP TRÊN CÙNG
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  const Spacer(), 

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(_currentPage),
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'W',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'EST. 1994',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        Text(
                          welcomeItems[_currentPage].title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          welcomeItems[_currentPage].description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E293B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Bắt đầu ngay',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 2. FIX LỖI CLICK DẤU CHẤM: Truyền số thứ tự (index) vào
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      welcomeItems.length,
                      (index) => _buildDot(index: index, isActive: _currentPage == index),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'PREMIER HOSPITALITY EXPERIENCE',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cập nhật hàm _buildDot để gắn sự kiện Click
  Widget _buildDot({required int index, required bool isActive}) {
    return GestureDetector(
      onTap: () {
        // Lệnh điều khiển chuyển trang mượt mà khi người dùng bấm vào dấu chấm
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Padding(
        // Dùng padding để làm cho "vùng bấm chuột" rộng ra một chút, dễ bấm hơn
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          width: isActive ? 24 : 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}