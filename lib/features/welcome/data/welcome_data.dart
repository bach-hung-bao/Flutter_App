// lib/views/welcome_data.dart
class WelcomeItem {
  final String title;
  final String description;
  final String backgroundImage; 

  WelcomeItem({
    required this.title,
    required this.description,
    required this.backgroundImage,
  });
}

// Danh sách 3 màn hình giới thiệu
List<WelcomeItem> welcomeItems = [
  // Màn hình 1: Giữ nguyên như ý bạn
  WelcomeItem(
    title: 'Chào mừng đến với\nWhite Hotel',
    description: 'Trải nghiệm sự sang trọng và dịch vụ đẳng\ncấp thế giới ngay trong tầm tay bạn.',
    backgroundImage: 'Assets/images/splash_bg.png', 
  ),
  // Màn hình 2: Giới thiệu không gian (Dùng ảnh splash_bg1.png)
  WelcomeItem(
    title: 'Không Gian Sống\nHoàn Mỹ',
    description: 'Tận hưởng thiết kế hiện đại, tinh tế cùng\ntiện nghi nội thất chuẩn 5 sao.',
    backgroundImage: 'Assets/images/splash_bg1.png', 
  ),
  // Màn hình 3: Giới thiệu tính năng app (Dùng ảnh splash_bg2.png)
  WelcomeItem(
    title: 'Smart Parking &\nQuản Lý Thông Minh',
    description: 'Tích hợp AI nhận diện biển số, đặt phòng\nvà gửi xe an toàn chỉ với một chạm.',
    backgroundImage: 'Assets/images/splash_bg2.png', 
  ),
];