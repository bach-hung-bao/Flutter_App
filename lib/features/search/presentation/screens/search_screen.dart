import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../hotel/domain/entities/hotel_entity.dart';
import '../../../hotel/presentation/screens/hotel_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart' as di;
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SearchBloc>()..add(const LoadFeaturedHotelsEvent()),
      child: const _SearchScreenView(),
    );
  }
}

class _SearchScreenView extends StatefulWidget {
  const _SearchScreenView();

  @override
  State<_SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<_SearchScreenView> {
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final mode = context.read<SearchBloc>().state.searchMode;
    context.read<SearchBloc>().add(SearchQueryChangedEvent(query, mode));
  }

  void _toggleSearchMode(int mode) {
    final currentMode = context.read<SearchBloc>().state.searchMode;
    if (currentMode == mode) return;

    _searchController.clear();
    context.read<SearchBloc>().add(SearchQueryChangedEvent('', mode));
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
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final hasQuery = state.currentQuery.isNotEmpty;

        if (hasQuery) {
          if (state.isSearchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A8F5C)),
            );
          }
          if (state.searchError.isNotEmpty) {
            return Center(
              child: Text(
                state.searchError,
                style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 15),
              ),
            );
          }
          if (state.searchResults.isEmpty) {
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
            itemCount: state.searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => _buildHotelCard(context, state.searchResults[index]),
          );
        }

        if (state.isFeaturedLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A8F5C)),
          );
        }

        if (state.featuredError.isNotEmpty) {
          return Center(
            child: Text(
              'Không tải được khách sạn nổi bật.',
              style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        if (state.featured.isEmpty) {
          return Center(
            child: Text(
              'Nhập tên khách sạn hoặc tỉnh thành để bắt đầu tìm kiếm.',
              style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: state.featured.length + 1,
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
            return _buildHotelCard(context, state.featured[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildSearchHeader() {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (p, c) => p.searchMode != c.searchMode || p.currentQuery != c.currentQuery,
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildFilterChip('Theo tên KS', 0, state.searchMode),
                  const SizedBox(width: 8),
                  _buildFilterChip('Theo Tỉnh/Thành', 1, state.searchMode),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: state.searchMode == 0
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
      },
    );
  }

  Widget _buildFilterChip(String label, int mode, int currentMode) {
    final isSelected = currentMode == mode;
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
