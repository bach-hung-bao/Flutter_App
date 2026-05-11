import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection.dart' as di;
import '../bloc/hotel_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/hotel_entity.dart';
import '../../../booking/presentation/screens/room_selection_screen.dart';

class HotelDetailScreen extends StatelessWidget {
  final int hotelId;
  final String hotelName;
  final double? rating;

  const HotelDetailScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HotelBloc>()..add(LoadHotelDetailEvent(hotelId)),
      child: _HotelDetailScreenContent(
        hotelName: hotelName,
        hotelId: hotelId,
        rating: rating,
      ),
    );
  }
}

class _HotelDetailScreenContent extends StatelessWidget {
  final String hotelName;
  final int hotelId;
  final double? rating;

  const _HotelDetailScreenContent({
    required this.hotelName,
    required this.hotelId,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: BlocConsumer<HotelBloc, HotelState>(
          listenWhen: (previous, current) {
            if (current is HotelToggleError) return true;
            if (previous is HotelLoaded && current is HotelLoaded) {
              return previous.isFav != current.isFav;
            }
            return false;
          },
          listener: (context, state) {
            if (state is HotelToggleError) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else if (state is HotelLoaded) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isFav ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.greenPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HotelLoading || state is HotelInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.greenPrimary),
              );
            } else if (state is HotelError) {
              return _buildErrorState(context, state.message);
            } else if (state is HotelLoaded) {
              return _buildHotelContent(context, state.hotel, state.isFav);
            } else if (state is HotelToggleError) {
              return _buildHotelContent(context, state.hotel, state.isFav);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () =>
                context.read<HotelBloc>().add(LoadHotelDetailEvent(hotelId)),
            child: Text(
              'Thử lại',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelContent(
    BuildContext context,
    HotelEntity hotel,
    bool isFav,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, hotel, isFav),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF5F7F6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(hotel, rating),
                    _buildDescription(hotel),
                    _buildAmenities(),
                    const SizedBox(
                      height: 100,
                    ), // Khoảng trống cho nút Đặt phòng ở dưới
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBottomNavigationBar(context, hotel),
      ],
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    HotelEntity hotel,
    bool isFav,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.greenPrimary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : Colors.white,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<HotelBloc>().add(
                  ToggleHotelFavoriteEvent(hotel.id),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Giả lập ảnh khách sạn (do API hiện tại có thể chưa trả về List ảnh trong entity này)
            Image.network(
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=1000',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: AppColors.greenMedium.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.hotel,
                  size: 80,
                  color: AppColors.greenPrimary,
                ),
              ),
            ),
            // Gradient làm mờ chân ảnh
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFFF5F7F6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(HotelEntity hotel, double? rating) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Khách sạn',
                style: GoogleFonts.dmSans(
                  color: AppColors.greenPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hotel.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A2B24),
              ),
            ),
            const SizedBox(height: 10),
            _buildStarRating(rating ?? 0),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotel.street ?? 'Đang cập nhật địa chỉ',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF6B8070),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final clamped = rating.clamp(0, 5);
    final filled = clamped.round();

    return Row(
      children: [
        ...List.generate(5, (index) {
          final isFilled = index < filled;
          return Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFilled ? Colors.amber : const Color(0xFFB0B8B3),
            size: 18,
          );
        }),
        const SizedBox(width: 6),
        Text(
          clamped.toStringAsFixed(1),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B8070),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(HotelEntity hotel) {
    if (hotel.description == null || hotel.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giới thiệu',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2B24),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hotel.description!,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF6B8070),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final amenities = [
      {'icon': Icons.wifi_rounded, 'name': 'Free Wifi'},
      {'icon': Icons.pool_rounded, 'name': 'Hồ bơi'},
      {'icon': Icons.restaurant_rounded, 'name': 'Nhà hàng'},
      {'icon': Icons.local_parking_rounded, 'name': 'Bãi đỗ xe'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện nghi',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2B24),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: amenities.map((a) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: AppColors.greenPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['name'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B8070),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, HotelEntity hotel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenPrimary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.greenPrimary, Color(0xFF23B97A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greenPrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomSelectionScreen(
                            hotelId: hotel.id,
                            hotelName: hotel.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Xem phòng & Đặt ngay',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
