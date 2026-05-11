import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/data/models/auth_session_model.dart'; 
import 'edit_profile_screen.dart';
import '../../../../core/constants/app_colors.dart';

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
    if (session != null) {
      setState(() {
        _fullName = session.fullName;
        _email = session.email;
        _roles = session.roles; // Sửa lỗi: Model dùng roles (số nhiều)
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Đăng xuất?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn thoát ứng dụng không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      // Nếu logout() đỏ, Bảo hãy đổi thành clear() hoặc tên hàm xóa session trong auth_storage.dart nhé
      await _authStorage.clear(); 
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuCard([
                      _MenuItem(icon: Icons.person_outline_rounded, title: 'Chỉnh sửa trang cá nhân', onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                        _loadProfile();
                      }),
                      _MenuItem(icon: Icons.history_rounded, title: 'Lịch sử đặt phòng', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                      }),
                    ]),
                    const SizedBox(height: 20),
                    _buildMenuCard([
                      _MenuItem(icon: Icons.security_rounded, title: 'Quyền riêng tư & Bảo mật', onTap: () {}),
                      _MenuItem(icon: Icons.help_outline_rounded, title: 'Trung tâm trợ giúp', onTap: () {}),
                    ]),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.greenPrimary, Color(0xFF23B97A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(radius: 50, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, size: 50, color: AppColors.greenPrimary)),
          ),
          const SizedBox(height: 16),
          Text(_fullName, style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(_email, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _roles.map((r) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(height: 1, indent: 60, color: Color(0xFFF5F7F6)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _logout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 10),
            Text('Đăng xuất', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.greenPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.greenPrimary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A2B24))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }
}