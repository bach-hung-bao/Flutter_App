import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../notification/data/notification_api_service.dart';
import '../../notification/domain/usecases/get_notifications_usecase.dart';
import '../../notification/domain/entities/notification_entity.dart';
// import '../../../core/constants/app_colors.dart'; // We can use direct colors for now to match the user's aesthetic.

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final GetNotificationsUseCase _getNotifications;

  bool _isLoading = true;
  String? _error;
  List<NotificationEntity> _notifications = [];

  @override
  void initState() {
    super.initState();
    final repo = NotificationApiService();
    _getNotifications = GetNotificationsUseCase(repo);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _getNotifications.execute();
      if (mounted)
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
    }
  }

  Future<void> _markAsRead(NotificationEntity notif) async {
    if (notif.isRead) return;
    try {
      await NotificationApiService().markAsRead(notif.id);
      setState(() {
        final index = _notifications.indexWhere(
          (element) => element.id == notif.id,
        );
        if (index != -1) {
          _notifications[index] = NotificationEntity(
            id: notif.id,
            userId: notif.userId,
            title: notif.title,
            message: notif.message,
            type: notif.type,
            isRead: true,
            createdAt: notif.createdAt,
          );
        }
      });
    } catch (e) {
      // Ignored for now
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
          'Thông báo',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        // Since it's likely a primary tab inside shell, we don't need a back button if it's pushed, but depends.
        // I will add a leading button if Navigator can pop.
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _notifications.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return _buildNotificationCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity item) {
    return GestureDetector(
      onTap: () => _markAsRead(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1A8F5C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Thông báo',
                    style: GoogleFonts.dmSans(
                      fontWeight: item.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF1A2B24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.createdAt.toString().split('.')[0], // Format basic
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 52, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          'Không thể tải thông báo',
          style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey),
        ),
        TextButton(onPressed: _load, child: const Text('Thử lại')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.notifications_off_outlined,
          size: 80,
          color: Color(0xFFD1E5D9),
        ),
        const SizedBox(height: 20),
        Text(
          'Bạn chưa có thông báo nào',
          style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Khi có thông báo mới, chúng sẽ xuất hiện ở đây',
          style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
        ),
      ],
    ),
  );
}
