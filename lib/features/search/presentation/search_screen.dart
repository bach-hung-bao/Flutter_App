import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../hotel/domain/entities/hotel_entity.dart';
import '../data/search_api_service.dart';
import '../../hotel/presentation/hotel_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _apiService = SearchApiService();

  Timer? _debounce;
  bool _isLoading = false;
  String _error = '';
  List<HotelEntity> _results = [];
  bool _isFeaturedLoading = true;
  String _featuredError = '';
  List<HotelEntity> _featured = [];

  // Chế độ tìm kiếm (0 = Theo tên, 1 = Theo tỉnh/thành phố)
  int _searchMode = 0;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeatured() async {
    setState(() {
      _isFeaturedLoading = true;
      _featuredError = '';
    });
    try {
      final items = await _apiService.getFeaturedHotels(pageSize: 8);
      if (mounted) {
        setState(() {
          _featured = items;
          _isFeaturedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFeaturedLoading = false;
          _featuredError = e.toString();
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _error = '';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _results = _filterFeatured(query);
        _error = '';
      });
    }

    _debounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final items = _searchMode == 0
          ? await _apiService.searchHotelsByName(query)
          : await _apiService.searchHotelsByProvince(query);

      if (mounted) {
        final merged = items.isNotEmpty ? items : _filterFeatured(query);
        setState(() => _results = merged);
      }
    } catch (e) {
      // 400 Bad Request cho by-province hoặc hotelName rỗng.
      if (mounted) {
        setState(() {
          _error = e.toString().contains('404')
              ? 'Không tìm thấy kết quả.'
              : 'Có lỗi xảy ra: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<HotelEntity> _filterFeatured(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];
    return _featured.where((h) {
      final name = h.name.toLowerCase();
      return name.startsWith(normalized) || name.contains(normalized);
    }).toList();
  }

  void _toggleSearchMode(int mode) {
    if (_searchMode == mode) return;
    setState(() {
      _searchMode = mode;
      _results.clear(); // Xóa kết quả cũ
      _error = '';
    });
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
      _performSearch(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D6B42), Color(0xFF1A8F5C), Color(0xFF1FAD6F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Tìm kiếm Khách sạn',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 22,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final hasQuery = _searchController.text.trim().isNotEmpty;

    if (hasQuery) {
      if (_isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A8F5C)),
        );
      }
      if (_error.isNotEmpty) {
        return Center(
          child: Text(
            _error,
            style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 15),
          ),
        );
      }
      if (_results.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Color(0xFFD1E5D9),
              ),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy khách sạn nào',
                style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, index) => _buildHotelCard(context, _results[index]),
      );
    }

    if (_isFeaturedLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A8F5C)),
      );
    }

    if (_featuredError.isNotEmpty) {
      return Center(
        child: Text(
          'Không tải được khách sạn nổi bật.',
          style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    if (_featured.isEmpty) {
      return Center(
        child: Text(
          'Nhập tên khách sạn hoặc tỉnh thành để bắt đầu tìm kiếm.',
          style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _featured.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'Khách sạn nổi bật',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2B24),
            ),
          );
        }
        return _buildHotelCard(context, _featured[index - 1]);
      },
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFilterChip('Theo tên KS', 0),
              const SizedBox(width: 8),
              _buildFilterChip('Theo Tỉnh/Thành', 1),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: _searchMode == 0
                  ? 'Nhập tên khách sạn...'
                  : 'Ví dụ: TP HCM, Hà Nội...',
              hintStyle: GoogleFonts.dmSans(color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF5F7F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int mode) {
    final isSelected = _searchMode == mode;
    return GestureDetector(
      onTap: () => _toggleSearchMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E9B66) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF1E9B66) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, HotelEntity hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HotelDetailScreen(hotelId: hotel.id, hotelName: hotel.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.hotel,
                  size: 40,
                  color: Color(0xFF1A8F5C),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1A2B24),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                            hotel.street ?? 'Không có địa chỉ cụ thể',
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
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB84D).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "4.8",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFFCC8C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
