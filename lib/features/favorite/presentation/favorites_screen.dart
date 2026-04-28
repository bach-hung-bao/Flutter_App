import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../favorite/data/favorite_api_service.dart';
import '../../favorite/domain/usecases/get_favorites_usecase.dart';
import '../../favorite/domain/usecases/toggle_favorite_usecase.dart';
import '../../hotel/domain/entities/hotel_entity.dart';
import '../../shell/presentation/main_nav_screen.dart';
import '../../../core/constants/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final GetFavoritesUseCase _getFavorites;
  late final ToggleFavoriteUseCase _toggleFavorite;

  bool _isLoading = true;
  String? _error;
  List<HotelEntity> _favorites = [];

  @override
  void initState() {
    super.initState();
    final repo = FavoriteApiService();
    _getFavorites = GetFavoritesUseCase(repo);
    _toggleFavorite = ToggleFavoriteUseCase(repo);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _getFavorites.execute();
      if (mounted) {
        setState(() {
          _favorites = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // Xử lý xóa mượt mà (Optimistic Update)
  Future<void> _toggle(int hotelId) async {
    final previousFavorites = List<HotelEntity>.from(_favorites);

    setState(() {
      _favorites.removeWhere((h) => h.id == hotelId);
    });

    try {
      await _toggleFavorite.execute(hotelId);
    } catch (e) {
      if (mounted) {
        setState(() => _favorites = previousFavorites);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể bỏ yêu thích, vui lòng kiểm tra kết nối!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.greenPrimary, AppColors.greenMedium],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Yêu thích',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
            (route) => false,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.greenMedium),
            )
          : _error != null
              ? _buildError()
              : _favorites.isEmpty
                  ? _buildEmpty(context)
                  : RefreshIndicator(
                      color: AppColors.greenMedium,
                      onRefresh: _load,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _favorites.length,
                        itemBuilder: (_, i) => _HotelFavCard(
                          hotel: _favorites[i],
                          onRemove: () => _toggle(_favorites[i].id),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi kết nối',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF172B24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không thể tải dữ liệu, vui lòng thử lại.',
              style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenMedium,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _load,
              child: Text(
                'Thử lại',
                style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmpty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Khối Icon trái tim bo tròn hiện đại
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenMedium.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greenMedium.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 56,
                      color: AppColors.greenMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Chưa có yêu thích nào',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172B24),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Những khách sạn bạn yêu thích sẽ xuất hiện ở đây. Hãy khám phá và lưu lại những địa điểm tuyệt vời nhé!',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: const Color(0xFF6B7B75),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Nút Call to Action
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenMedium,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18), // Bo góc mượt
                    ),
                  ),
                  onPressed: () {
                    // Chuyển hướng về trang chủ
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Khám phá ngay',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60), // Nâng content lên trên một chút
            ],
          ),
        ),
      );
}

class _HotelFavCard extends StatelessWidget {
  final HotelEntity hotel;
  final VoidCallback onRemove;

  const _HotelFavCard({required this.hotel, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Tăng độ bo góc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Bóng đổ mềm hơn
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(
                    Icons.hotel,
                    size: 40,
                    color: Color(0xFF1A8F5C),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF1A2B24),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hotel.street != null) ...[
                      const SizedBox(height: 6),
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
                              hotel.street!,
                              style: GoogleFonts.dmSans(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}