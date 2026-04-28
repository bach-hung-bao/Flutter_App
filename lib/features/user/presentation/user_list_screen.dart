import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../data/user_admin_api_service.dart';
import '../domain/entities/user_entity.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _apiService = UserAdminApiService();
  final _scrollController = ScrollController();

  final List<UserEntity> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _error = '';
  int _pageIndex = 1;
  int _totalCount = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool reset = false}) async {
    if (reset) {
      setState(() {
        _items.clear();
        _pageIndex = 1;
        _totalCount = 0;
        _error = '';
        _isLoading = true;
      });
    }

    try {
      final (items, total) = await _apiService.getUsers(
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _totalCount = total;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_isLoadingMore || _items.length >= _totalCount) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _pageIndex += 1;
      _fetchUsers();
    }
  }

  Future<void> _openForm({UserEntity? user}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
    );
    if (result == true) {
      _fetchUsers(reset: true);
    }
  }

  Future<void> _confirmDelete(UserEntity user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có chắc chắn muốn xóa ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await _apiService.deleteUser(user.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((item) => item.id == user.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
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
          'Quản lý người dùng',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenPrimary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchUsers(reset: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(_error)),
                ],
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final user = _items[index];
                  return _buildUserCard(user);
                },
              ),
      ),
    );
  }

  Widget _buildUserCard(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.greenSurface,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: AppColors.greenPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: 'Sửa',
                onPressed: () => _openForm(user: user),
                icon: const Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
              ),
              IconButton(
                tooltip: 'Xóa',
                onPressed: () => _confirmDelete(user),
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
