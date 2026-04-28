class NotificationEntity {
  final int id;
  final int userId;
  final String? title;
  final String? message;
  final int
  type; // Using int for enum for simplicity, or String depending on API
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.title,
    this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
