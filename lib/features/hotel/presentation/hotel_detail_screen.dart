import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../booking/data/booking_api_service.dart';
import '../../booking/domain/usecases/create_booking_usecase.dart';
import '../../favorite/data/favorite_api_service.dart';
import '../../favorite/domain/usecases/toggle_favorite_usecase.dart';
// BỔ SUNG: Import UseCase kiểm tra trạng thái yêu thích
import '../../favorite/domain/usecases/check_favorite_usecase.dart';
import '../../hotel/data/hotel_api_service.dart';
import '../../hotel/domain/entities/hotel_entity.dart';
import '../../hotel/domain/usecases/get_hotel_by_id_usecase.dart';
import '../../booking/presentation/booking_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;

  const HotelDetailScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late final GetHotelByIdUseCase _getHotel;
  late final ToggleFavoriteUseCase _toggleFav;
  late final CheckFavoriteUseCase _checkFav; // Khai báo UseCase mới

  HotelEntity? _hotel;
  bool _isLoading = true;
  bool _isFav = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getHotel = GetHotelByIdUseCase(HotelApiService());
    
    // Khởi tạo các UseCase cho Favorite
    final favRepo = FavoriteApiService();
    _toggleFav = ToggleFavoriteUseCase(favRepo);
    _checkFav = CheckFavoriteUseCase(favRepo);
    
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // ĐÃ SỬA: Chạy song song 2 API lấy thông tin khách sạn và kiểm tra yêu thích
      final results = await Future.wait([
        _getHotel.execute(widget.hotelId),
        _checkFav.execute(widget.hotelId),
      ]);

      if (mounted) {
        setState(() { 
          _hotel = results[0] as HotelEntity?; 
          _isFav = results[1] as bool; // Cập nhật trạng thái trái tim chuẩn xác
          _isLoading = false; 
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _onToggleFav() async {
    final result = await _toggleFav.execute(widget.hotelId);
    if (mounted) {
      setState(() => _isFav = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích',
              style: GoogleFonts.poppins()),
          backgroundColor: result ? AppColors.greenPrimary : AppColors.brownAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _hotel == null
                  ? _buildError()
                  : _buildContent(_hotel!),
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        title: Text(widget.hotelName, style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 52, color: AppColors.error),
        const SizedBox(height: 12),
        Text('Không tải được thông tin', style: AppTextStyles.bodyMedium),
        TextButton(onPressed: _load, child: const Text('Thử lại')),
      ])),
    );
  }

  Widget _buildContent(HotelEntity hotel) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.greenPrimary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              hotel.name,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.greenPrimary, AppColors.greenMedium],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.hotel, size: 80, color: Colors.white54),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border,
                  color: _isFav ? Colors.redAccent : Colors.white),
              onPressed: _onToggleFav,
              tooltip: 'Yêu thích',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Hotel info
              Text('Thông tin khách sạn', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _InfoTile(Icons.location_on_outlined, 'Địa chỉ',
                  hotel.street ?? 'Chưa cập nhật'),
              const SizedBox(height: 10),
              _InfoTile(Icons.phone_outlined, 'Điện thoại',
                  hotel.phone ?? 'Chưa cập nhật'),
              const SizedBox(height: 10),
              _InfoTile(
                hotel.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                'Trạng thái',
                hotel.isActive ? 'Đang hoạt động' : 'Tạm ngưng',
              ),

              if (hotel.description != null && hotel.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Mô tả', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(hotel.description!, style: AppTextStyles.bodyMedium),
              ],

              const SizedBox(height: 32),

              // Book button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        hotelId: hotel.id,
                        hotelName: hotel.name,
                        createBookingUseCase: CreateBookingUseCase(BookingApiService()),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.book_online_outlined),
                  label: Text('Đặt phòng ngay', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: AppColors.greenPrimary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.labelMedium),
        Text(value, style: AppTextStyles.bodyMedium),
      ])),
    ]);
  }
}