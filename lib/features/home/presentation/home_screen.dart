import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/storage/auth_storage.dart';
import '../data/repositories/home_api_service.dart';
import '../domain/entities/hotel_recommendation_entity.dart';
import '../domain/entities/province_entity.dart';
import '../domain/usecases/get_home_recommendations_usecase.dart';
import '../domain/usecases/get_provinces_usecase.dart';
import '../../hotel/presentation/hotel_detail_screen.dart';


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
    // ĐÃ SỬA: Gọi đúng HomeApiService
    final repo = HomeApiService();
    _getRecommendations = GetHomeRecommendationsUseCase(repo);
    _getProvinces = GetProvincesUseCase(repo);
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final session = await _authStorage.getSession();
      final provinces = await _getProvinces.execute(pageSize: 8);
      
      // Mặc định _selectedProvince = null, gọi API lấy "Tất cả"
      final hotels = await _getRecommendations.execute(
        topK: 10,
        province: _selectedProvince?.name,
        accessToken: session?.accessToken,
      );
      
      if (!mounted) return;
      
      setState(() {
        _fullName = session?.fullName ?? 'Bạn';
        _provinces = provinces;
        // ĐÃ XÓA: Đoạn code gán mặc định _selectedProvince = provinces.first
        _hotels = hotels;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _refreshHotels({ProvinceEntity? province}) async {
    setState(() { _selectedProvince = province; _isRefreshing = true; _error = null; });
    try {
      final session = await _authStorage.getSession();
      final hotels = await _getRecommendations.execute(
        topK: 10,
        province: _selectedProvince?.name,
        accessToken: session?.accessToken,
      );
      if (!mounted) return;
      setState(() { _hotels = hotels; _isRefreshing = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isRefreshing = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadHomeData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildProvinceSection()),
            SliverToBoxAdapter(child: _buildHotelsHeader()),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverToBoxAdapter(child: _buildError())
            else if (_hotels.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.greenPrimary, AppColors.greenMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Xin chào, $_fullName 👋',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Khám phá khách sạn tuyệt vời hôm nay',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hotel, color: Colors.white, size: 28),
          ),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: [
          _Chip(Icons.home_work_outlined, '${_hotels.length} gợi ý'),
          _Chip(Icons.public_outlined, '${_provinces.length} tỉnh'),
          _Chip(Icons.verified_outlined, 'AI powered'),
        ]),
      ]),
    );
  }

  Widget _buildProvinceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Chọn điểm đến', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _provinces.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
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
      ]),
    );
  }

  Widget _buildHotelsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(children: [
        Text('Gợi ý cho bạn', style: AppTextStyles.h3),
        const Spacer(),
        if (_isRefreshing)
          const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
      ]),
    );
  }

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text('Không tải được dữ liệu', style: AppTextStyles.bodyMedium)),
        TextButton(onPressed: _loadHomeData, child: const Text('Thử lại')),
      ]),
    ),
  );

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(child: Column(children: [
      Icon(Icons.hotel_outlined, size: 72, color: AppColors.greenLight),
      const SizedBox(height: 16),
      Text('Chưa có gợi ý nào', style: AppTextStyles.bodyMedium),
    ])),
  );

  Widget _buildHotelCard(HotelRecommendationEntity hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelDetailScreen(
            hotelId: hotel.hotelId,
            hotelName: hotel.name,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                  ? Image.network(hotel.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback())
                  : _imageFallback(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hotel.name, style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              if (hotel.province != null)
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.brownLight),
                  const SizedBox(width: 4),
                  Text(
                    '${hotel.ward ?? ''}${hotel.ward != null && hotel.province != null ? ', ' : ''}${hotel.province ?? ''}',
                    style: AppTextStyles.bodySmall,
                  ),
                ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text((hotel.averageRating ?? 0).toStringAsFixed(1),
                    style: AppTextStyles.labelLarge),
                const SizedBox(width: 16),
                const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.brownLight),
                const SizedBox(width: 4),
                Text('${hotel.roomCount} phòng', style: AppTextStyles.bodySmall),
                const Spacer(),
                if (hotel.avgRoomPrice != null)
                  Text(
                    '${_money(hotel.avgRoomPrice!)} đ',
                    style: AppTextStyles.price.copyWith(fontSize: 14),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: AppColors.greenSurface,
    child: const Center(child: Icon(Icons.hotel, size: 52, color: AppColors.greenPrimary)),
  );

  String _money(double v) => v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ProvinceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ProvinceChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenPrimary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.greenPrimary.withValues(alpha: 0.3), blurRadius: 8)]
              : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}