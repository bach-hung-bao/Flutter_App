import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection.dart' as di;
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';
import '../../../hotel/domain/entities/hotel_entity.dart';
import '../../../hotel/presentation/screens/hotel_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';

// --- CONSTANTS ĐỒNG BỘ VỚI HOME ---
const _kGreen = AppColors.greenPrimary;
const _kSurface = Color(0xFFF8FAFC);
const _kTextPrimary = Color(0xFF1E293B);
const _kTextSec = Color(0xFF64748B);

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<FavoriteBloc>()..add(LoadFavoritesEvent()),
      child: const _FavoritesScreenView(),
    );
  }
}

class _FavoritesScreenView extends StatelessWidget {
  const _FavoritesScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
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
          'Khách sạn yêu thích',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteError && !state.isAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _kGreen),
            );
          }

          if (state is FavoriteError && state.isAuthError) {
            return _buildLoginRequired(context);
          }

          if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<FavoriteBloc>().add(LoadFavoritesEvent()),
              color: _kGreen,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final hotel = state.favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _FavoriteHotelCard(
                      hotel: hotel,
                      index: index,
                      onRemove: () {
                        context.read<FavoriteBloc>().add(
                          ToggleFavoriteInListEvent(hotel.id!),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- GIAO DIỆN KHI TRỐNG ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: _kGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có yêu thích',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hãy thả tim những khách sạn bạn ưng ý để xem lại chúng tại đây nhé!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 15, color: _kTextSec),
            ),
          ),
        ],
      ),
    );
  }

  // --- GIAO DIỆN CHƯA ĐĂNG NHẬP ---
  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'Yêu cầu đăng nhập',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng đăng nhập để xem danh sách khách sạn yêu thích của bạn.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET THẺ KHÁCH SẠN (ĐỒNG BỘ 100% VỚI HOME) ---
class _FavoriteHotelCard extends StatelessWidget {
  final HotelEntity hotel;
  final int index;
  final VoidCallback onRemove;

  const _FavoriteHotelCard({
    required this.hotel,
    required this.index,
    required this.onRemove,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách ảnh dự phòng giống màn Home
    final List<String> networkFallbacks = [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1542314831-c6a4d14b837?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1551882547-ff40c0d139f3?auto=format&fit=crop&w=800&q=80',
    ];

    // Lấy ảnh từ backend, nếu không có thì lấy ảnh dự phòng
    final String displayImage =
        (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
        ? hotel.imageUrl!
        : networkFallbacks[index % networkFallbacks.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HotelDetailScreen(hotelId: hotel.id, hotelName: hotel.name),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PHẦN ẢNH & NÚT XOÁ
              Stack(
                children: [
                  Image.network(
                    displayImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.network(
                      networkFallbacks[index % networkFallbacks.length],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Nút bỏ yêu thích
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8', // Giả định rating, bạn có thể thay bằng hotel.rating nếu có
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. PHẦN THÔNG TIN
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: _kGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.street ?? 'Chua cap nhat dia chi',
                            style: GoogleFonts.dmSans(
                              color: _kTextSec,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá chỉ từ',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: _kTextSec,
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                1200000,
                              ), // Thay bằng giá thực tế nếu hotel có trường price
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _kGreen,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Xem ngay',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
