import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../booking/presentation/my_bookings_screen.dart';
import '../../../core/storage/auth_storage.dart';
import '../../auth/presentation/login_screen.dart';
import 'edit_profile_screen.dart';
import '../../user/presentation/user_list_screen.dart';
import '../../../core/constants/app_colors.dart';

const _kGreen = AppColors.greenMedium;
const _kGreenDark = AppColors.greenPrimary;
const _kGreenAccent = AppColors.greenLight;
const _kGold = Colors.amber;
const _kSurface = AppColors.scaffoldBg;
const _kTextPrimary = AppColors.textPrimary;
const _kTextSecondary = AppColors.textSecondary;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthStorage _authStorage = AuthStorage();
  String _fullName = '';
  String _email = '';
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await _authStorage.getSession();
    if (session != null && mounted) {
      setState(() {
        _fullName = session.fullName;
        _email = session.email;
        _roles = session.roles;
      });
    }
  }

  Future<void> _logout() async {
    await _authStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                    Text(
                      'Tùy chọn',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(),
                    const SizedBox(height: 40),
                    _buildLogoutButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280, // Tăng thêm chiều cao để không bị chật
      pinned: true,
      backgroundColor: _kGreenDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            'Hồ sơ của tôi',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.greenPrimary, AppColors.greenMedium],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Hình tròn trang trí
            Positioned(
              left: -50,
              top: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: 20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: _kGreenAccent,
                      child: Text(
                        _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U',
                        style: GoogleFonts.dmSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: _kGold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _fullName.isNotEmpty ? _fullName : 'Người dùng',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email.isNotEmpty ? _email : '---',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                // Fix lỗi đè chữ: Thêm không gian trống đẩy cụm thông tin lên trên
                const SizedBox(height: 50), 
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bo góc mượt hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Bóng đổ mềm và mịn
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: _email.isNotEmpty ? _email : '--',
          ),
          const Divider(
            height: 1,
            indent: 72, // Lùi dải phân cách sát với chữ
            endIndent: 20,
            color: Color(0xFFF0F0F0),
          ),
          _buildInfoTile(
            icon: Icons.shield_outlined,
            title: 'Vai trò',
            subtitle: _roles.isNotEmpty ? _roles.join(', ') : 'Customer',
            iconColor: _kGold,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    final isAdmin = _roles.any((role) => role.toLowerCase() == 'admin');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person_outline,
            title: 'Chỉnh sửa hồ sơ',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result == true) {
                _loadProfile();
              }
            },
          ),
          const Divider(height: 1, indent: 72, endIndent: 20, color: Color(0xFFF0F0F0)),
          if (isAdmin)
            _buildMenuTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Quản lý người dùng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserListScreen()),
                );
              },
            ),
          if (isAdmin)
            const Divider(height: 1, indent: 72, endIndent: 20, color: Color(0xFFF0F0F0)),
          _buildMenuTile(
            icon: Icons.book_outlined,
            title: 'Lịch sử đặt phòng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 72, endIndent: 20, color: Color(0xFFF0F0F0)),
          _buildMenuTile(
            icon: Icons.star_outline_rounded,
            title: 'Đánh giá của tôi',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          const Divider(height: 1, indent: 72, endIndent: 20, color: Color(0xFFF0F0F0)),
          _buildMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Trung tâm hỗ trợ',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liên hệ Hotline: 1900 1234')),
              );
            },
          ),
          const Divider(height: 1, indent: 72, endIndent: 20, color: Color(0xFFF0F0F0)),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Cài đặt ứng dụng',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = _kGreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14), // Đổi thành bo góc vuông hiện đại
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: _kTextSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: _kGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFFB0B0B0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Nút bấm tròn trịa hiện đại
          ),
        ),
        onPressed: _logout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 22),
            const SizedBox(width: 10),
            Text(
              'Đăng xuất',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}