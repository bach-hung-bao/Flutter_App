import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection.dart' as di;
import '../bloc/home_bloc.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../notification/presentation/screens/notifications_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/hotel_recommendation_entity.dart';
import '../../domain/entities/province_entity.dart';
import '../../../hotel/presentation/screens/hotel_detail_screen.dart';

const _kGreen = AppColors.greenPrimary;
const _kGreenMedium = AppColors.greenMedium;
const _kSurface = AppColors.scaffoldBg;
const _kTextPrimary = Color(0xFF172B24);
const _kTextSec = Color(0xFF6B7B75);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HomeBloc>()..add(LoadHomeDataEvent()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            bool isLoading = state is HomeInitial || state is HomeLoading;
            bool isRefreshing = false;
            String? error;
            String fullName = 'Bạn';
            List<ProvinceEntity> provinces = [];
            ProvinceEntity? selectedProvince;
            List<HotelRecommendationEntity> hotels = [];

            if (state is HomeError) {
              error = state.message;
            } else if (state is HomeLoaded) {
              fullName = state.fullName;
              provinces = state.provinces;
              hotels = state.hotels;
              selectedProvince = state.selectedProvince;
              isRefreshing = state.isRefreshing;
            }

            return RefreshIndicator(
              color: _kGreen,
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildTopSection(context, fullName),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: _buildQuickCategories(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: _buildProvinceSection(
                      context,
                      provinces,
                      selectedProvince,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHotelsHeader(isRefreshing)),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: _kGreen),
                      ),
                    )
                  else if (error != null)
                    SliverToBoxAdapter(child: _buildError(context))
                  else if (hotels.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildHotelCard(context, hotels[i]),
                          childCount: hotels.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, String fullName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
                      'Xin chào, $fullName 👋',
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
                  onTap: () => _goToSearch(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                ),
                _buildSearchRow(
                  icon: Icons.calendar_month_outlined,
                  title: 'Ngày lưu trú',
                  subtitle: 'Hôm nay - Ngày mai',
                  onTap: () => _goToSearch(context),
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
                    onPressed: () => _goToSearch(context),
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

  void _goToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCategoryItem(
            context,
            'Khách sạn',
            Icons.domain_rounded,
            const Color(0xFFE3F2FD),
            Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildCategoryItem(
            context,
            'Resort',
            Icons.pool_rounded,
            const Color(0xFFF3E5F5),
            Colors.purple,
          ),
          const SizedBox(width: 16),
          _buildCategoryItem(
            context,
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
    BuildContext context,
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

  Widget _buildProvinceSection(
    BuildContext context,
    List<ProvinceEntity> provinces,
    ProvinceEntity? selectedProvince,
  ) {
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
              itemCount: provinces.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedProvince == null;
                  return _ProvinceChip(
                    label: 'Tất cả',
                    isSelected: isSelected,
                    onTap: () {
                      context.read<HomeBloc>().add(
                        RefreshHotelsEvent(province: null),
                      );
                    },
                  );
                }
                final p = provinces[index - 1];
                return _ProvinceChip(
                  label: p.name,
                  isSelected: selectedProvince?.id == p.id,
                  onTap: () {
                    context.read<HomeBloc>().add(
                      RefreshHotelsEvent(province: p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsHeader(bool isRefreshing) {
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
          if (isRefreshing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
            ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) => Padding(
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
          TextButton(
            onPressed: () => context.read<HomeBloc>().add(LoadHomeDataEvent()),
            child: const Text('Thử lại'),
          ),
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

  Widget _buildHotelCard(
    BuildContext context,
    HotelRecommendationEntity hotel,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelDetailScreen(
            hotelId: hotel.hotelId,
            hotelName: hotel.name,
            rating: hotel.averageRating,
          ),
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
                      _buildStarRow(hotel.averageRating ?? 0),
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

  Widget _buildStarRow(double rating) {
    final clamped = rating.clamp(0, 5);
    final filled = clamped.round();

    return Row(
      children: [
        ...List.generate(5, (index) {
          final isFilled = index < filled;
          return Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFilled ? Colors.amber : const Color(0xFFB0B8B3),
            size: 16,
          );
        }),
        const SizedBox(width: 6),
        Text(
          clamped.toStringAsFixed(1),
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _money(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

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
