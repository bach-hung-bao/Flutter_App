import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection.dart' as di;
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/screens/booking_detail_screen.dart';

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
    if (_isBottom) {
      context.read<NotificationBloc>().add(const LoadNotificationsEvent(reset: false));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thông báo hệ thống',
          style: GoogleFonts.dmSans(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.greenPrimary,
                strokeWidth: 3,
              ),
            );
          }

          if (state.error.isNotEmpty && state.notifications.isEmpty) {
            return _buildError();
          }

          final notifications = state.notifications;
          if (notifications.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: AppColors.greenPrimary,
            onRefresh: () async {
              context.read<NotificationBloc>().add(const LoadNotificationsEvent(reset: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.hasReachedMax ? notifications.length : notifications.length + 1,
              itemBuilder: (context, index) {
                if (index >= notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.greenPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return _NotificationItemCard(notification: notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông báo',
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra lại kết nối mạng hoặc server Backend.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => context.read<NotificationBloc>().add(const LoadNotificationsEvent(reset: true)),
              child: Text('Thử lại', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.greenPrimary),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thông báo nào',
            style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Text(
            'Trạng thái các đơn đặt phòng của bạn\nsẽ được cập nhật và hiển thị tại đây.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: Colors.grey[500], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NotificationItemCard extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItemCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy • HH:mm');
    final isUnread = !(notification.isRead ?? false);

    // Tự động nhận diện Icon và màu sắc dựa trên nội dung trạng thái đặt phòng
    IconData iconData = Icons.stars_rounded;
    Color iconColor = AppColors.greenPrimary;
    Color iconBg = const Color(0xFFE8F5E9);

    final titleLower = (notification.title ?? '').toLowerCase();
    if (titleLower.contains('hủy') || titleLower.contains('từ chối')) {
      iconData = Icons.cancel_rounded;
      iconColor = Colors.red;
      iconBg = const Color(0xFFFFEBEE);
    } else if (titleLower.contains('xác nhận') || titleLower.contains('thành công') || titleLower.contains('duyệt')) {
      iconData = Icons.check_circle_rounded;
      iconColor = AppColors.greenPrimary;
      iconBg = const Color(0xFFE8F5E9);
    } else if (titleLower.contains('chờ') || titleLower.contains('mới')) {
      iconData = Icons.pending_rounded;
      iconColor = Colors.orange;
      iconBg = const Color(0xFFFFF3E0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF1F8F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isUnread ? Border.all(color: AppColors.greenPrimary.withValues(alpha: 0.15), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            HapticFeedback.lightImpact();
            // Mark as read
            context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notification.id));

            // Navigate to booking detail if this is a booking notification
            if (notification.relatedId != null &&
                (notification.relatedTable == 'Bookings' || notification.type == 1)) {
              try {
                final token = await AuthStorage().getAccessToken();
                final response = await ApiClient().get(
                  '/api/bookings/detail/${notification.relatedId}',
                  accessToken: token,
                );
                final data = response['data'];
                if (data is Map<String, dynamic> && context.mounted) {
                  final booking = BookingModel.fromJson(data);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(booking: booking),
                    ),
                  );
                }
              } catch (_) {
                // Ignore navigation errors silently
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khối ICON đại diện trạng thái đơn phòng
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 24, color: iconColor),
                ),
                const SizedBox(width: 14),
                // Khối TEXT nội dung thông báo khách sạn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title ?? 'Cập nhật đặt phòng',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.greenPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.message ?? 'Đơn đặt phòng của bạn có thay đổi mới.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFmt.format(notification.createdAt ?? DateTime.now()),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}