import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../search/presentation/search_screen.dart';
import '../../notification/presentation/notifications_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/auth_storage.dart';
import '../data/repositories/home_api_service.dart';
import '../domain/entities/hotel_recommendation_entity.dart';
import '../domain/entities/province_entity.dart';
import '../domain/usecases/get_home_recommendations_usecase.dart';
import '../domain/usecases/get_provinces_usecase.dart';
import '../../hotel/presentation/hotel_detail_screen.dart';

// --- Bảng màu chuẩn ---
const _kGreen = AppColors.greenPrimary;
const _kGreenMedium = AppColors.greenMedium;
const _kSurface = AppColors.scaffoldBg;
const _kTextPrimary = Color(0xFF172B24);
const _kTextSec = Color(0xFF6B7B75);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetHomeRecommendationsUseCase _getRecommendations;
  late final GetProvincesUseCase _getProvinces;
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String _fullName = '';
  List<ProvinceEntity> _provinces = [];
  ProvinceEntity? _selectedProvince;
  List<HotelRecommendationEntity> _hotels = [];

  @override
  void initState() {
    super.initState();
    final repo = HomeApiService();
    _getRecommendations = GetHomeRecommendationsUseCase(repo);
    _getProvinces = GetProvincesUseCase(repo);
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = await _authStorage.getSession();
      final provinces = await _getProvinces.execute(pageSize: 8);

      final hotels = await _getRecommendations.execute(
        topK: 12,
        province: _selectedProvince?.name,
        accessToken: session?.accessToken,
      );

      if (!mounted) return;

      setState(() {
        _fullName = session?.fullName ?? 'Bạn';
        _provinces = provinces;
        _hotels = hotels;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshHotels({ProvinceEntity? province}) async {
    setState(() {
      _selectedProvince = province;
      _isRefreshing = true;
      _error = null;
    });
    try {
      final session = await _authStorage.getSession();
      final hotels = await _getRecommendations.execute(
        topK: 12,
        province: _selectedProvince?.name,
        accessToken: session?.accessToken,
      );
      if (!mounted) return;
      setState(() {
        _hotels = hotels;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: RefreshIndicator(
          color: _kGreen,
          onRefresh: _loadHomeData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildTopSection(), // Banner + Form Search đè lên
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _buildQuickCategories(), // Các nút: Khách sạn, Resort...
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: _buildProvinceSection(), // Chọn địa điểm
              ),
              SliverToBoxAdapter(
                child: _buildHotelsHeader(), // Tiêu đề "Gợi ý cho bạn"
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _kGreen),
                  ),
                )
              else if (_error != null)
                SliverToBoxAdapter(child: _buildError())
              else if (_hotels.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildHotelCard(_hotels[i]),
                      childCount: _hotels.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 1. Header & Khung Tìm Kiếm Đặt Phòng ─────────────────────────────────
  Widget _buildTopSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Gradient Xanh
        Container(
          height: 240,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kGreen, _kGreenMedium],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $_fullName 👋',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Khám phá kỳ nghỉ\ntuyệt vời của bạn',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút Thông báo
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Khung Tìm Kiếm Nhô Lên (Overlap)
        Padding(
          padding: const EdgeInsets.only(top: 160, left: 20, right: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSearchRow(
                  icon: Icons.location_on_outlined,
                  title: 'Bạn muốn đi đâu?',
                  subtitle: 'Tên khách sạn, điểm đến...',
                  onTap: _goToSearch,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                ),
                _buildSearchRow(
                  icon: Icons.calendar_month_outlined,
                  title: 'Ngày lưu trú',
                  subtitle: 'Hôm nay - Ngày mai',
                  onTap: _goToSearch,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _goToSearch,
                    child: Text(
                      'Tìm kiếm khách sạn',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(fontSize: 13, color: _kTextSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  // ─── 2. Danh Mục Khám Phá Nhanh ───────────────────────────────────────────
  Widget _buildQuickCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCategoryItem(
            'Khách sạn',
            Icons.domain_rounded,
            const Color(0xFFE3F2FD),
            Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildCategoryItem(
            'Resort',
            Icons.pool_rounded,
            const Color(0xFFF3E5F5),
            Colors.purple,
          ),
          const SizedBox(width: 16),
          _buildCategoryItem(
            'Homestay',
            Icons.cottage_rounded,
            const Color(0xFFFFF3E0),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng đang phát triển')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Điểm Đến Phổ Biến (Tỉnh Thành) ───────────────────────────────────
  Widget _buildProvinceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khám phá theo khu vực',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _provinces.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedProvince == null;
                  return _ProvinceChip(
                    label: 'Tất cả',
                    isSelected: isSelected,
                    onTap: () => _refreshHotels(province: null),
                  );
                }
                final p = _provinces[index - 1];
                return _ProvinceChip(
                  label: p.name,
                  isSelected: _selectedProvince?.id == p.id,
                  onTap: () => _refreshHotels(province: p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Gợi Ý Khách Sạn ──────────────────────────────────────────────────
  Widget _buildHotelsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          Text(
            'Đề xuất cho bạn',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const Spacer(),
          if (_isRefreshing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
            ),
        ],
      ),
    );
  }

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Không thể kết nối. Vui lòng thử lại!',
              style: GoogleFonts.dmSans(color: Colors.redAccent),
            ),
          ),
          TextButton(onPressed: _loadHomeData, child: const Text('Thử lại')),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có khách sạn nào ở khu vực này.',
            style: GoogleFonts.dmSans(color: _kTextSec, fontSize: 15),
          ),
        ],
      ),
    ),
  );

  Widget _buildHotelCard(HotelRecommendationEntity hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              HotelDetailScreen(hotelId: hotel.hotelId, hotelName: hotel.name),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                    ? Image.network(
                        hotel.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (hotel.averageRating ?? 0).toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hotel.province != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${hotel.ward ?? ''}${hotel.ward != null && hotel.province != null ? ', ' : ''}${hotel.province ?? ''}',
                            style: GoogleFonts.dmSans(
                              color: _kTextSec,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        size: 16,
                        color: _kTextSec,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${hotel.roomCount} phòng',
                        style: GoogleFonts.dmSans(
                          color: _kTextSec,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      if (hotel.avgRoomPrice != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Chỉ từ',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _kTextSec,
                              ),
                            ),
                            Text(
                              '${_money(hotel.avgRoomPrice!)} đ',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _kGreen,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFE8F5E9),
    child: const Center(
      child: Icon(Icons.hotel_rounded, size: 48, color: _kGreen),
    ),
  );

  String _money(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ─── Widget Phụ Trợ ──────────────────────────────────────────────────────────
class _ProvinceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ProvinceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? _kGreen : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: isSelected ? Colors.white : _kTextPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
