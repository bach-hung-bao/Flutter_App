import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../booking/presentation/my_bookings_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/auth_storage.dart';
import '../../auth/presentation/login_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.greenPrimary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.greenPrimary, AppColors.brownAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                            fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _fullName.isNotEmpty ? _fullName : 'Người dùng',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Info card
                _Card(children: [
                  _InfoRow(Icons.email_outlined, 'Email', _email.isNotEmpty ? _email : '--'),
                  _InfoRow(Icons.badge_outlined, 'Vai trò',
                      _roles.isNotEmpty ? _roles.join(', ') : 'Customer'),
                ]),
                const SizedBox(height: 20),

                // Menu items
                _Card(children: [
                  _MenuItem(
                    Icons.book_outlined, 
                    'Lịch sử đặt phòng', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                      );
                    },
                  ),
                  _MenuItem(Icons.star_outline, 'Đánh giá của tôi', onTap: () {
                    // TODO: Chuyển hướng sang màn hình MyReviewsScreen sau này
                  }),
                  _MenuItem(Icons.help_outline, 'Hỗ trợ', onTap: () {
                    // TODO: Mở màn hình Hỗ trợ
                  }),
                ]),
                const SizedBox(height: 20),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: Text('Đăng xuất', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brownAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(color: AppColors.divider, height: 1, indent: 56)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 22, color: AppColors.greenPrimary),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.labelMedium),
          Text(value, style: AppTextStyles.bodyMedium),
        ])),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brownAccent),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
