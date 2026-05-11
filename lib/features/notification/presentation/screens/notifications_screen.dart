import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart' as di;
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NotificationBloc>()..add(const LoadNotificationsEvent(reset: true)),
      child: const _NotificationsScreenView(),
    );
  }
}

class _NotificationsScreenView extends StatefulWidget {
  const _NotificationsScreenView();

  @override
  State<_NotificationsScreenView> createState() => _NotificationsScreenViewState();
}

class _NotificationsScreenViewState extends State<_NotificationsScreenView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Tải thêm dữ liệu khi cuộn gần đến đáy
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificationBloc>().state;
      if (!state.isLoadingMore && !state.hasReachedMax && !state.isLoading) {
        context.read<NotificationBloc>().add(const LoadMoreNotificationsEvent());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(const LoadNotificationsEvent(reset: true));
    // Tạo độ trễ ảo nhẹ để UX mượt mà hơn khi pull-to-refresh
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: AppColors.greenPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Thông báo',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary));
            }

            if (state.error.isNotEmpty && state.notifications.isEmpty) {
              return _buildError(context);
            }

            if (state.notifications.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              color: AppColors.greenPrimary,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(top: 16, bottom: 40),
                itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: AppColors.greenPrimary, strokeWidth: 2.5),
                        ),
                      ),
                    );
                  }
                  return _buildItem(context, state.notifications[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, NotificationEntity item) {
    final isRead = item.isRead;
    
    // Format thời gian đơn giản (dd/MM/yyyy HH:mm)
    final day = item.createdAt.day.toString().padLeft(2, '0');
    final month = item.createdAt.month.toString().padLeft(2, '0');
    final year = item.createdAt.year;
    final hour = item.createdAt.hour.toString().padLeft(2, '0');
    final minute = item.createdAt.minute.toString().padLeft(2, '0');
    final dateStr = "$day/$month/$year lúc $hour:$minute";

    return InkWell(
      onTap: () {
        if (!isRead) {
          context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(item.id));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0F9F4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? const Color(0xFFEAEEEC) : AppColors.greenPrimary.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFF5F7F6) : AppColors.greenPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.type == 1 ? Icons.book_online_rounded : Icons.notifications_active_rounded,
                color: isRead ? const Color(0xFF6B8070) : AppColors.greenPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Thông báo hệ thống',
                    style: GoogleFonts.dmSans(
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF1A2B24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF6B8070),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dateStr,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9AAFA1),
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
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
            style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF172B24)),
          ),
          const SizedBox(height: 8),
          Text(
            'Không thể tải thông báo lúc này.',
            style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF6B8070)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => context.read<NotificationBloc>().add(const LoadNotificationsEvent(reset: true)),
            child: Text('Thử lại', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.greenPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.greenPrimary),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thông báo nào',
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF172B24)),
          ),
          const SizedBox(height: 12),
          Text(
            'Khi có thông báo về đặt phòng hay ưu đãi,\nchúng sẽ xuất hiện ở đây.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF6B8070), height: 1.5),
          ),
        ],
      ),
    );
  }
}