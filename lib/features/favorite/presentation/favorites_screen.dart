import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../favorite/data/favorite_api_service.dart';
import '../../favorite/domain/usecases/get_favorites_usecase.dart';
import '../../favorite/domain/usecases/toggle_favorite_usecase.dart';
import '../../hotel/domain/entities/hotel_entity.dart';

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
    setState(() { _isLoading = true; _error = null; });
    try {
      final items = await _getFavorites.execute();
      if (mounted) setState(() { _favorites = items; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  // ĐÃ SỬA: Xử lý xóa mượt mà (Optimistic Update)
  Future<void> _toggle(int hotelId) async {
    // 1. Copy lại danh sách hiện tại để phòng hờ gọi API thất bại
    final previousFavorites = List<HotelEntity>.from(_favorites);

    // 2. Xóa ngay lập tức trên UI để tạo cảm giác mượt mà
    setState(() {
      _favorites.removeWhere((h) => h.id == hotelId);
    });

    try {
      // 3. Gọi API ngầm ở dưới
      await _toggleFavorite.execute(hotelId);
    } catch (e) {
      // 4. Nếu API lỗi (rớt mạng...), khôi phục lại dữ liệu và báo lỗi
      if (mounted) {
        setState(() => _favorites = previousFavorites);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể bỏ yêu thích, vui lòng kiểm tra kết nối!'),
            backgroundColor: Colors.red,
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
        backgroundColor: AppColors.greenPrimary,
        title: Text('Yêu thích',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _favorites.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
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

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.wifi_off, size: 52, color: AppColors.brownLight),
    const SizedBox(height: 12),
    Text('Không tải được', style: AppTextStyles.bodyMedium),
    TextButton(onPressed: _load, child: const Text('Thử lại')),
  ]));

  Widget _buildEmpty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.favorite_border, size: 80, color: AppColors.greenLight),
    const SizedBox(height: 20),
    Text('Chưa có khách sạn yêu thích', style: AppTextStyles.h3),
    const SizedBox(height: 8),
    Text('Thêm yêu thích từ trang chủ nhé!',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
  ]));
}

class _HotelFavCard extends StatelessWidget {
  final HotelEntity hotel;
  final VoidCallback onRemove;
  const _HotelFavCard({required this.hotel, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image placeholder
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 110,
            width: double.infinity,
            color: AppColors.greenSurface,
            child: const Icon(Icons.hotel, size: 48, color: AppColors.greenPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: Text(
            hotel.name,
            style: AppTextStyles.labelLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hotel.street != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(hotel.street!,
                style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: onRemove,
            tooltip: 'Bỏ yêu thích',
          ),
        ),
      ]),
    );
  }
}